//
//  P1ViewController.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/04/24.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit
import Speech


fileprivate let listenPauseDuration = 0.4

// Prototype 1: 一個 run 10.9秒
// Loop {
//  説(請跟我說日文)
//  日文
//  複述
//  説(我聽到你說)
//  辨識出的 TTS
//  分數
// }

class P1ViewController: UIViewController {
    let cmd = Commands.shared
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        cmd.startEngine()
        repeatAfterMe()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cmd.stopEngine()
    }
    
    // MARK: - cmd Control
    func repeatAfterMe() {
        cmdQueue.async {
            print("----------------------------------")
            let cmd = Commands.shared
            let sentence = sentences[sentenceIndex]
            cmd.say(REPEAT_AFTER_ME_HINT, assistant)
            let speakTime = getNow()
            cmd.say(sentence, teacher, rate: teachingRate)
            cmd.listen(
                listenDuration: (getNow() - speakTime) + listenPauseDuration,
                resultHandler: self.speechResultHandler
            )
        }
    }
    
    func iHearYouSaid(_ saidSentence: String) {
        cmdQueue.async {
            let cmd = Commands.shared
            print("hear <<< \(saidSentence)")
            cmd.say(I_HEAR_YOU_HINT, assistant)
            cmd.say(saidSentence, Oren, rate: teachingRate)
            let score = getSpeechScore(sentences[sentenceIndex], saidSentence)
            sentenceIndex = (sentenceIndex + 1) % sentences.count
            cmd.say(String(score)+"分", assistant)
            self.repeatAfterMe()
        }
    }
    
    func speechResultHandler(result: SFSpeechRecognitionResult?, error: Error?) {
        let cmd = Commands.shared
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
                    cmd.say(CANNOT_HEAR_HINT, assistant)
                    self.repeatAfterMe()
                }
            }
        }
    }
}
