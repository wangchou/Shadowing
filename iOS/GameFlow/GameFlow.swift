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

    case speakingTranslation

    case speakingTargetString

    case echoMethod

    case listening
    case scoreCalculated

    case gameOver
}

private let engine = SpeechEngine.shared
private let context = GameContext.shared

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
    private var isNeedToStopPromiseChain = false
    private var timer: Timer?
    private var wait: Promise<Void> = Promise<Void>.pending()
    private var gameSeconds: Int = 0

    static let shared = GameFlow()

    private init() {}

    // MARK: - Key GameFlow
    func start() {
        isPaused = false

        wait = fulfilledVoidPromise()

        startCommandObserving(self)
        SpeechEngine.shared.start()
        context.gameState = .justStarted
        context.gameRecord?.startedTime = Date()

        startTimer()

        context.loadLearningSentences()

        speakTitle(title: context.gameTitle)
            .then( tryWait )
            .then( speakNarratorString )
            .then( tryWait )
            .always {
                self.learnNextSentence()
            }
    }

    // Flow for learn a sentence
    private func learnNextSentence() {
        // Click skipNext  => stop previous game's promise chain
        if self.isNeedToStopPromiseChain {
            isNeedToStopPromiseChain = false
            return
        }
        speakTranslation()
            .then( tryWait )
            .then( speakTargetString )
            .then( tryWait )
            .then( echoMethod )
            .then( tryWait )
            .then( listenPart )
            .then( tryWait )
            .catch { error in
                print("Promise chain is dead", error)
            }
            .always {
                // Click skipNext  => stop previous game's promise chain
                if self.isNeedToStopPromiseChain {
                    self.isNeedToStopPromiseChain = false
                    return
                }

                if context.nextSentence() {
                    self.learnNextSentence()
                } else {
                    self.gameOver()
                }
            }
    }
}

// MARK: - Flow Steps
extension GameFlow {
    private var narratorString: String {
        switch context.gameSetting.learningMode {
        case .meaningAndSpeaking, .speakingOnly:
            return i18n.gameStartedWithGuideVoice
        case .echoMethod:
            return i18n.gameStartedWithEchoMethod
        case .interpretation:
            return i18n.gameStartedWithoutGuideVoice
        }
    }

    private func speakNarratorString() -> Promise<Void> {
        if !context.gameSetting.isUsingNarrator { return fulfilledVoidPromise() }

        return narratorSay(self.narratorString)
    }

    private func tryWait() -> Promise<Void> {
        return wait
    }

    private func forceStop() {
        stopCommandObserving(self)
        isNeedToStopPromiseChain = true

        timer?.invalidate()
        isPaused = false
        wait.reject(GameError.forceStop)
        SpeechEngine.shared.stopListeningAndSpeaking()
    }

    private func gameOver() {
        isNeedToStopPromiseChain = false

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
        postEvent(.gameResume)
        wait.fulfill(())
    }

    private func startTimer() {
        gameSeconds = 0
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.isPaused { return }

            postEvent(.playTimeUpdate, int: self.gameSeconds)
            self.gameSeconds += 1
        }
    }

    private func speakTranslation() -> Promise<Void> {
        if isNeedToStopPromiseChain { return rejectedVoidPromise() }

        context.gameState = .speakingTranslation
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
        if isNeedToStopPromiseChain { return rejectedVoidPromise() }

        context.gameState = .speakingTargetString
        guard context.gameSetting.isUsingGuideVoice else {
            postEvent(.sayStarted, string: context.targetString)
            return fulfilledVoidPromise()
        }

        return teacherSay(context.targetString)
    }

    private func echoMethod() -> Promise<Void> {
        if isNeedToStopPromiseChain { return rejectedVoidPromise() }

        if context.gameSetting.learningMode == .echoMethod {
            context.gameState = .echoMethod
            return pausePromise(Double(context.speakDuration))
        }
        return fulfilledVoidPromise()
    }

    private func listenPart() -> Promise<Void> {
        if isNeedToStopPromiseChain { return rejectedVoidPromise() }

        return listenWrapped()
            .then(saveUserSaidString)
            .then(getScore)
            .then(speakScore)
    }

    private func listenWrapped() -> Promise<String> {
        context.gameState = .listening
        if context.gameSetting.isMointoring { engine.monitoringOn() }
        if context.gameSetting.isUsingGuideVoice {
            return engine
                .listen(duration: Double(context.speakDuration + pauseDuration))
        }

        return context
            .calculatedSpeakDuration
            .then({ speakDuration -> Promise<String> in
                return engine.listen(duration: Double(speakDuration + pauseDuration))
            })
    }

    private func saveUserSaidString(userSaidString: String) -> Promise<Void> {
        if isNeedToStopPromiseChain { return rejectedVoidPromise() }
        engine.monitoringOff()
        userSaidSentences[context.targetString] = userSaidString
        return fulfilledVoidPromise()
    }

    private func getScore() -> Promise<Void> {
        if isNeedToStopPromiseChain { return rejectedVoidPromise() }
        return calculateScore(context.targetString, context.userSaidString)
            .then(saveScore)
    }

    private func saveScore(score: Score) -> Promise<Void> {
        context.score = score
        sentenceScores[context.targetString] = score
        updateGameRecord(score: score)
        return fulfilledVoidPromise()
    }

    private func speakScore() -> Promise<Void> {
        if isNeedToStopPromiseChain { return rejectedVoidPromise() }
        return assisantSay(context.score.text)
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
