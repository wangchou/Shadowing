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
// one way data flow
// cmd fired -> cmd event queue/history array -> event run loop -> event delegates in VC -> update UI & fire cmd
// make the command history is replayable

enum CommandType {
    case say
    case listen
    case engineStart
    case engineEnd
    case reduceBGM
    case restoreBGM
}

protocol Command {
    var type: CommandType { get }
    func exec()
}

func logger(_ cmd: Command) {
    switch cmd.type {
    case CommandType.say:
        (cmd as! SayCommand).log()
    case CommandType.listen:
        print("hear <<< ")
    default:
        print("unlogging command")
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

        // attach nodes
        engine.attach(bgm.node)
        engine.attach(micVolumeNode)
        
        // connect nodes
        engine.connect(bgm.node, to: mainMixer, format: bgm.buffer.format)
        engine.connect(mic, to: micVolumeNode, format: mic.inputFormat(forBus: 0))
        engine.connect(micVolumeNode, to: mainMixer, format: micVolumeNode.outputFormat(forBus: 0))

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
    
    func listen(listenDuration: Double,
                resultHandler: @escaping (SFSpeechRecognitionResult?, Error?) -> Void
        ) {
        let listenCommand = ListenCommand(listenDuration: listenDuration, resultHandler: resultHandler)
        dispatch(listenCommand)
    }
    
    func reduceBGMVolume() {
        cmdGroup.wait()
        bgm.reduceVolume()
        cmdGroup.wait()
    }
    func restoreBGMVolume() {
        cmdGroup.wait()
        bgm.restoreVolume()
        cmdGroup.wait()
    }
}
