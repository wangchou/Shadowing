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

typealias gg = Promise<Void>

class VoiceOnlyFlow: GameFlow {
    static let shared = VoiceOnlyFlow()
    var userSaidString: String = ""
    var targetString: String = ""
    var score: Int = 0
    
    var state: GameState = .stopped {
        didSet {
            postEvent(.gameStateChanged, state)
        }
    }
    
    func play() {
        startEngine(toSpeaker: false)
        context.isDev = true
        context.loadLearningSentences(allSentences)
        learnNext()
    }
    
    private func learnNext() {
        targetString = context.targetString
        var startTime: Double = 0
        meijia("請跟著唸日文").then { ()-> Promise<Void> in
            self.state = .speakingJapanese
            startTime = getNow()
            return hattori(self.targetString)
        }.then { ()-> Promise<String> in
            self.state = .listening
            let speakDuration = getNow() - startTime
            return listenJP(duration: (speakDuration + pauseDuration))
        }.then { userSaidString -> Promise<Void> in
            self.userSaidString = userSaidString
            self.state = .stringRecognized
            return meijia("我聽到你說")
        }.then {
            oren(self.userSaidString)
        }.then {
            calculateScore(self.targetString, self.userSaidString)
        }.then { score -> Promise<Void> in
            self.state = .scoreCalculated
            return meijia("\(score)分")
        }.then {
            if(context.nextSentence()) {
                self.learnNext()
            }
        }.catch { error in
            print("error ... \(error)")
        }
    }
    
    func stop() {
        stopEngine()
    }
}
