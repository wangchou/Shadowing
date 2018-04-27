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

class FlowController {
    
    //Singleton
    static let shared = FlowController()

    private init() {}
    
    func repeatAfterMe() {
        let audio = AudioController.shared
        print("repeat after me", audio)
        
        // completionHandler chain
        audio.say(REPEAT_AFTER_ME_HINT, assistant)
        {   let sentence = sentences[sentenceIndex]
            let listeningDuration: Double = Double((Float(sentence.count) * 0.6 * teachingRate) + 1.5)
            audio.say(sentence, teacher, rate: teachingRate)
        {   audio.speechRecognizer.start(
                inputNode: audio.engine.inputNode,
                stopAfterSeconds: listeningDuration,
                resultHandler: self.speechResultHandler
            )
        }}
    }
    
    // do these concurrently
    // 1. replay recording
    // 2. getScore from server kana str
    // 3. play recognition result in tts
    private func repeatSaid(_ saidSentence: String, completionHandler: @escaping (Int)->Void) {
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
        {   self.repeatSaid(saidSentence)
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
            audio.say(CANNOT_HEAR_HINT, assistant) {
                self.repeatAfterMe()
            }
        }
    }
}
