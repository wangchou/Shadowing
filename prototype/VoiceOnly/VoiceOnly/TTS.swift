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
    var onCompleteHandler: (() -> Void)? = nil
    
    func say(
        _ text: String,
        _ name: String,
        rate: Float = AVSpeechUtteranceDefaultSpeechRate, // 0.5, range 0 ~ 1.0
        onCompleteHandler: @escaping () -> Void = {}
    ) {
        synthesizer.delegate = self
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(identifier: name)
        utterance.rate = rate
        
        self.onCompleteHandler = onCompleteHandler
        synthesizer.speak(utterance)
    }
    
    func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didFinish utterance: AVSpeechUtterance
    ) {
        print("saying >>>", "\(utterance.speechString)")
        guard let onCompleteHandler = onCompleteHandler else { return }
        onCompleteHandler()
    }
}
