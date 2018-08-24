//
//  FlowController1.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/04.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import Promises

private let pauseDuration = 0.4
private let context = GameContext.shared

class VoiceOnlyGame: Game {
    static let shared = VoiceOnlyGame()
    var startTime: Double = 0
    private var gameSeconds: Int = 0
    private var timer: Timer?

    var state: GameState = .stopped {
        didSet {
            postEvent(.gameStateChanged, gameState: state)
        }
    }

    func start() {
        startEngine(toSpeaker: false)
        context.gameRecord?.startedTime = Date()
        gameSeconds = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            //if self.isPaused { return }

            postEvent(.playTimeUpdate, int: self.gameSeconds)
            self.gameSeconds += 1
        }
        context.loadLearningSentences()
        learnNext()
    }

    func stop() {
        context.gameRecord?.playDuration = gameSeconds
        stopEngine()
    }

    private func learnNext() {
        speakJapanese()
        .then(listen)
        .then(getScore)
        .then(iHearYouSaid)
        .then(speakScore)
        .catch { error in
            print("error ... \(error)")
        }.always {
            if context.nextSentence() {
                self.learnNext()
            } else {
                meijia("遊戲結束").then {
                    self.state = .gameOver
                    self.stop()
                }
            }
        }
    }

    private func speakJapanese() -> Promise<Void> {
        self.state = .speakingJapanese
        self.startTime = getNow()
        return hattori(context.targetString)
    }

    private func listen() -> Promise<Void> {
        self.state = .listening
        let speakDuration = getNow() - self.startTime
        return listenJP(duration: speakDuration + pauseDuration)
                 .then(saveUserSaidString)
    }

    private func saveUserSaidString(userSaidString: String) -> Promise<Void> {
        self.state = .stringRecognized
        context.userSaidString = userSaidString
        return fulfilledPromise()
    }

    private func getScore() -> Promise<Void> {
        return calculateScore(context.targetString, context.userSaidString)
                 .then(saveScore)
    }

    private func saveScore(score: Score) -> Promise<Void> {
        self.state = .scoreCalculated
        context.score = score
        updateRecord(score: score)
        return fulfilledPromise()
    }

    private func updateRecord(score: Score) {
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

    private func iHearYouSaid() -> Promise<Void> {
        guard context.score.value != 100 else { return fulfilledPromise() }
        return meijia("我聽到")
            .then { oren(context.userSaidString) }
    }

    private func fulfilledPromise() -> Promise<Void> {
        let promise = Promise<Void>.pending()
        promise.fulfill(())
        return promise
    }

    private func speakScore() -> Promise<Void> {
        return meijia(context.score.valueText)
    }
}
