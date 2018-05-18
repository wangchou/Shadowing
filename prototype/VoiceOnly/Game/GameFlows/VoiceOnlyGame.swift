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

    var state: GameState = .stopped {
        didSet {
            postEvent(.gameStateChanged, gameState: state)
        }
    }

    func play() {
        startEngine(toSpeaker: false)
        context.loadLearningSentences()
        learnNext()
    }

    func stop() {
        stopEngine()
    }

    private func learnNext() {
        speakHint()
        .then(speakJapanese)
        .then(listen)
        .then(iHearYouSaid)
        .then(getScore)
        .then(speakScore)
        .catch { error in
            print("error ... \(error)")
        }.always {
            if context.nextSentence() {
                self.learnNext()
            }
        }
    }

    private func speakHint() -> Promise<Void> {
        return meijia("請跟著唸日文")
    }

    private func speakJapanese() -> Promise<Void> {
        self.state = .speakingJapanese
        self.startTime = getNow()
        return hattori(context.targetString)
    }

    private func listen() -> Promise<String> {
        self.state = .listening
        let speakDuration = getNow() - self.startTime
        return listenJP(duration: speakDuration + pauseDuration)
    }

    private func iHearYouSaid(userSaidString: String) -> Promise<Void> {
        self.state = .stringRecognized
        context.userSaidString = userSaidString
        return meijia("我聽到你說")
            .then { oren(userSaidString) }
    }

    private func getScore() -> Promise<Int> {
        return calculateScore(context.targetString, context.userSaidString)
    }

    private func speakScore(score: Int) -> Promise<Void> {
        self.state = .scoreCalculated
        return meijia("\(score)分")
    }
}
