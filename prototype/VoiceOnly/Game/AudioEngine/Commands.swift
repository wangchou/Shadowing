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

func startEngine() {
    engine.isEngineRunning = true

    guard !isSimulator else { return }

    do {
        configureAudioSession()
        try engine.audioEngine.start()
        // engine.bgm.play()
    } catch {
        print("Start Play through failed \(error)")
    }
}

func stopEngine() {
    guard engine.isEngineRunning else { return }
    engine.isEngineRunning = false
    engine.tts.stop()
    guard !isSimulator else { return }

    engine.speechRecognizer.stop()
    engine.audioEngine.stop()
}

// MARK: - TTS / Speak Japanese
func meijia(_ sentence: String, rate: Float = fastRate) -> Promise<Void> {
    return engine.tts.say(sentence, name: meijiaSan, rate: rate)
}

func oren(_ sentence: String, rate: Float = context.teachingRate) -> Promise<Void> {
    return engine.tts.say(sentence, name: orenSan, rate: context.teachingRate)
}

func hattori(_ sentence: String, rate: Float = context.teachingRate) -> Promise<Void> {
    return engine.tts.say(sentence, name: hattoriSan, rate: rate)
}

func otoya(_ sentence: String, rate: Float = context.teachingRate) -> Promise<Void> {
    return engine.tts.say(sentence, name: otoyaSan, rate: rate)
}

func kyoko(_ sentence: String, rate: Float = context.teachingRate) -> Promise<Void> {
    return engine.tts.say(sentence, name: kyokoSan, rate: context.teachingRate)
}

// MARK: - Voice Recognition
func listen(duration: Double, langCode: String? = nil) -> Promise<String> {
    let langCode = langCode ?? context.targetString.langCode ?? "ja"
    return engine.speechRecognizer.start(stopAfterSeconds: duration, localIdentifier: langCode)
}

func stopListen() {
    engine.speechRecognizer.endAudio()
}
