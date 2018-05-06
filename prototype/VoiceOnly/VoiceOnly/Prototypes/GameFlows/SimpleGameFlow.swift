//
//  FlowController1.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/04.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation

fileprivate let pauseDuration = 0.4
fileprivate let context = GameContext.shared

class SimpleGameFlow: GameFlow {
    static let shared = SimpleGameFlow()
    
    var state: GameState = .stopped {
        didSet {
            postEvent(.gameStateChanged, state)
        }
    }
    
    func play() {
        startEngine(toSpeaker: true)
        context.isDev = false
        context.loadLearningSentences(sentences)
        learnNext()
    }
    
    private func learnNext() {
        cmdQueue.async {
            let targetString = context.targetString
            
            self.state = .speakingJapanese
            hattori(targetString)
            
            self.state = .listening
            let userSaidString = listen(duration: context.speakDuration + pauseDuration)
            
            self.state = .stringRecognized
            let score = calculateScore(targetString, userSaidString)
            
            self.state = .scoreCalculated
            meijia("\(score)分")
            
            self.state = .sentenceSessionEnded
            if(context.nextSentence()) {
                self.learnNext()
            }
        }
    }
    
    func stop() {
        stopEngine()
    }
}
