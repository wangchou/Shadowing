//
//  FlowController1.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/04.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation

protocol GameFlow {
    func play()
    func stop()
}

fileprivate let pauseDuration = 0.4
fileprivate let context = CommandContext.shared

class VoiceOnlyFlow: GameFlow {
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
            hattori(targetString)
            let userSaidString = listen(duration: context.speakDuration + pauseDuration)
            
            if(userSaidString == "") {
                meijia("聽不清楚、再一次。")
                self.learnNext()
                return
            }
            
            meijia("我聽到你說")
            oren(userSaidString)
            let score = calculateScore(targetString, userSaidString)
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
