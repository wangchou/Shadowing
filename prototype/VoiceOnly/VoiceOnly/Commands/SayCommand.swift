//
//  SayCommand.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/03.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import Speech

fileprivate let context = CommandContext.shared

class SayCommand: NSObject, Command, AVSpeechSynthesizerDelegate {
    let type = CommandType.say
    let text: String
    let name: String
    let rate: Float
    
    init(_ text: String, _ name: String, rate: Float) {
        self.text = text
        self.name = name
        self.rate = rate
    }
    
    func exec() {
        let context = CommandContext.shared
        let tmpTime = getNow()
        if !context.isEngineRunning {
            context.speakDuration = 0
            cmdGroup.leave()
            return
        }
        context.tts.say(text, name, rate: rate, delegate: self) {
            context.speakDuration = getNow() - tmpTime
            cmdGroup.leave()
        }
    }
    
    func log() {
        switch self.name {
        case MeiJia:
            print("美佳 🇹🇼: ", terminator: "")
        case Hattori:
            print("服部 🇯🇵: ", terminator: "")
        case Oren:
            print("オーレン 🇯🇵: ", terminator: "")
        default:
            return
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                           willSpeakRangeOfSpeechString characterRange: NSRange,
                           utterance: AVSpeechUtterance) {
        let speechString = utterance.speechString as NSString
        let token = speechString.substring(with: characterRange)
        print(token, terminator: "")
    }
    
    func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didFinish utterance: AVSpeechUtterance
        ) {
        guard context.tts.completionHandler != nil else { return }
        print("")
        context.tts.completionHandler!()
    }
}
