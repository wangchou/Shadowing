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

let replayRate: Float = 1

let assistant = MeiJia
let teacher = Hattori

class AudioController {
    
    //Singleton
    static let shared = AudioController()
    
    var engine = AVAudioEngine()
    var speedEffectNode = AVAudioUnitTimePitch()
    var replayUnit: ReplayUnit!
    var speechRecognizer: SpeechRecognizer = SpeechRecognizer()
    var bgm = BGM()
    var tts = TTS()
    public var isRunning = false
    
    private init() {}
    
    private func buildNodeGraph() {
        // get nodes
        let mainMixer = engine.mainMixerNode
        let mic = engine.inputNode // only for real device, simulator will crash
        let format = mic.outputFormat(forBus: 0)
        replayUnit = ReplayUnit()
        
        // attach nodes
        engine.attach(bgm.node)
        engine.attach(replayUnit.node)
        engine.attach(speedEffectNode)
        
        // connect nodes
        engine.connect(bgm.node, to: mainMixer, format: bgm.buffer.format)
        engine.connect(mic, to: mainMixer, format: format)
        engine.connect(replayUnit.node, to: speedEffectNode, format: format)
        engine.connect(speedEffectNode, to: mainMixer, format: format)
        
        // misc
        speedEffectNode.rate = replayRate // replay slowly
        
        // volume
        bgm.node.volume = 0.5
    }
    
    func start() {
        do {
            isRunning = true
            configureAudioSession()
            buildNodeGraph()
            engine.prepare()
            try engine.start()
            bgm.play()
        } catch {
            print("Start Play through failed \(error)")
        }
    }
    
    func stop() {
        isRunning = false
        engine.stop()
        tts.stop()
        speechRecognizer.stop()
    }
    
    // syntax sugar wrapper
    func say(
        _ text: String,
        _ name: String,
        rate: Float = normalRate,
        onCompleteHandler: @escaping () -> Void = {}
        ) {
        if !isRunning {
            return
        }
        if(name == teacher) {
            bgm.reduceVolume()
        }
        tts.say(text, name, rate: rate) {
            onCompleteHandler()
            if(name == teacher) {
                self.bgm.restoreVolume()
            }
        }
    }
    
    func replay(completionHandler: @escaping () -> Void) {
        replayUnit.play()
        completionHandler()
    }
    
}
