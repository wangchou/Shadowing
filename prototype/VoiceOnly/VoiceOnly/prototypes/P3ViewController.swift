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

fileprivate let listenPauseDuration = 0.25

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
        printDuration()
        setStartTime()
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
        let audio = AudioController.shared
        print("hear <<< \(saidSentence)")
        
        // completionHandler chain
        let targetSentence = sentences[sentenceIndex]
        getSpeechScore(targetSentence, saidSentence)
        {   sentenceIndex = (sentenceIndex + 1) % sentences.count
            audio.say(String($0)+"分", assistant)
        {   self.repeatAfterMe()
        }}
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
