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
    // this function will introduce 4 ms delay
    func setChannels(_ leftChannelOn: Bool, _ rightChannelOn: Bool) {
        let session = AVAudioSession.sharedInstance()
        let outputs = session.currentRoute.outputs
        if outputs.count == 0 || (outputs[0].channels?.isEmpty)! {
            print("unable to set sythesizer to right/left channel (simulator is not supported)")
            return
        }
        var outputChannels: [AVAudioSessionChannelDescription] = []
        if(leftChannelOn) {
            outputChannels.append(outputs[0].channels![0])
        }
        if(rightChannelOn) {
            outputChannels.append(outputs[0].channels![1])
        }
        synthesizer.outputChannels = outputChannels
    }
    
    // it will take 1~9 ms if use one channel
    //              0-3 ms if use both channel
    func speak(
        _ text: String,
        _ name: String,
        volume: Float = 1.0, // 0 ~ 1.0
        rate: Float = AVSpeechUtteranceDefaultSpeechRate, // 0.5, range 0 ~ 1.0
        leftChannelOn: Bool = true,
        rightChannelOn: Bool = true,
        onCompleteHandler: @escaping () -> Void = {}
        ) {
        
        if(!leftChannelOn || !rightChannelOn) {
            setChannels(leftChannelOn, rightChannelOn)
        }
        synthesizer.delegate = self
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(identifier: name)
        utterance.volume = volume
        utterance.rate = rate
        
        self.onCompleteHandler = onCompleteHandler
        synthesizer.speak(utterance)
    }
    
    func speakLeftOnly(
        _ text: String,
        _ name: String,
        volume: Float = 1.0, // 0 ~ 1.0
        rate: Float = AVSpeechUtteranceDefaultSpeechRate, // 0.5, range 0 ~ 1.0
        onCompleteHandler: @escaping () -> Void = {}) {
        speak(text, name, volume: volume, rate: rate, leftChannelOn: true, rightChannelOn: false, onCompleteHandler: onCompleteHandler)
    }
    
    func speakRightOnly(
        _ text: String,
        _ name: String,
        volume: Float = 1.0, // 0 ~ 1.0
        rate: Float = AVSpeechUtteranceDefaultSpeechRate, // 0.5, range 0 ~ 1.0
        onCompleteHandler: @escaping () -> Void = {}) {
        speak(text, name, volume: volume, rate: rate, leftChannelOn: false, rightChannelOn: true, onCompleteHandler: onCompleteHandler)
    }
    
    override init() {
        super.init()
        //dumpVoices()
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                           didFinish utterance: AVSpeechUtterance) {
        print(">>>", "\(utterance.speechString)")
        guard let onCompleteHandler = onCompleteHandler else { return }
        onCompleteHandler()
    }
    /*
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                           willSpeakRangeOfSpeechString characterRange: NSRange,
                           utterance: AVSpeechUtterance) {
        //print(characterRange, utterance)
    }
     */
}
