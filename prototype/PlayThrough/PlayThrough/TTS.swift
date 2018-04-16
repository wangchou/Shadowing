//
//  TTS.swift (Text to Speech)
//  PlayThrough
//
//  Created by Wangchou Lu on H30/04/16.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import AVFoundation

class TTS: NSObject, AVSpeechSynthesizerDelegate {
    var speechSynthesizer: AVSpeechSynthesizer = AVSpeechSynthesizer()
    
    func speak(
        _ text: String,
        _ name: String
        ) {
        speechSynthesizer.delegate = self
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(identifier: name)
        speechSynthesizer.speak(utterance)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                           willSpeakRangeOfSpeechString characterRange: NSRange,
                           utterance: AVSpeechUtterance) {
        //print(characterRange, utterance)
    }
}
