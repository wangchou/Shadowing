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

class CommandContext {
    //Singleton
    static let shared = CommandContext()
    
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
    var speakDuration: Double = 0
    
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
        self.sentences = sentences
        self.targetString = sentences[0]
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