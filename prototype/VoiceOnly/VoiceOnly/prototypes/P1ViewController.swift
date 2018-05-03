//
//  P1ViewController.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/04/24.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import Speech

fileprivate let isDev = false

fileprivate let listenPauseDuration = 0.4

fileprivate let cmd = Commands.shared

fileprivate var targetSentence = sentences[sentenceIndex]

class P1ViewController: UIViewController {
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        startEngine(toSpeaker: false)
        repeatAfterMe() 
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopEngine()
    }
    
    func nextSentence() {
        sentenceIndex = (sentenceIndex + 1) % sentences.count
        targetSentence = sentences[sentenceIndex]
    }
    
    // MARK: - cmd Control
    func repeatAfterMe() {
        print("----------------------------------")
        cmdQueue.async {
            meijia(REPEAT_AFTER_ME_HINT)
            let speakTime = getNow()
            hattori(targetSentence)
            listen(
                listenDuration: (getNow() - speakTime) + listenPauseDuration,
                resultHandler: self.speechResultHandler
            )
        }
    }
    
    func iHearYouSaid(_ saidSentence: String) {
        print("使用者 👨: \(saidSentence)")
        cmdQueue.async {
            meijia(I_HEAR_YOU_HINT)
            oren(saidSentence)
            let score = getSpeechScore(targetSentence, saidSentence)
            self.nextSentence()
            meijia("\(score)分")
            self.repeatAfterMe()
        }
    }
    
    func speechResultHandler(result: SFSpeechRecognitionResult?, error: Error?) {
        if !cmd.isEngineRunning {
            return
        }
        
        if let result = result {
            if result.isFinal {
                iHearYouSaid(result.bestTranscription.formattedString)
            }
        }
        
        if error != nil {
            if(isDev) {
                iHearYouSaid("おねさま")
            } else {
                cmdQueue.async {
                    meijia(CANNOT_HEAR_HINT)
                    self.repeatAfterMe()
                }
            }
        }
        
    }
}
