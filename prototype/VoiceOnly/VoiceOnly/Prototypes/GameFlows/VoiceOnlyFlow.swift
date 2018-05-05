//
//  FlowController1.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/04.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation

enum GameState {
    case stopped
    case speakingJapanese
    case listening
    case stringRecognized
    case repeatingWhatSaid
    case scoreCalculated
    case speakingScore
}

protocol GameFlow {
    var state: GameState { get set}
    func play()
    func stop()
}

fileprivate let pauseDuration = 0.4
fileprivate let context = CommandContext.shared

class VoiceOnlyFlow: GameFlow {
    var state: GameState = .stopped {
        didSet {
            postEvent(.gameStateChanged, state)
        }
    }
    
    static let shared = VoiceOnlyFlow()
    
    func play() {
        startEngine(toSpeaker: false)
        context.isDev = true
        context.loadLearningSentences(sentences)
        learnNext()
    }
    
    private func learnNext() {
        cmdQueue.async {
            let targetString = context.targetString
            meijia("請跟著唸日文")
            
            self.state = .speakingJapanese
            hattori(targetString)
            
            self.state = .listening
            let userSaidString = listen(duration: context.speakDuration + pauseDuration)
            
            self.state = .stringRecognized
            if(userSaidString == "") {
                meijia("聽不清楚、再一次。")
                self.learnNext()
                return
            }
            
            self.state = .repeatingWhatSaid
            meijia("我聽到你說")
            oren(userSaidString)
            
            self.state = .scoreCalculated
            let score = calculateScore(targetString, userSaidString)
            
            self.state = .speakingScore
            meijia("\(score)分")
            if(context.nextSentence()) {
                self.learnNext()
            }
        }
    }
    
    func stop() {
        stopEngine()
    }
}
