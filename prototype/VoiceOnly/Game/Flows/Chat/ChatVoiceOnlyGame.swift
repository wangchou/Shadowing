//
//  ChatVoiceOnlyGame.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 9/3/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation
import Promises

private let context = GameContext.shared

class ChatVoiceOnlyGame: Game {
    static let shared = VoiceOnlyGame()
    private var gameSeconds: Int = 0
    private var timer: Timer?

    // MARK: - Public Functions
    func start() {
        startEngine(toSpeaker: false)
        context.gameState = .stopped
        context.gameRecord?.startedTime = Date()
        gameSeconds = 0
        prepareTimer()
        context.loadLearningSentences()
        meijia("每句日文說完後，請跟著說～").always {
            self.learnNext()
        }
    }

    func stop() {
        context.gameRecord?.playDuration = gameSeconds
        context.gameState = .stopped
        timer?.invalidate()
        stopEngine()
    }

    // MARK: - Private Functions
    private func learnNext() {
        sayRemainingSentenceCount()
            .then(speakTargetString)
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
                    self.gameOver()
                }
        }
    }

    private func sayRemainingSentenceCount() -> Promise<Void> {
        return kyoko(context.remainingSentenceCount.s, rate: normalRate)
    }

    private func iHearYouSaid() -> Promise<Void> {
        guard context.score.value != 100 else { return fulfilledVoidPromise() }
        return meijia("我聽到")
            .then { oren(context.userSaidString) }
    }

    private func speakScore() -> Promise<Void> {
        return meijia(context.score.valueText)
    }

    private func prepareTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            postEvent(.playTimeUpdate, int: self.gameSeconds)
            self.gameSeconds += 1
        }
    }

    private func gameOver() {
        meijia("遊戲結束").then {
            context.gameState = .gameOver
            self.stop()
        }
    }
}
