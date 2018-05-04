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

fileprivate let listenPauseDuration = 0.4
fileprivate let context = Commands.shared

class TalkingPhoneFlow: GameFlow {
    static let shared = TalkingPhoneFlow()
    
    func play() {
        startEngine(toSpeaker: false)
        context.isDev = true
        context.loadLearningSentences(sentences)
        learnNext()
    }
    
    private func learnNext() {
        cmdQueue.async {
            print("----------------------------------")
            let targetSentence = context.targetSentence
            meijia(REPEAT_AFTER_ME_HINT)
            let speakTime = getNow()
            hattori(targetSentence, delegate: nil)
            let saidSentence = listen(listenDuration: (getNow() - speakTime) + listenPauseDuration)
            
            if(saidSentence == "") {
                meijia(CANNOT_HEAR_HINT)
                self.learnNext()
            } else {
                meijia(I_HEAR_YOU_HINT)
                oren(saidSentence)
                let score = getSpeechScore(targetSentence, saidSentence)
                meijia("\(score)分")
                if(context.nextSentence()) {
                    self.learnNext()
                }
            }
        }
    }
    
    func stop() {
        stopEngine()
    }
}
