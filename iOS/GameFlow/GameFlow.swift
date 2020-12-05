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

enum GameState: String {
    case justStarted
    case speakTitle
    case speakInitialDescription
    case speakingTranslation
    case speakingTargetString
    case echoMethod
    case listening
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
    private var wait = Promise<Void>.pending()
    private var gameSeconds: Int = 0

    static var shared = GameFlow()

    init() {}

    // MARK: - Key GameFlow

    func start() {
        isPaused = false
        wait = fulfilledVoidPromise()

        startCommandObserving(self)
        SpeechEngine.shared.start()
        SpeechEngine.shared.preloadTTSVoice()
        context.gameState = .justStarted
        context.gameRecord?.startedTime = Date()

        startTimer()

        context.loadLearningSentences()

        Promises.all([
            waitKanaInfoLoaded,
            waitDifficultyDBLoaded,
        ])
            .then { _ in
                speakTitle()
            }
            .then(tryWait)
            .then(speakInitialDescription)
            .then(tryWait)
            .always {
                self.learnNextSentence()
            }
    }

    // Flow for learn a sentence
    private func learnNextSentence() {
        // Click skipNext  => stop previous game's promise chain
        if isNeedToStopPromiseChain {
            isNeedToStopPromiseChain = false
            return
        }
        speakTranslation()
            .then(tryWait)
            .then(speakTargetString)
            .then(tryWait)
            .then(echoMethod)
            .then(tryWait)
            .then(listenPart)
            .then(tryWait)
            .catch { error in
                print("Promise chain is dead", error)
            }
            .always { [weak self] in
                guard let self = self else { return }
                self.wait.fulfill(())

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
            return context.gameSetting.isEchoMethod ?
                i18n.gameStartedWithEchoMethod : i18n.gameStartedWithGuideVoice
        case .interpretation:
            return i18n.gameStartedWithoutGuideVoice
        }
    }

    private func speakInitialDescription() -> Promise<Void> {
        if !context.gameSetting.isSpeakInitialDescription { return fulfilledVoidPromise() }
        context.gameState = .speakInitialDescription
        return narratorSay(narratorString)
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
            if let gr = context.gameRecord {
                if context.gameMode == .infiniteChallengeMode {
                    lastInfiniteChallengeSentences[gr.level] = context.sentences.map { s in
                        s.origin
                    }
                }
                if context.gameMode == .medalMode {
                    context.gameMedal.updateMedals(record: &context.gameRecord!)
                    saveMedalCount()
                }
            }
            updateGameHistory()
            saveGameSetting()
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

        var translation = context.targetSentence.translation

        // only speak the first meaning when multiple meanings are available
        if translation.range(of: "/") != nil {
            translation = translation.split(separator: "/")[0].s
        }
        return translatorSay(translation)
    }

    private func speakTargetString() -> Promise<Void> {
        if isNeedToStopPromiseChain { return rejectedVoidPromise() }

        context.gameState = .speakingTargetString
        guard context.gameSetting.isSpeakOriginal else {
            return fulfilledVoidPromise()
        }

        return teacherSay(context.targetString, ttsFixes: context.ttsFixes)
    }

    private func echoMethod() -> Promise<Void> {
        if isNeedToStopPromiseChain { return rejectedVoidPromise() }

        guard context.gameSetting.isEchoMethod else {
            return fulfilledVoidPromise()
        }
        context.gameState = .echoMethod
        return pausePromise(Double(context.speakDuration))
    }

    private func listenPart() -> Promise<Void> {
        if isNeedToStopPromiseChain { return rejectedVoidPromise() }

        if context.gameSetting.isMointoring {
            engine.monitoringOn()
        } else {
            engine.monitoringOff()
        }

        return listenWrapped()
            .then(saveUserSaidString)
            .then(getScore)
            .then(speakScore)
    }

    private func listenWrapped() -> Promise<String> {
        context.gameState = .listening
        if context.gameSetting.isSpeakOriginal {
            return engine
                .listen(duration: Double(context.speakDuration + pauseDuration))
        }

        return context
            .calculatedSpeakDuration
            .then { speakDuration -> Promise<String> in
                engine.listen(duration: Double(speakDuration + pauseDuration))
            }
    }

    private func saveUserSaidString(userSaidString: String) -> Promise<Void> {
        if isNeedToStopPromiseChain { return rejectedVoidPromise() }
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
