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

// Prototype 3: 一個 run 5.6秒
// Loop {
//  日文
//  使用者複述
//  分數
// }

class P3ViewController: UIViewController {
    let audio = AudioController.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        audio.start()
        repeatAfterMe()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        audio.stop()
    }
    
    func repeatAfterMe() {
        print("----------------------------------")
        let audio = AudioController.shared
        let sentence = sentences[sentenceIndex]
        
        // async/await
        myQueue.async {
            let speakTime = getNow()
            audio.say(sentence, teacher, rate: teachingRate)
            audio.listen(
                listenDuration: (getNow() - speakTime) + listenPauseDuration,
                resultHandler: self.speechResultHandler
            )
        }
    }
    
    func iHearYouSaid(_ saidSentence: String) {
        let audio = AudioController.shared
        print("hear <<< \(saidSentence)")
        
        myQueue.async {
            audio.say(I_HEAR_YOU_HINT, assistant)
            let score = getSpeechScore(sentences[sentenceIndex], saidSentence)
            sentenceIndex = (sentenceIndex + 1) % sentences.count
            audio.say(String(score)+"分", assistant)
            self.repeatAfterMe()
        }
    }
    
    func speechResultHandler(result: SFSpeechRecognitionResult?, error: Error?) {
        let audio = AudioController.shared
        if !audio.isRunning {
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
                myQueue.async {
                    audio.say(CANNOT_HEAR_HINT, assistant)
                    self.repeatAfterMe()
                }
            }
        }
    }
}
