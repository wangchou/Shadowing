//
//  TTS.swift (Text to Speech)
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/04/16.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import AVFoundation

class TTS {
    var synthesizer: AVSpeechSynthesizer = AVSpeechSynthesizer()
    var completionHandler: (() -> Void)? = nil
    
    func say(
        _ text: String,
        _ name: String,
        rate: Float = AVSpeechUtteranceDefaultSpeechRate, // 0.5, range 0 ~ 1.0
        delegate: AVSpeechSynthesizerDelegate? = nil,
        completionHandler: @escaping () -> Void = {}
    ) {
        synthesizer.delegate = delegate
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(identifier: name)
        utterance.rate = rate
        
        self.completionHandler = completionHandler
        synthesizer.speak(utterance)
    }
    
    func stop() {
        synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
    }
}
