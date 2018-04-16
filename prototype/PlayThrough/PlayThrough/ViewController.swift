//
//  ViewController.swift
//  PlayThrough
//
//  Created by Wangchou Lu on H30/04/14.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    var engine: AVAudioEngine = AVAudioEngine()
    var bgm: BGM = BGM()
    var tts: TTS = TTS()
    
    func buildNodeGraph() {
        let mainMixer = engine.mainMixerNode
        
        // bgm
        engine.attach(bgm.node)
        engine.connect(bgm.node, to: mainMixer, format: bgm.buffer.format)
        
        // mic only for real device, not for simulator
//        let mic = engine.inputNode
//        engine.connect(mic, to: mainMixer, format: mic.outputFormat(forBus: 0))
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
        dumpVoices()
        engineStart()
        bgm.play()
        tts.speak("可以下班了嗎？星期天累累的。", "com.apple.ttsbundle.Mei-Jia-compact")
        tts.speak("紘一の息子。大学卒業後、「こはぜ屋」を手伝いながら就職活動中。", "com.apple.ttsbundle.Otoya-premium")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


