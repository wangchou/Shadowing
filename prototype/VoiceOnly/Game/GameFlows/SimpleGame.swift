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

class SimpleGame: Game {
    static let shared = SimpleGame()
    private var isPaused: Bool = false
    private var wait: Promise<Void> = Promise<Void>.pending()
    private var startTime: Double = 0
    private var gameSeconds: Int = 0
    private var timer: Timer?

    var state: GameState = .stopped {
        didSet {
            postEvent(.gameStateChanged, gameState: state)
        }
    }

    func play() {
        startEngine(toSpeaker: true)
        gameSeconds = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if self.isPaused { return }

            postEvent(.playTimeUpdate, int: self.gameSeconds)
            self.gameSeconds += 1
        }
        context.loadLearningSentences()
        meijia("每次日文說完後，請跟著說～").always {
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

    func stop() {
        state = .stopped
        timer?.invalidate()
        stopEngine()
    }

    private func learnNext() {
        speakJapanese()
        .then { self.wait }
        .then(listen)
        .then(getScore)
        .then(speakScore)
        .then { self.wait }
        .catch { error in print("Promise chain 死了。", error)}
        .always {
            self.state = .sentenceSessionEnded
            if context.nextSentence() && context.isEngineRunning {
                self.learnNext()
            } else {
                guard let record = context.gameRecord else { return }
                self.state = .gameOver

                meijia("遊戲結束").then {_ in
                    self.state = .mainScreen
                }

                if let previousRecord = context.gameHistory[record.dataSetKey],
                    record.p <= previousRecord.p &&
                    record.rank != "SS" {
                    return
                }

                context.gameHistory[record.dataSetKey] = record
                saveGameHistory()
            }
        }
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

    private func getScore(userSaidString: String) -> Promise<Int> {
        self.state = .stringRecognized
        return calculateScore(context.targetString, userSaidString)
    }

    // change life will change the teachingSpeed
    // initial life = 40, speed = 0.7x
    // life 100 => speed 1.0x
    // life 0   => speed 0.5x
    // 25句 Rank A 達成度90% => missed x 1, good x3, great x 9, perfect x 12 => life = 100, last speed 1.00x
    //      Rank B 達程度80% => missed x 2, good x6, great x 7, perfect x 10 => life = 82,  last speed 0.91x
    //      Rank C 達程度70% => missed x 3, good x9, great x 6, perfect x 7  => life = 62,  last speed 0.81x

    private func updateLife(score: Int) {
        var life = context.life

        switch score {
        case 100:
            life += 4
        case 80...99:
            life += 2
        case 60...79:
            life += -1
        default:
            life += -3
        }

        context.life = max(min(100, life), 0)

        postEvent(.lifeChanged, int: context.life)
    }

    private func speakScore(score: Int) -> Promise<Void> {
        self.state = .scoreCalculated

        updateLife(score: score)

        var text = ""
        context.gameRecord?.sentencesScore[context.targetString] = score

        switch score {
        case 100:
            context.gameRecord?.perfectCount += 1
            text = "正解"
        case 80...99:
            context.gameRecord?.greatCount += 1
            text = "すごい"
        case 60...79:
            context.gameRecord?.goodCount += 1
            text = "いいね"
        default:
            text = "違うよ"
        }

        return oren(text, rate: normalRate)
    }
}
