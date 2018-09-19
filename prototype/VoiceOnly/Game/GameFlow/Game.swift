//
//  GameFlow.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/05.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import Promises

private let context = GameContext.shared
private let engine = GameEngine.shared

enum GameState {
    case stopped
    case TTSSpeaking
    case listening
    case stringRecognized
    case repeatingWhatSaid
    case scoreCalculated
    case speakingScore
    case sentenceSessionEnded
    case gameOver
}

class Game {
    var timer: Timer?
    var isPaused: Bool = false
    var wait: Promise<Void> = Promise<Void>.pending()
    var gameSeconds: Int = 0
    func start() { print("please override game.start method") }
}

extension Game {
    internal func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if self.isPaused { return }

            postEvent(.playTimeUpdate, int: self.gameSeconds)
            self.gameSeconds += 1
        }
    }

    internal func gameOver() {
        meijia("遊戲結束").then {
            context.gameState = .gameOver
            self.stop()
        }
    }

    func stop() {
        context.gameRecord?.playDuration = gameSeconds
        context.gameState = .stopped
        timer?.invalidate()
        updateGameHistory()
        saveGameSetting()
        saveUserSaidSentencesAndScore()
    }

    internal func speakTargetString() -> Promise<Void> {
        context.gameState = .TTSSpeaking
        return Game.speak(text: context.targetString, speaker: context.targetSpeaker)
    }

    static func speak(text: String, speaker: ChatSpeaker? = nil) -> Promise<Void> {
        let startTime = getNow()
        func updateSpeakDuration() -> Promise<Void> {
            context.speakDuration = Float((getNow() - startTime))
            return fulfilledVoidPromise()
        }
        let language = text.langCode
        if language == "ja",
           let speaker = speaker {
            switch speaker {
            case .man1:
                return hattori(text).then(updateSpeakDuration)
            case .man2:
                return otoya(text).then(updateSpeakDuration)
            case .woman1:
                return oren(text).then(updateSpeakDuration)
            case .woman2:
                return kyoko(text).then(updateSpeakDuration)
            case .narrator:
                return meijia(text).then(updateSpeakDuration)
            case .user:
                return fulfilledVoidPromise().then(updateSpeakDuration)
            }
        }

        return engine.tts.say(text, language: language, rate: context.teachingRate)
                .then(updateSpeakDuration)
    }

    internal func listenWrapped() -> Promise<Void> {
        context.gameState = .listening
        if context.gameFlowMode == .chat {
            return context.calculatedSpeakDuration.then({ speakDuration -> Promise<String> in
                return listen(duration: Double(speakDuration + pauseDuration))
            })
            .then(saveUserSaidString)
        } else {
            return listen(duration: Double(context.speakDuration + pauseDuration))
                .then(saveUserSaidString)
        }
    }

    private func saveUserSaidString(userSaidString: String) -> Promise<Void> {
        context.gameState = .stringRecognized
        context.userSaidString = userSaidString
        userSaidSentences[context.targetString] = userSaidString
        return fulfilledVoidPromise()
    }

    internal func getScore() -> Promise<Void> {
        return calculateScore(context.targetString, context.userSaidString)
            .then(saveScore)
    }

    private func saveScore(score: Score) -> Promise<Void> {
        context.gameState = .scoreCalculated
        context.score = score
        sentenceScores[context.targetString] = score
        updateGameRecord(score: score)
        return fulfilledVoidPromise()
    }

    internal func updateGameRecord(score: Score) {
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
