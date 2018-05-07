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
        context.loadLearningSentences(allSentences)
        learnNext()
    }
    
    private func learnNext() {
        let targetString = context.targetString
        let startTime = getNow()
        self.state = .speakingJapanese
        
        hattori(targetString).then { () -> Promise<String> in
            self.state = .listening
            let speakDuration = getNow() - startTime
            return listenJP(duration: speakDuration + pauseDuration)
        }.then { userSaidString -> Promise<Int> in
            self.state = .stringRecognized
            return calculateScore(targetString, userSaidString)
        }.then { score -> Promise<Void> in
            self.state = .scoreCalculated
            return meijia("\(score)分")
        }.then {
            self.state = .sentenceSessionEnded
            if(context.nextSentence()) {
                self.learnNext()
            }
        }.catch { error in
            print("Promise chain 死了。", error)
        }
    }
    
    func stop() {
        stopEngine()
    }
}
