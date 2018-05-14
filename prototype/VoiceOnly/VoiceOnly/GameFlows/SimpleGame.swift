//
//  FlowController1.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/04.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import Promises

fileprivate let pauseDuration = 0.4
fileprivate let context = GameContext.shared

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
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
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
            if(context.nextSentence() && context.isEngineRunning) {
                self.learnNext()
            } else {
                let record = context.gameRecord!
                if let previousRecord = context.gameHistory[record.dataSetKey],
                    record.p <= previousRecord.p &&
                    record.rank != "SS" {
                    return
                }
                
                context.gameHistory[record.dataSetKey] = record
                saveGameHistory()
                self.state = .gameOver
                
                meijia("遊戲結束").then {_ in
                    self.state = .mainScreen
                }
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
    
    private func speakScore(score: Int) -> Promise<Void> {
        self.state = .scoreCalculated
        
        // change life will change the teachingSpeed
        // life 100 => 1.0x
        // life 0 => 0.5x
        var text = ""
        var life = context.life
        
        context.gameRecord?.sentencesScore[context.targetString] = score
        
        switch score {
        case 100:
            life += 5
            context.gameRecord?.perfectCount += 1
            text = "正解"
        case 80...99:
            life += 2
            context.gameRecord?.greatCount += 1
            text = "すごい"
        case 60...79:
            life += -5
            context.gameRecord?.goodCount += 1
            text = "いいね"
        default:
            life += -10
            text = "違うよ"
        }
        
        context.life = max(min(100, life), 0)
        
        postEvent(.lifeChanged, int: context.life)
        
        return oren(text, rate: normalRate)
    }
}
