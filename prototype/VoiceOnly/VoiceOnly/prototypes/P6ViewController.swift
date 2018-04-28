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

// Prototype 6: 一個 run 8.9秒
// Loop {
//  日文
//  使用者複述
//  説(我聽到你說)
//  辨識出的 TTS
//  分數
// }

class P6ViewController: UIViewController {
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
    
    private func repeatWhatSaid(_ saidSentence: String, completionHandler: @escaping (Int)->Void) {
        let audio = AudioController.shared
        var speechScore: Int = 0
        let group = DispatchGroup()
        
        group.enter()
        audio.say(saidSentence, Oren, rate: teachingRate) { group.leave() }
        
        group.enter()
        let targetSentence = sentences[sentenceIndex]
        getSpeechScore(targetSentence, saidSentence) {
            speechScore = $0
            group.leave()
        }
        
        group.notify(queue: .main) {
            completionHandler(speechScore)
        }
    }
    
    func iHearYouSaid(_ saidSentence: String) {
        let audio = AudioController.shared
        print("hear <<< \(saidSentence)")
        
        // completionHandler chain
        audio.say(I_HEAR_YOU_HINT, assistant)
        {   self.repeatWhatSaid(saidSentence)
        {   sentenceIndex = (sentenceIndex + 1) % sentences.count
            audio.say(String($0)+"分", assistant)
        {   self.repeatAfterMe()
        }}}
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
                audio.say(CANNOT_HEAR_HINT, assistant) {
                    self.repeatAfterMe()
                }
            }
        }
    }
}
