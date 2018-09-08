//
//  GameEngine.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 8/27/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation
import AVFoundation
import Speech

class GameEngine {
    // Singleton
    static let shared = GameEngine()

    // Short term data for single game
    var audioEngine = AVAudioEngine()
    var micVolumeNode = AVAudioMixerNode()
    var speechRecognizer = SpeechRecognizer()
    var bgm = BGM()
    var tts = TTS()

    var isEngineRunning = false

    // MARK: - Lifecycle
    private init() {
        guard !isSimulator else { return }
        configureAudioSession()
        buildNodeGraph()
        audioEngine.prepare()
    }

    private func buildNodeGraph() {
        let mainMixer = audioEngine.mainMixerNode
        let mic = audioEngine.inputNode // only for real device, simulator will crash

        audioEngine.attach(bgm.node)
        audioEngine.attach(micVolumeNode)

        audioEngine.connect(bgm.node, to: mainMixer, format: bgm.buffer.format)
        audioEngine.connect(mic, to: micVolumeNode, format: mic.inputFormat(forBus: 0))
        audioEngine.connect(micVolumeNode, to: mainMixer, format: micVolumeNode.outputFormat(forBus: 0))

        micVolumeNode.volume = micOutVolume
        bgm.node.volume = 0.5
    }
}
