//
//  ChatGame.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 9/6/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation

import Foundation
import Promises

private let context = GameContext.shared

class ChatFlow: Game {
    static let shared = ChatFlow()

    // MARK: - Public Functions
    override func start() {
        context.gameFlowMode = .chat
        context.gameState = .stopped
        context.gameRecord?.startedTime = Date()
        gameSeconds = 0
        startTimer()
        context.loadChatDemoSentences()
        meijia("模擬會話，等下請念框框裡的日文。").always {
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
        speakPart()
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

    private func speakPart() -> Promise<Void> {
        if context.isTargetSentencePlayedByUser {
            return fulfilledVoidPromise()
        }
        return pausePromise(0.3)
            .then(speakTargetString)
    }

    private func listenPart() -> Promise<Void> {
        if context.isTargetSentencePlayedByUser {
            return listen()
                .then(getScore)
                .then({ () -> Promise<Void> in

                    if context.userSaidString == "" {
                        return hattori("聞こえない")
                            .then({ context.score.value = 100 })
                    }
                    if context.score.value < 80 {
                        return hattori("もう一度お願いします")
                            .then({ context.score.value = 100 })
                    }
                    return fulfilledVoidPromise()
                })
        }

        return fulfilledVoidPromise()
    }
}
