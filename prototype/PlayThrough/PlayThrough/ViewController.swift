//
//  ViewController.swift
//  PlayThrough
//
//  Created by Wangchou Lu on H30/04/14.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import UIKit
import AVFoundation
import Speech

let MeiJia = "com.apple.ttsbundle.Mei-Jia-compact"
let Otoya = "com.apple.ttsbundle.Otoya-premium"

class ViewController: UIViewController {
    var engine = AVAudioEngine()
    var speedEffectNode = AVAudioUnitTimePitch()
    var replayUnit: ReplayUnit!
    var speechRecognizer: SpeechRecognizer = SpeechRecognizer()
    var mic: AVAudioInputNode!
    var bgm = BGM()
    var tts = TTS()
    
    func buildNodeGraph() {
        let mainMixer = engine.mainMixerNode
        
        // bgm
        engine.attach(bgm.node)
        engine.connect(bgm.node, to: mainMixer, format: bgm.buffer.format)
        
        // mic only for real device, not for simulator
        mic = engine.inputNode
        let format = mic.outputFormat(forBus: 0)
        engine.connect(mic, to: mainMixer, format: format)
        
        // replay unit
        replayUnit = ReplayUnit(pcmFormat: format)
        engine.attach(replayUnit.node)
        engine.attach(speedEffectNode)
        engine.connect(replayUnit.node, to: speedEffectNode, format: format)
        engine.connect(speedEffectNode, to: mainMixer, format: format)
        speedEffectNode.rate = 0.8 // replay slowly
        
        // for dev
        bgm.node.pan = -1.0
        bgm.node.volume = 0.05
        mic.pan = -1.0
    }
    
    func engineStart() {
        do {
            configureAudioSession()
            buildNodeGraph()
            engine.prepare()
            try engine.start()
        } catch {
            print("Start Play through failed \(error)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        engineStart()
        bgm.play()
        tts.speak("請說日文給我聽", MeiJia, onCompleteHandler: startListening)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func speechStartHandler() {
        // for dev mode
        self.tts.speak("読めば分かる！説明できない面白さ！！", Otoya, volume: 1.0, leftChannelOn: false)
        
        // make a beep sound for normal mode
    }
    
    func startListening() {
        self.speechRecognizer.start(
            inputNode: self.mic,
            stopAfterSeconds: 5,
            startHandler: self.speechStartHandler,
            resultHandler: self.speechResultHandler
        )
    }
    
    func speechResultHandler(result: SFSpeechRecognitionResult?, error: Error?) {
        var isFinal = false
        
        if let result = result {
            isFinal = result.isFinal
            print("\n<<< \(result.bestTranscription.formattedString)\n")
            if(isFinal) {
                tts.speak("我聽到你說：", MeiJia) {
                    //self.tts.speak(result.bestTranscription.formattedString, Otoya) {
                    self.replayUnit.play() {
                        self.tts.speak("請說日文給我聽", MeiJia, onCompleteHandler: self.startListening)
                    }
                    //}
                }
            }
        }
        
        if isFinal {
            speechRecognizer.stop()
        }
        
        if error != nil {
            print(error)
            tts.speak("聽不清楚、再說一次", MeiJia, onCompleteHandler: startListening)
        }
    }
}


