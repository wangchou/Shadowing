//
//  SayCommand.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/03.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import Speech

class SayCommand: Command {
    let type = CommandType.say
    let exec: () -> Void
    let text: String
    let name: String
    let rate: Float
    let delegate: AVSpeechSynthesizerDelegate?
    
    init(_ context: Commands,
         _ text: String,
         _ name: String,
         rate: Float = normalRate,
         delegate: AVSpeechSynthesizerDelegate? = nil) {
        self.text = text
        self.name = name
        self.rate = rate
        self.delegate = delegate
        exec = {
            if !context.isEngineRunning {
                return
            }
            cmdGroup.enter()
            context.tts.say(text, name, rate: rate, delegate: delegate) {
                if(name == Hattori ) {
                    context.bgm.restoreVolume()
                }
                cmdGroup.leave()
            }
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
}

// Define Characters like renpy
func meijia(_ sentence: String) {
    let sayCommand = SayCommand(Commands.shared, sentence, MeiJia)
    dispatch(sayCommand)
}

func oren(_ sentence: String, rate: Float = teachingRate, delegate: AVSpeechSynthesizerDelegate? = nil) {
    let sayCommand = SayCommand(Commands.shared, sentence, Oren, rate: rate, delegate: delegate)
    dispatch(sayCommand)
}

func hattori(_ sentence: String, rate: Float = teachingRate, delegate: AVSpeechSynthesizerDelegate? = nil) {
    let sayCommand = SayCommand(Commands.shared, sentence, Hattori, rate: rate, delegate: delegate)
    dispatch(sayCommand)
}
