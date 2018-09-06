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

class ShadowingFlow: Game {
    static let shared = ShadowingFlow()

    // MARK: - Public Functions
    override func start() {
        startEngine(toSpeaker: true)
        reduceBGMVolume()
        context.gameFlowMode = .shadowing
        context.gameState = .stopped
        context.gameRecord?.startedTime = Date()
        gameSeconds = 0
        prepareTimer()
        context.loadLearningSentences()

        meijia("每句日文說完後，請跟著說～").always {
            self.learnNext()
        }

        isPaused = false
        wait.fulfill(())
    }

    func pause() {
        wait = Promise<Void>.pending()
        isPaused = true
    }

    func resume() {
        isPaused = false
        wait.fulfill(())
    }

    // MARK: - Private Functions
    private func learnNext() {
        speakTargetString()
        .then { self.wait }
        .then( listenPart )
        .then { self.wait }
        .catch { error in print("Promise chain 死了。", error)}
        .always {
            context.gameState = .sentenceSessionEnded
            if context.nextSentence() && context.isEngineRunning {
                self.learnNext()
            } else {
                self.gameOver()
            }
        }
    }

    private func listenPart() -> Promise<Void> {
        return listen()
            .then(getScore)
            .then(speakScore)
    }

    // change life will change the teachingSpeed
    // initial life = 40, speed = 0.7x
    // life 100 => speed 1.0x
    // life 0   => speed 0.5x
    // 25句 Rank A 達成度90% => missed x 1, good x3, great x 9, perfect x 12 => life = 100, last speed 1.00x
    //      Rank B 達程度80% => missed x 2, good x6, great x 7, perfect x 10 => life = 82,  last speed 0.91x
    //      Rank C 達程度70% => missed x 3, good x9, great x 6, perfect x 7  => life = 62,  last speed 0.81x

    private func updateLife(score: Score) {
        var life = context.life

        switch score.type {
        case .perfect:
            life += 4
        case .great:
            life += 2
        case .good:
            life += -1
        default:
            life += -3
        }

        context.life = max(min(100, life), 0)

        postEvent(.lifeChanged, int: context.life)
    }

    private func speakScore() -> Promise<Void> {
        context.gameState = .scoreCalculated
        let score = context.score
        updateLife(score: score)

        return oren(score.text, rate: normalRate)
    }
}
