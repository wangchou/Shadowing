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

struct ReduceBGMCommand: Command {
    let type = CommandType.reduceBGM
    func exec() {
        GameContext.shared.bgm.reduceVolume()
        cmdGroup.leave()
    }
}

struct RestoreBGMCommand: Command {
    let type = CommandType.restoreBGM
    func exec() {
        GameContext.shared.bgm.restoreVolume()
        cmdGroup.leave()
    }
}

struct StartEngineCommand: Command {
    let type = CommandType.startEngine
    let toSpeaker: Bool
    func exec() {
        let context = GameContext.shared
        do {
            context.isEngineRunning = true
            configureAudioSession(toSpeaker: toSpeaker)
            try context.engine.start()
            context.bgm.play()
        } catch {
            print("Start Play through failed \(error)")
        }
        cmdGroup.leave()
    }
}

struct StopEngineCommand: Command {
    let type = CommandType.stopEngine
    func exec() {
        let context = GameContext.shared
        context.isEngineRunning = false
        context.engine.stop()
        context.tts.stop()
        context.speechRecognizer.stop()
        cmdGroup.leave()
    }
}
