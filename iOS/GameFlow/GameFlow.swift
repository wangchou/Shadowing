//
//  FlowController1.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/04.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import Promises

enum GameError: Error {
    case forceStop
}

enum GameState {
    case justStarted
    case TTSSpeaking
    case listening
    case scoreCalculated
    case speakingScore
    case sentenceSessionEnded
    case gameOver
    case forceStopped
}

private let engine = SpeechEngine.shared
private let context = GameContext.shared
private let setting = context.gameSetting
private let i18n = I18n.shared

// handler for commands posted from UI
extension GameFlow: GameCommandDelegate {
    @objc func onCommandHappened(_ notification: Notification) {
        guard let command = notification.object as? Command else { print("convert command fail"); return }

        switch command.type {
        case .resume:
            resume()
        case .forceStopGame:
            forceStop()
        case .pause:
            pause()
        }
    }
}

class GameFlow {
    private var isPaused: Bool = false
    private var isForceStopped = false
    private var timer: Timer?
    private var wait: Promise<Void> = Promise<Void>.pending()
    private var gameSeconds: Int = 0

    static let shared = GameFlow()

    private init() {}

    // MARK: - Public Functions
    func start() {
        isPaused = false
        isForceStopped = false
        wait = Promise<Void>.pending()
        gameSeconds = 0
        startCommandObserving(self)
        SpeechEngine.shared.start()
        context.gameState = .justStarted
        context.gameRecord?.startedTime = Date()

        startTimer()

        context.loadLearningSentences()
        let narratorString = setting.learningMode == .interpretation ?
            i18n.gameStartedWithoutGuideVoice :
            i18n.gameStartedWithGuideVoice
        if setting.isUsingNarrator {
            narratorSay(narratorString)
                .then { self.wait }
                .always {
                    self.learnNextSentence()
                }
        } else {
            learnNextSentence()
        }

        isPaused = false
        wait.fulfill(())
    }
}

// MARK: - Private Functions
extension GameFlow {

    // Main Game Flow keep calling learnNext
    private func learnNextSentence() {
        guard !self.isForceStopped else { return }
        speakTranslation()
            .then( speakTargetString )
            .then { self.wait }
            .then( listenPart )
            .then { self.wait }
            .catch { error in print("Promise chain is dead", error)}
            .always {
                guard !self.isForceStopped else { return }
                context.gameState = .sentenceSessionEnded
                if context.nextSentence() {
                    self.learnNextSentence()
                } else {
                    self.gameOver()
                }
        }
    }

    private func forceStop() {
        stopCommandObserving(self)
        isForceStopped = true
        context.gameState = .forceStopped

        timer?.invalidate()
        isPaused = false
        wait.reject(GameError.forceStop)
        SpeechEngine.shared.reset()
    }

    private func gameOver() {
        narratorSay(i18n.gameOver).then {
            stopCommandObserving(self)
            context.gameState = .gameOver

            context.gameRecord?.playDuration = self.gameSeconds
            self.timer?.invalidate()
            updateGameHistory()
            saveGameSetting()
            if context.contentTab == .infiniteChallenge,
                let gr = context.gameRecord {
                lastInfiniteChallengeSentences[gr.level] = context.sentences
            }
            saveGameMiscData()
        }
    }

    private func pause() {
        wait = Promise<Void>.pending()
        isPaused = true
    }

    private func resume() {
        isPaused = false
        wait.fulfill(())
    }

    private func listenPart() -> Promise<Void> {
        return listenWrapped()
            .then(getScore)
            .then(speakScore)
    }

    // change life will change the teachingSpeed
    // initial life = 50, speed = 0.7x
    // life 100 => speed 1.1x
    // life 0   => speed 0.4x
    private func updateLife(score: Score) {
        var life = context.life

        switch score.type {
        case .perfect:
            life += 4
        case .great:
            life += 2
        case .good:
            life += -4
        case .poor:
            life += -6
        }

        context.life = max(min(100, life), 0)

        postEvent(.lifeChanged, int: context.life)
    }

    private func speakScore() -> Promise<Void> {
        let score = context.score
        updateLife(score: score)

        return assisantSay(score.text)
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if self.isPaused { return }

            postEvent(.playTimeUpdate, int: self.gameSeconds)
            self.gameSeconds += 1
        }
    }

    private func speakTranslation() -> Promise<Void> {
        context.gameState = .TTSSpeaking
        guard context.gameSetting.isSpeakTranslation else {
            return fulfilledVoidPromise()
        }
        var translationsDict = (gameLang == .jp && context.contentTab == .topics) ?
            chTranslations : translations
        var translation = translationsDict[context.targetString] ?? ""

        // only speak the first meaning when multiple meanings are available
        if translation.range(of: "/") != nil {
            translation = translation.split(separator: "/")[0].s
        }
        return translatorSay(translation)
    }

    private func speakTargetString() -> Promise<Void> {
        guard context.gameSetting.isUsingGuideVoice else {
            postEvent(.sayStarted, string: context.targetString)
            return fulfilledVoidPromise()
        }

        return teacherSay(context.targetString)
    }

    private func listenWrapped() -> Promise<Void> {
        context.gameState = .listening
        if context.gameSetting.isMointoring { engine.monitoringOn() }
        if context.gameSetting.isUsingGuideVoice {
            return engine
                .listen(duration: Double(context.speakDuration + pauseDuration))
                .then(saveUserSaidString)
        }

        return context
            .calculatedSpeakDuration
            .then({ speakDuration -> Promise<String> in
                return engine.listen(duration: Double(speakDuration + pauseDuration))
            })
            .then(saveUserSaidString)
    }

    private func saveUserSaidString(userSaidString: String) -> Promise<Void> {
        engine.monitoringOff()
        context.userSaidString = userSaidString
        userSaidSentences[context.targetString] = userSaidString
        return fulfilledVoidPromise()
    }

    private func getScore() -> Promise<Void> {
        return calculateScore(context.targetString, context.userSaidString)
            .then(saveScore)
    }

    private func saveScore(score: Score) -> Promise<Void> {
        context.score = score
        sentenceScores[context.targetString] = score
        updateGameRecord(score: score)
        return fulfilledVoidPromise()
    }

    private func updateGameRecord(score: Score) {
        context.gameRecord?.sentencesScore[context.targetString] = score

        switch score.type {
        case .perfect:
            context.gameRecord?.perfectCount += 1
        case .great:
            context.gameRecord?.greatCount += 1
        case .good:
            context.gameRecord?.goodCount += 1
        default:
            ()
        }
    }
}
