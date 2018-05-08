//
//  Commands.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/08.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import Promises

fileprivate let context = GameContext.shared

func startEngine(toSpeaker: Bool = false) {
    let context = GameContext.shared
    do {
        context.isEngineRunning = true
        configureAudioSession(toSpeaker: toSpeaker)
        try context.engine.start()
        context.bgm.play()
    } catch {
        print("Start Play through failed \(error)")
    }
}

func stopEngine() {
    context.isEngineRunning = false
    context.speechRecognizer.stop()
    context.engine.stop()
    context.tts.stop()
}

func reduceBGMVolume() {
    context.bgm.reduceVolume()
}
func restoreBGMVolume() {
    context.bgm.restoreVolume()
}

func meijia(_ sentence: String) -> Promise<Void> {
    return context.tts.say(sentence, MeiJia, rate: normalRate)
}

func oren(_ sentence: String, rate: Float = teachingRate) -> Promise<Void> {
    return context.tts.say(sentence, Oren, rate: rate)
}

func hattori(_ sentence: String, rate: Float = teachingRate) -> Promise<Void> {
    return context.tts.say(sentence, Hattori, rate: rate)
}

func listenJP(duration: Double) -> Promise<String> {
    return context.speechRecognizer.start(stopAfterSeconds: duration)
}
