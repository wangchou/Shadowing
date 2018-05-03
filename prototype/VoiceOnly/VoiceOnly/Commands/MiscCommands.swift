//
//  MiscCommands.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/03.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation

// need to make the command layer don't know anything about the ui
// one way data flow
// cmd fired -> cmd event queue/history array -> event run loop -> event delegates in VC -> update UI & fire cmd
// make the command history is replayable

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

struct ReduceBGMCommand: Command {
    let type = CommandType.reduceBGM
    func exec() {
        Commands.shared.bgm.reduceVolume()
    }
}

struct RestoreBGMCommand: Command {
    let type = CommandType.restoreBGM
    func exec() {
        Commands.shared.bgm.restoreVolume()
    }
}

struct StartEngineCommand: Command {
    let type = CommandType.startEngine
    let context = Commands.shared
    let toSpeaker: Bool
    func exec() {
        do {
            context.isEngineRunning = true
            configureAudioSession(toSpeaker: toSpeaker)
            try context.engine.start()
            context.bgm.play()
        } catch {
            print("Start Play through failed \(error)")
        }
    }
}

struct StopEngineCommand: Command {
    let type = CommandType.stopEngine
    let context = Commands.shared
    func exec() {
        context.isEngineRunning = false
        context.engine.stop()
        context.tts.stop()
        context.speechRecognizer.stop()
    }
}
