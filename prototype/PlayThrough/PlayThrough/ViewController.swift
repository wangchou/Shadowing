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
    var session: AVAudioSession = AVAudioSession.sharedInstance()
    var engine: AVAudioEngine = AVAudioEngine()
    var mainMixer: AVAudioMixerNode!
    var mic: AVAudioInputNode!
    var speaker: AVAudioOutputNode!
    var bgm: AVAudioPlayerNode!
    var bgmFile: AVAudioFile!
    var bgmBuffer: AVAudioPCMBuffer!
    var tts: TTS = TTS()
    
    func prepareBGM() {
        do {
            let path = Bundle.main.path(forResource: "drumLoop", ofType: "caf")!
            let url = URL(fileURLWithPath: path)
            bgmFile = try AVAudioFile(forReading: url)
            bgmBuffer = AVAudioPCMBuffer(pcmFormat: bgmFile.processingFormat, frameCapacity: UInt32(bgmFile.length))
            try bgmFile.read(into: bgmBuffer)
        } catch {
            print("prepare bgm with \(error)")
        }
    }
    
    func playBGM() {
        bgm.scheduleBuffer(bgmBuffer, at: nil, options: .loops)
        bgm.play()
    }
    
    func buildNodeGraph() {
        // create nodes
        mainMixer = engine.mainMixerNode
        mic = engine.inputNode
        speaker = engine.outputNode
        bgm = AVAudioPlayerNode()
        
        // bgm
        prepareBGM()
        engine.attach(bgm)
        engine.connect(bgm, to: mainMixer, format: bgmBuffer.format)
        
        // only for real device, not for simulator
        //engine.connect(mic, to: mainMixer, format: mic.outputFormat(forBus: 0))
    }
    
    func configureAudioSession() {
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try session.setCategory(
                AVAudioSessionCategoryPlayAndRecord,
                mode: AVAudioSessionModeMeasurement
            )
            
            // per ioBufferDuration
            // default  23ms | 1024 frames | <1% CPU (iphone SE)
            // 0.001   0.7ms |   32 frames |  8% CPU
            try session.setPreferredIOBufferDuration(0.001)
            print(session.ioBufferDuration)
            
            session.requestRecordPermission({ (success) in
                if success { print("Permission Granted") } else {
                    print("Permission fail")
                }
            })
        } catch {
            print("configuare audio session with \(error)")
        }
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
        playBGM()
        tts.speak("可以下班了嗎？星期天累累的。", "com.apple.ttsbundle.Mei-Jia-compact")
        tts.speak("紘一の息子。大学卒業後、「こはぜ屋」を手伝いながら就職活動中。", "com.apple.ttsbundle.Otoya-premium")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


