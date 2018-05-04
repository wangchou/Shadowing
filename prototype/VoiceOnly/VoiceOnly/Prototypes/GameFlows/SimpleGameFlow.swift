//
//  FlowController1.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/04.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation

fileprivate let pauseDuration = 0.4
fileprivate let context = CommandContext.shared

class SimpleGameFlow: GameFlow {
    static let shared = SimpleGameFlow()
    
    func play() {
        startEngine(toSpeaker: false)
        context.isDev = true
        context.loadLearningSentences(sentences)
        learnNext()
    }
    
    private func learnNext() {
        cmdQueue.async {
            let targetString = context.targetString
            hattori(targetString)
            let userSaidString = listen(duration: context.speakDuration + pauseDuration)
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
