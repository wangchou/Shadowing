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
    private var startTime: Double = 0
    
    var state: GameState = .stopped {
        didSet {
            postEvent(.gameStateChanged, gameState: state)
        }
    }
    
    func play() {
        startEngine(toSpeaker: true)
        
        let index: Int = Int(arc4random_uniform(UInt32(allSentences.count)))
        let randomSentences = Array(allSentences.values)[index]
        context.loadLearningSentences(randomSentences)
        meijia("每次日文說完後，請跟著說～").always {
            self.learnNext()
        }
    }
    
    func stop() {
        state = .stopped
        stopEngine()
    }
    
    private func learnNext() {
        speakJapanese()
        .then(listen)
        .then(getScore)
        .then(speakScore)
        .catch { error in print("Promise chain 死了。", error)}
        .always {
            self.state = .sentenceSessionEnded
            if(context.nextSentence() && context.isEngineRunning) {
                self.learnNext()
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
        if score == 100 {
            context.life = context.life + 10
        } else if score >= 80 {
            context.life = context.life + 5
        } else if score >= 60 {
            context.life = context.life + 2
        } else {
            context.life = context.life - 10
        }
        
        if context.life > 100 {
            context.life = 100
        }
        if context.life < 0 {
            context.life = 0
        }
        
        return meijia("\(score)分")
    }
}
