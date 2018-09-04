//
//  FlowController1.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/04.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import Promises

private let context = GameContext.shared

class VoiceOnlyGame: Game {
    static let shared = VoiceOnlyGame()

    // MARK: - Public Functions
    override func start() {
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
        return oren(context.score.valueText, rate: normalRate)
    }
}
