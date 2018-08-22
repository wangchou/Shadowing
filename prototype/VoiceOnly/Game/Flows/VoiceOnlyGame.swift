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
            } else {
                meijia("遊戲結束").then {
                    self.state = .gameOver
                    self.stop()
                }
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

    private func getScore() -> Promise<Score> {
        return calculateScore(context.targetString, context.userSaidString)
    }

    private func speakScore(score: Score) -> Promise<Void> {
        self.state = .scoreCalculated
        updateRecord(score: score)
        return meijia(score.valueText)
    }
}
