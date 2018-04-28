//
//  TTS.swift (Text to Speech)
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/04/16.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import AVFoundation

class TTS: NSObject, AVSpeechSynthesizerDelegate {
    var synthesizer: AVSpeechSynthesizer = AVSpeechSynthesizer()
    var completionHandler: (() -> Void)? = nil
    
    func say(
        _ text: String,
        _ name: String,
        rate: Float = AVSpeechUtteranceDefaultSpeechRate, // 0.5, range 0 ~ 1.0
        delegate: AVSpeechSynthesizerDelegate? = nil,
        completionHandler: @escaping () -> Void = {}
    ) {
        if delegate != nil {
            synthesizer.delegate = delegate
        } else {
            synthesizer.delegate = self
        }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(identifier: name)
        utterance.rate = rate
        
        self.completionHandler = completionHandler
        synthesizer.speak(utterance)
    }
    
    func stop() {
        synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                           willSpeakRangeOfSpeechString characterRange: NSRange,
                           utterance: AVSpeechUtterance) {
        let speechString = utterance.speechString as NSString
        print(speechString.substring(with: characterRange), terminator: "")
    }
    
    func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didFinish utterance: AVSpeechUtterance
    ) {
        guard let completionHandler = completionHandler else { return }
        print("")
        completionHandler()
    }
}
