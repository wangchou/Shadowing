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

class AudioController {
    
    //Singleton
    static let shared = AudioController()
    
    var engine = AVAudioEngine()
    var boosterNode = AVAudioMixerNode()
    var replayUnit: ReplayUnit!
    var speechRecognizer: SpeechRecognizer = SpeechRecognizer()
    var bgm = BGM()
    var tts = TTS()
    public var isRunning = false
    
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
        engine.attach(boosterNode)
        
        // connect nodes
        engine.connect(bgm.node, to: mainMixer, format: bgm.buffer.format)
        engine.connect(mic, to: boosterNode, format: mic.inputFormat(forBus: 0))
        engine.connect(boosterNode, to: mainMixer, format: boosterNode.outputFormat(forBus: 0))
        engine.connect(replayUnit.node, to: mainMixer, format: format)

        boosterNode.volume = micOutVolume
        
        // volume
        bgm.node.volume = 0.5
    }
    
    func start() {
        do {
            isRunning = true
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
    
    // Warning: use it in myQueue.async {} block
    // It blocks current thead !!!
    // Do not call it on main thread
    func say(
        _ text: String,
        _ name: String,
        rate: Float = normalRate,
        delegate: AVSpeechSynthesizerDelegate? = nil
        ) {
        if !isRunning {
            return
        }
        myGroup.enter()
        if(name == teacher) {
            bgm.reduceVolume()
            boosterNode.volume = 0
        }
        
        tts.say(text, name, rate: rate, delegate: delegate) {
            self.boosterNode.volume = micOutVolume
            if(name == teacher) {
                self.bgm.restoreVolume()
            }
            myGroup.leave()
        }
        myGroup.wait()
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
    func replay(completionHandler: @escaping () -> Void) {
        myGroup.enter()
        replayUnit.play() { myGroup.leave() }
        myGroup.wait()
    }
}
