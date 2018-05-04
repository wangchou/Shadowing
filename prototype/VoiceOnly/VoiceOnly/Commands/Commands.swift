//
//  Commands.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/04.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import AVFoundation

enum CommandType {
    case say
    case listen
    case startEngine
    case stopEngine
    case reduceBGM
    case restoreBGM
}

protocol Command {
    var type: CommandType { get }
    func exec()
}

func dispatch(_ cmd: Command) {
    cmdGroup.wait()
    cmdGroup.enter()
    cmd.exec()
    cmdGroup.wait()
}

func startEngine(toSpeaker: Bool = false) {
    dispatch(StartEngineCommand(toSpeaker: toSpeaker))
}

func stopEngine() {
    dispatch(StopEngineCommand())
}

func reduceBGMVolume() {
    dispatch(ReduceBGMCommand())
}
func restoreBGMVolume() {
    dispatch(RestoreBGMCommand())
}

func meijia(_ sentence: String) {
    dispatch(SayCommand(sentence, MeiJia, rate: normalRate))
}

func oren(_ sentence: String, rate: Float = teachingRate) {
    dispatch(SayCommand(sentence, Oren, rate: rate))
}

func hattori(_ sentence: String, rate: Float = teachingRate) {
    dispatch(SayCommand(sentence, Hattori, rate: rate))
}

func listen(duration: Double) -> String {
    dispatch(ListenCommand(duration: duration))
    cmdGroup.wait()
    return CommandContext.shared.saidSentence
}
