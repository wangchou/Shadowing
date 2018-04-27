//
//  FlowController.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/04/26.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import AVFoundation
import Speech

var isDev = true
let listenPauseDuration = 0.25

class FlowController {
    
    //Singleton
    static let shared = FlowController()

    private init() {}
    
    func repeatAfterMe() {
        let audio = AudioController.shared
        
        // completionHandler chain
        audio.say(REPEAT_AFTER_ME_HINT, assistant)
        {   let sentence = sentences[sentenceIndex]
            let startTime = NSDate().timeIntervalSince1970
            audio.say(sentence, teacher, rate: teachingRate)
        {   let listenDuration = (NSDate().timeIntervalSince1970 - startTime) +
                                 listenPauseDuration
            audio.speechRecognizer.start(
                inputNode: audio.engine.inputNode,
                stopAfterSeconds: listenDuration,
                resultHandler: self.speechResultHandler
            )
        }}
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
        audio.replay() { group.leave() }
        
        group.enter()
        audio.say(saidSentence, Oren, rate: teachingRate * replayRate) { group.leave() }
        
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
        print("\nhear <<< \(saidSentence)\n")
        
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
