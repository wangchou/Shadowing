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
private let engine = GameEngine.shared

func startEngine(toSpeaker: Bool = false) {
    engine.isEngineRunning = true

    guard !isSimulator else { return }

    do {
        configureAudioSession(toSpeaker: toSpeaker)
        try engine.audioEngine.start()
        engine.bgm.play()
    } catch {
        print("Start Play through failed \(error)")
    }
}

func stopEngine() {
    guard engine.isEngineRunning else { return }
    engine.isEngineRunning = false
    engine.tts.stop()
    updateGameHistory()
    guard !isSimulator else { return }

    engine.speechRecognizer.stop()
    engine.bgm.stop()
    engine.audioEngine.stop()
}

func reduceBGMVolume() {
    engine.bgm.reduceVolume()
}

func restoreBGMVolume() {
    engine.bgm.restoreVolume()
}

// MARK: - TTS / Speak Japanese
func meijia(_ sentence: String, rate: Float = fastRate) -> Promise<Void> {
    return engine.tts.say(sentence, meijiaSan, rate: rate)
}

func oren(_ sentence: String, rate: Float = context.teachingRate) -> Promise<Void> {
    return engine.tts.say(sentence, orenSan, rate: context.teachingRate)
}

func hattori(_ sentence: String, rate: Float = context.teachingRate) -> Promise<Void> {
    return engine.tts.say(sentence, hattoriSan, rate: rate)
}

func otoya(_ sentence: String, rate: Float = context.teachingRate) -> Promise<Void> {
    return engine.tts.say(sentence, otoyaSan, rate: rate)
}

func kyoko(_ sentence: String, rate: Float = context.teachingRate) -> Promise<Void> {
    return engine.tts.say(sentence, kyokoSan, rate: context.teachingRate)
}

// MARK: - Voice Recognition
func listenJP(duration: Double) -> Promise<String> {
    return engine.speechRecognizer.start(stopAfterSeconds: duration)
}
