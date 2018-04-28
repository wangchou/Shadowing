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

// Prototype 4: 一個 run 4.2秒
// Loop {
//  日文
//  使用者複述 (分數 & 結果之後 show 在畫面上)
// }

class P4ViewController: UIViewController {
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
        
        // completionHandler chain
        let speakTime = getNow()
        audio.say(sentence, teacher, rate: teachingRate)
        {   audio.listen(
                listenDuration: (getNow() - speakTime) + listenPauseDuration,
                resultHandler: self.speechResultHandler
            )
        }
    }
    
    func iHearYouSaid(_ saidSentence: String) {
        print("hear <<< \(saidSentence)")
        
        // completionHandler chain
        let targetSentence = sentences[sentenceIndex]
        sentenceIndex = (sentenceIndex + 1) % sentences.count
        getSpeechScore(targetSentence, saidSentence)
        {
            print(String($0)+"分")
        }
        repeatAfterMe()
    }
    
    func speechResultHandler(result: SFSpeechRecognitionResult?, error: Error?) {
        let audio = AudioController.shared
        if !audio.isRunning {
            return
        }
        
        if (result?.isFinal) != nil {
            iHearYouSaid(result!.bestTranscription.formattedString)
        }
        
        if error != nil {
            if(isDev) {
                iHearYouSaid("おねさま")
            } else {
                audio.say(CANNOT_HEAR_HINT, assistant) {
                    self.repeatAfterMe()
                }
            }
        }
    }
}
