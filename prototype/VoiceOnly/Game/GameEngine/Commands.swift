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
    context.isEngineRunning = false
    context.tts.stop()
    updateGameHistory()
    guard !isSimulator else { return }

    context.speechRecognizer.stop()
    context.bgm.stop()
    context.engine.stop()
}

func updateGameHistory() {
    guard let record = context.gameRecord else { return }

    if let previousRecord = context.gameHistory[record.dataSetKey],
        record.p <= previousRecord.p &&
            record.rank != "SS" {
        return
    }

    context.gameHistory[record.dataSetKey] = record
    saveGameHistory()
}

func reduceBGMVolume() {
    context.bgm.reduceVolume()
}
func restoreBGMVolume() {
    context.bgm.restoreVolume()
}

func meijia(_ sentence: String) -> Promise<Void> {
    return context.tts.say(sentence, meijiaSan, rate: normalRate)
}

func oren(_ sentence: String, rate: Float? = nil) -> Promise<Void> {
    if let rate = rate {
        return context.tts.say(sentence, orenSan, rate: rate)
    }
    return context.tts.say(sentence, orenSan, rate: context.teachingRate)
}

func hattori(_ sentence: String) -> Promise<Void> {
    return context.tts.say(sentence, hattoriSan, rate: context.teachingRate)
}

func listenJP(duration: Double) -> Promise<String> {
    return context.speechRecognizer.start(stopAfterSeconds: duration)
}