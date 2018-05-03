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
fileprivate var saidSentence = ""
fileprivate var targetSentence = sentences[sentenceIndex]
// Prototype 1: 全語音、只能用講電話的方式
class P1ViewController: UIViewController {
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        startEngine(toSpeaker: false)
        sentenceIndex = 0
        targetSentence = sentences[sentenceIndex]
        learnNextSentence()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopEngine()
    }
    
    // MARK: - cmd Control
    func learnNextSentence() {
        cmdQueue.async {
            print("----------------------------------")
            // step 1
            meijia(REPEAT_AFTER_ME_HINT)
            
            // step 2
            let speakTime = getNow()
            hattori(targetSentence, delegate: nil)
            
            // step 3
            reduceBGMVolume()
            
            // step 4
            listen(
                listenDuration: (getNow() - speakTime) + listenPauseDuration,
                resultHandler: self.speechResultHandler
            )
            
            // step 5
            restoreBGMVolume()
            
            if(saidSentence == "") {
                // step 6.1
                meijia(CANNOT_HEAR_HINT)
                self.learnNextSentence()
            } else {
                print("使用者 👨: \(saidSentence)")
                
                // step 6.2
                meijia(I_HEAR_YOU_HINT)
                
                // step 6.2.1
                oren(saidSentence)
                
                // step 6.2.2
                let score = getSpeechScore(targetSentence, saidSentence)
                
                // step 6.2.3
                meijia("\(score)分")
                sentenceIndex = sentenceIndex + 1
                if(sentenceIndex == sentences.count) {
                    return
                }
                targetSentence = sentences[sentenceIndex]
                self.learnNextSentence()
            }
        }
    }
    
    func speechResultHandler(result: SFSpeechRecognitionResult?, error: Error?) {
        if !cmd.isEngineRunning {
            return
        }
        
        if let result = result, result.isFinal {
            saidSentence = result.bestTranscription.formattedString
            cmdGroup.leave()
        }
        
        if error != nil {
            saidSentence = isDev ? "おねさま" : ""
            cmdGroup.leave()
        }
        
    }
}
