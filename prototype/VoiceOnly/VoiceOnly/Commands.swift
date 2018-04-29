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

let assistant = MeiJia
let teacher = Hattori

class Commands {
    
    //Singleton
    static let shared = Commands()
    
    var engine = AVAudioEngine()
    var micVolumeNode = AVAudioMixerNode()
    var replayUnit: ReplayUnit!
    var speechRecognizer: SpeechRecognizer = SpeechRecognizer()
    var bgm = BGM()
    var tts = TTS()
    
    public var isEngineRunning = false
    
    // MARK: - Lifecycle
    private init() {
        configureAudioSession()
        buildNodeGraph()
        engine.prepare()
    }
    
    private func buildNodeGraph() {
        // get nodes
        let mainMixer = engine.mainMixerNode
        let mic = engine.inputNode // only for real device, simulator will crash
        let format = mic.outputFormat(forBus: 0)
        replayUnit = ReplayUnit()
        
        // attach nodes
        engine.attach(bgm.node)
        engine.attach(replayUnit.node)
        engine.attach(micVolumeNode)
        
        // connect nodes
        engine.connect(bgm.node, to: mainMixer, format: bgm.buffer.format)
        engine.connect(mic, to: micVolumeNode, format: mic.inputFormat(forBus: 0))
        engine.connect(micVolumeNode, to: mainMixer, format: micVolumeNode.outputFormat(forBus: 0))
        engine.connect(replayUnit.node, to: mainMixer, format: format)

        micVolumeNode.volume = micOutVolume
        
        // volume
        bgm.node.volume = 0.5
    }
    
    // MARK: - Public
    func startEngine() {
        do {
            isEngineRunning = true
            try engine.start()
            bgm.play()
        } catch {
            print("Start Play through failed \(error)")
        }
    }
    
    func stopEngine() {
        isEngineRunning = false
        engine.stop()
        tts.stop()
        speechRecognizer.stop()
    }
    
    // Warning: use it in myQueue.async {} block
    // It blocks current thead !!!
    // Do not call it on main thread
    func say(
        _ text: String,
        _ name: String,
        rate: Float = normalRate,
        delegate: AVSpeechSynthesizerDelegate? = nil
        ) {
        if !isEngineRunning {
            return
        }
        cmdGroup.enter()
        if(name == teacher) {
            bgm.reduceVolume()
        }
        
        tts.say(text, name, rate: rate, delegate: delegate) {
            if(name == teacher) {
                self.bgm.restoreVolume()
            }
            cmdGroup.leave()
        }
        cmdGroup.wait()
    }
    
    func listen(listenDuration: Double,
                resultHandler: @escaping (SFSpeechRecognitionResult?, Error?) -> Void
        ) {
        DispatchQueue.main.async {
            self.speechRecognizer.start(
                inputNode: self.engine.inputNode,
                stopAfterSeconds: listenDuration,
                resultHandler: resultHandler
            )
        }
    }
    
    // Warning: use it in myQueue.async {} block
    // It blocks current thead !!!
    // Do not call it on main thread
    func replay() {
        cmdGroup.enter()
        replayUnit.play() { cmdGroup.leave() }
        cmdGroup.wait()
    }
}
