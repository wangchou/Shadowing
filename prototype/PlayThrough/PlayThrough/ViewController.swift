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
        tts.speak("請說日文給我聽", "com.apple.ttsbundle.Mei-Jia-compact") {
            self.speechRecognizer.start(inputNode: self.mic, resultHandler: self.speechResultHandler)
            Timer.scheduledTimer(withTimeInterval: 8.0, repeats: false) { timer in
                self.speechRecognizer.stop()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func speechResultHandler(result: SFSpeechRecognitionResult?, error: Error?) {
        var isFinal = false
        
        if let result = result {
            isFinal = result.isFinal
            print(result, "isFinal =", isFinal)
            if(isFinal) {
                tts.speak("我聽到你說：", "com.apple.ttsbundle.Mei-Jia-compact")
                tts.speak(result.bestTranscription.formattedString, "com.apple.ttsbundle.Otoya-premium")
                tts.speak("請說日文給我聽", "com.apple.ttsbundle.Mei-Jia-compact") {
                    self.speechRecognizer.start(inputNode: self.mic, resultHandler: self.speechResultHandler)
                    Timer.scheduledTimer(withTimeInterval: 8.0, repeats: false) { timer in
                        self.speechRecognizer.stop()
                    }
                }
            }
        }
        
        if isFinal {
            print("\nRecogntion is done with isFinal = \(isFinal)")
            speechRecognizer.stop()
        }
        
        if error != nil {
            print("\nError=\(error.debugDescription)")
            tts.speak("聽不清楚、再說一次", "com.apple.ttsbundle.Mei-Jia-compact") {
                self.speechRecognizer.start(inputNode: self.mic, resultHandler: self.speechResultHandler)
                Timer.scheduledTimer(withTimeInterval: 8.0, repeats: false) { timer in
                    self.speechRecognizer.stop()
                }
            }
        }
    }
}


