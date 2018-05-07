//
//  AudioController.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/04/24.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import AVFoundation
import Speech
import Promises

class GameContext {
    //Singleton
    static let shared = GameContext()
    
    var engine = AVAudioEngine()
    var micVolumeNode = AVAudioMixerNode()
    var speechRecognizer: SpeechRecognizer = SpeechRecognizer()
    var bgm = BGM()
    var tts = TTS()
    var isEngineRunning = false
    
    var sentences: [String] = []
    var sentenceIndex: Int = 0
    var targetString: String = ""
    var saidSentence: String = ""
    var isDev = true
    var score = 0
    
    // MARK: - Lifecycle
    private init() {
        configureAudioSession()
        buildNodeGraph()
        engine.prepare()
    }
    
    private func buildNodeGraph() {
        let mainMixer = engine.mainMixerNode
        let mic = engine.inputNode // only for real device, simulator will crash

        engine.attach(bgm.node)
        engine.attach(micVolumeNode)
        
        engine.connect(bgm.node, to: mainMixer, format: bgm.buffer.format)
        engine.connect(mic, to: micVolumeNode, format: mic.inputFormat(forBus: 0))
        engine.connect(micVolumeNode, to: mainMixer, format: micVolumeNode.outputFormat(forBus: 0))

        micVolumeNode.volume = micOutVolume
        bgm.node.volume = 0.5
    }
    
    func loadLearningSentences(_ sentences: [String]) {
        self.sentenceIndex = 0
        self.sentences = sentences.shuffled()
        self.targetString = self.sentences[0]
    }
    
    func nextSentence() -> Bool {
        sentenceIndex = sentenceIndex + 1
        if sentenceIndex < sentences.count {
            targetString = sentences[sentenceIndex]
            saidSentence = ""
            return true
        } else {
            return false
        }
    }
}

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
