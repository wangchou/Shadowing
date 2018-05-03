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

// need to make the command layer don't know anything about the ui
// let many UI layer Instance monitoring the command layer events and interpreted it
// then launch EventRunLoop...
// in EventRunLoop it will called methods in delegate

// one way data flow
// cmd fired -> cmd event queue/history array -> event run loop -> event delegates in VC -> update UI & fire cmd
// make the command history is replayable

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
    func startEngine(toSpeaker: Bool = false) {
        do {
            cmdGroup.wait()
            isEngineRunning = true
            configureAudioSession(toSpeaker: toSpeaker)
            //bgm.node.volume = toSpeaker ? 0 : 0.5
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
        tts.say(text, name, rate: rate, delegate: delegate) {
            if(name == Hattori ) {
                self.bgm.restoreVolume()
            }
            cmdGroup.leave()
        }
        cmdGroup.wait()
    }
    
    func listen(listenDuration: Double,
                resultHandler: @escaping (SFSpeechRecognitionResult?, Error?) -> Void
        ) {
        if !isEngineRunning {
            return
        }
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

// Define Characters like renpy
func meijia(_ sentence: String) {
    print("美佳 🇹🇼: ", terminator: "")
    Commands.shared.say(sentence, MeiJia)
}

func oren(_ sentence: String, rate: Float = teachingRate, delegate: AVSpeechSynthesizerDelegate? = nil) {
    print("オーレン 🇯🇵: ", terminator: "")
    Commands.shared.say(sentence, Oren, rate: rate, delegate: delegate)
}

func hattori(_ sentence: String, rate: Float = teachingRate, delegate: AVSpeechSynthesizerDelegate? = nil) {
    print("服部 🇯🇵: ", terminator: "")
    Commands.shared.say(sentence, Hattori, rate: rate, delegate: delegate)
}
