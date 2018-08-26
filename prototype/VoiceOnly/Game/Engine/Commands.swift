//
//  Commands.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/08.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import Promises

private let context = GameContext.shared

func startEngine(toSpeaker: Bool = false) {
    context.isEngineRunning = true

    guard !isSimulator else { return }

    do {
        configureAudioSession(toSpeaker: toSpeaker)
        try context.engine.start()
        context.bgm.play()
    } catch {
        print("Start Play through failed \(error)")
    }
}

func stopEngine() {
    guard context.isEngineRunning else { return }
    context.isEngineRunning = false
    context.tts.stop()
    updateGameHistory()
    guard !isSimulator else { return }

    context.speechRecognizer.stop()
    context.bgm.stop()
    context.engine.stop()
}

func reduceBGMVolume() {
    context.bgm.reduceVolume()
}

func restoreBGMVolume() {
    context.bgm.restoreVolume()
}

// MARK: - TTS / Speak Japanese
func meijia(_ sentence: String) -> Promise<Void> {
    return context.tts.say(sentence, meijiaSan, rate: fastRate)
}

func oren(_ sentence: String, rate: Float? = nil) -> Promise<Void> {
    if let rate = rate {
        return context.tts.say(sentence, orenSan, rate: rate)
    }
    return context.tts.say(sentence, orenSan, rate: context.teachingRate)
}

func hattori(_ sentence: String, rate: Float? = nil) -> Promise<Void> {
    if let rate = rate {
        return context.tts.say(sentence, hattoriSan, rate: rate)
    }
    return context.tts.say(sentence, hattoriSan, rate: context.teachingRate)
}

func kyoko(_ sentence: String, rate: Float? = nil) -> Promise<Void> {
    if let rate = rate {
        return context.tts.say(sentence, kyokoSan, rate: rate)
    }
    return context.tts.say(sentence, kyokoSan, rate: context.teachingRate)
}

// MARK: - Voice Recognition
func listenJP(duration: Double) -> Promise<String> {
    return context.speechRecognizer.start(stopAfterSeconds: duration)
}
