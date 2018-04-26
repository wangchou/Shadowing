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
        audio.say(REPEAT_AFTER_ME_HINT, assistant) {
            let sentence = sentences[sentenceIndex]
            let listeningDuration: Double = Double((Float(sentence.count) * 0.6 * teachingRate) + 1.5)
            audio.say(sentence, teacher, rate: teachingRate) {
                audio.speechRecognizer.start(
                    inputNode: audio.engine.inputNode,
                    stopAfterSeconds: listeningDuration,
                    resultHandler: self.speechResultHandler
                )
            }
        }
    }
    
    func iHearYouSaid(_ saidString: String) {
        let audio = AudioController.shared
        let targetSentence = sentences[sentenceIndex]
        var speechScore: Int = 0
        var isGotScore = false
        getSpeechScore(targetSentence, saidString) { score in
            isGotScore = true
            speechScore = score
        }
        
        sentenceIndex = (sentenceIndex + 1) % sentences.count
        
        print("\nhear <<< \(saidString)\n")
        audio.say(I_HEAR_YOU_HINT, assistant) {
            var isReplayUnitComplete = false
            var isTTSSpeakComplete = false
            
            audio.replay() {
                isReplayUnitComplete = true
                if(isTTSSpeakComplete) {
                    self.repeatAfterMe()
                }
            }
            
            audio.say(saidString, Oren, rate: teachingRate * replayRate) {
                while !isGotScore {
                    usleep(10000) // 10 ms, ps: will block ui thread
                }
                audio.say(String(speechScore)+"分", assistant) {
                    isTTSSpeakComplete = true
                    if(isReplayUnitComplete) {
                        self.repeatAfterMe()
                    }
                }
                
            }
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
            audio.say(CANNOT_HEAR_HINT, assistant) {
                self.repeatAfterMe()
            }
        }
    }
}
