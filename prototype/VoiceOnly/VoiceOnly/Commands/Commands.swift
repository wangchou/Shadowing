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

var sentenceIndex = 0

func logger(_ cmd: Command) {
    switch cmd.type {
    case CommandType.say:
        (cmd as! SayCommand).log()
    case CommandType.listen:
        print("hear <<< ")
    default:
        print(cmd.type)
    }
}

func dispatch(_ cmd: Command) {
    cmdGroup.wait()
    logger(cmd)
    cmd.exec()
    cmdGroup.wait()
}

class Commands {
    //Singleton
    static let shared = Commands()
    
    var engine = AVAudioEngine()
    var micVolumeNode = AVAudioMixerNode()
    var speechRecognizer: SpeechRecognizer = SpeechRecognizer()
    var bgm = BGM()
    var tts = TTS()
    var isEngineRunning = false
    
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
    
    // MARK: - Public
    func startEngine(toSpeaker: Bool = false) {
        dispatch(StartEngineCommand(toSpeaker: toSpeaker))
    }
    
    func stopEngine() {
        dispatch(StopEngineCommand())
    }
    
    func reduceBGMVolume() {
        dispatch(ReduceBGMCommand())
    }
    func restoreBGMVolume() {
        dispatch(RestoreBGMCommand())
    }
}
