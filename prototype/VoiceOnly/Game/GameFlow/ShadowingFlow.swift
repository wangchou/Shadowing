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
        context.gameFlowMode = .shadowing
        context.gameState = .stopped
        context.gameRecord?.startedTime = Date()
        gameSeconds = 0
        startTimer()
        context.loadLearningSentences()
        var narratorString = "我說完後，請跟著我說～"
        if !context.gameSetting.isUsingGuideVoice {
            narratorString = "請唸出對應的日文。"
        }
        narratorSay(narratorString).always {
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
        .catch { error in print("Promise chain is dead", error)}
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
            life += -3
        case .poor:
            life += -5
        }

        context.life = max(min(100, life), 0)

        postEvent(.lifeChanged, int: context.life)
    }

    private func speakScore() -> Promise<Void> {
        context.gameState = .scoreCalculated
        let score = context.score
        updateLife(score: score)

        return assisantSay(score.text)
    }
}
