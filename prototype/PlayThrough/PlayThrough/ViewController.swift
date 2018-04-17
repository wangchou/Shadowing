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
    var engine: AVAudioEngine = AVAudioEngine()
    var speechRecognizer: SpeechRecognizer = SpeechRecognizer()
    var mic: AVAudioInputNode!
    var bgm: BGM = BGM()
    var tts: TTS = TTS()
    
    func buildNodeGraph() {
        let mainMixer = engine.mainMixerNode
        
        // bgm
        engine.attach(bgm.node)
        engine.connect(bgm.node, to: mainMixer, format: bgm.buffer.format)
        
        // mic only for real device, not for simulator
        mic = engine.inputNode
        engine.connect(mic, to: mainMixer, format: mic.outputFormat(forBus: 0))
        
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
                    self.tts.speak(result.bestTranscription.formattedString, Otoya) {
                        self.tts.speak("請說日文給我聽", MeiJia, onCompleteHandler: self.startListening)
                    }
                }
            }
        }
        
        if isFinal {
            speechRecognizer.stop()
        }
        
        if error != nil {
            print("\nError=\(error.debugDescription)")
            tts.speak("聽不清楚、再說一次", MeiJia, onCompleteHandler: startListening)
        }
    }
}


