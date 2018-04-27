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

// Prototype 5: 一個 run 5.5秒，但 辨識出 TTS 的日文，會讓人混亂。
// Loop {
//  日文
//  使用者複述
//  辨識出的 TTS
// }

class P5ViewController: UIViewController {
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
    
    // do these concurrently
    // 1. replay recording
    // 2. getScore from server kana str
    // 3. play recognition result in tts
    private func repeatWhatSaid(_ saidSentence: String, completionHandler: @escaping (Int)->Void) {
        let audio = AudioController.shared
        var speechScore: Int = 0
        let group = DispatchGroup()
        
        group.enter()
        audio.say(saidSentence, Oren, rate: teachingRate * replayRate) { group.leave() }
        
        let targetSentence = sentences[sentenceIndex]
        getSpeechScore(targetSentence, saidSentence) {
            speechScore = $0
        }
        
        group.notify(queue: .main) {
            completionHandler(speechScore)
        }
    }
    
    func iHearYouSaid(_ saidSentence: String) {
        print("hear <<< \(saidSentence)")
        
        // completionHandler chain
        repeatWhatSaid(saidSentence) { score in
            sentenceIndex = (sentenceIndex + 1) % sentences.count
            self.repeatAfterMe()
        }
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
