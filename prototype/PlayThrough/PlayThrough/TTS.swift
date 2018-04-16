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
    var synthesizer: AVSpeechSynthesizer = AVSpeechSynthesizer()
    var onCompleteHandler: (() -> Void)? = nil
    
    // only for real device, not for simulator
    func useLeftChannel() {
        let session = AVAudioSession.sharedInstance()
        let outputs = session.currentRoute.outputs
        if outputs.count == 0 {
            print("unable to set sythesizer to left channel only (simulator is not supported)")
            return
        }
        let leftChannel = outputs[0].channels?[0]
        synthesizer.outputChannels = [leftChannel] as? [AVAudioSessionChannelDescription]
    }
    
    func speak(
        _ text: String,
        _ name: String,
        volume: Float = 0.5,
        leftChannelOnly: Bool = false,
        onCompleteHandler: @escaping () -> Void = {}
        ) {
        if(leftChannelOnly) {
            useLeftChannel()
        }
        synthesizer.delegate = self
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(identifier: name)
        utterance.volume = volume
        
        self.onCompleteHandler = onCompleteHandler
        synthesizer.speak(utterance)
    }
    
    override init() {
        super.init()
        // dumpVoices()
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                           didFinish utterance: AVSpeechUtterance) {
        print("\(utterance.speechString) is said")
        guard let onCompleteHandler = onCompleteHandler else { return }
        onCompleteHandler()
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                           willSpeakRangeOfSpeechString characterRange: NSRange,
                           utterance: AVSpeechUtterance) {
        //print(characterRange, utterance)
    }
}
