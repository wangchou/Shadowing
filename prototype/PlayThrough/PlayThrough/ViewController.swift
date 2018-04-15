//
//  ViewController.swift
//  PlayThrough
//
//  Created by Wangchou Lu on H30/04/14.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import UIKit
import AVFoundation

// Test setup
// channel one: sound -> iphone mic -> this play through app -> usb mixer -> garageband
// channel two: sound -> macbook mic -> garageband
// latency ~= the time interval between signal appear of channel one and channel two

/*
 test: AudioKit code with (mic -> speaker) latency ~= 16.25ms
 decision: Not using AudioKit anymore
 
 AKSettings.bufferLength = .Shortest
 let mic = AKMicrophone()
 AudioKit.output = mic
 AudioKit.start()
*/

// tested result
// following AVAudioEngine code with (mic -> speaker latency) ~= 5.41ms

class ViewController: UIViewController, AVSpeechSynthesizerDelegate {

    var session: AVAudioSession = AVAudioSession.sharedInstance()
    var engine: AVAudioEngine = AVAudioEngine()
    var mainMixer: AVAudioMixerNode!
    var mic: AVAudioInputNode!
    var speaker: AVAudioOutputNode!
    var bgm: AVAudioPlayerNode!
    var bgmFile: AVAudioFile!
    var bgmBuffer: AVAudioPCMBuffer!
    var speechSynthesizer: AVSpeechSynthesizer = AVSpeechSynthesizer()
    
    func buildNodeGraph() {
        do {
            // create nodes
            mainMixer = engine.mainMixerNode
            mic = engine.inputNode
            speaker = engine.outputNode
            
            // bgm
            let path = Bundle.main.path(forResource: "drumLoop", ofType: "caf")!
            let url = URL(fileURLWithPath: path)
            bgmFile = try AVAudioFile(forReading: url)
            bgmBuffer = AVAudioPCMBuffer(pcmFormat: bgmFile.processingFormat, frameCapacity: UInt32(bgmFile.length))
            try bgmFile.read(into: bgmBuffer)
            bgm = AVAudioPlayerNode()
            
            // connect nodes
            engine.attach(bgm)
            engine.connect(bgm, to: mainMixer, format: bgmBuffer.format)
            // only for real device, not for simulator
            //engine.connect(mic, to: mainMixer, format: mic.outputFormat(forBus: 0))
        } catch {
            print("\(error)")
        }
        
    }
    
    func speak(
        _ text: String,
        _ name: String
    ) {
        speechSynthesizer.delegate = self
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(identifier: name)
        speechSynthesizer.speak(utterance)
    }
    
    func startPlayThrough() {
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
            
            buildNodeGraph()
            
            engine.prepare()
            try engine.start()
            bgm.scheduleBuffer(bgmBuffer, at: nil, options: .loops)
            bgm.play()
            speak("可以下班了嗎？星期天累累的。", "com.apple.ttsbundle.Mei-Jia-compact")
            speak("紘一の息子。大学卒業後、「こはぜ屋」を手伝いながら就職活動中。", "com.apple.ttsbundle.Otoya-premium")
        } catch {
            print("Start Play through failed \(error)")
        }
    }
    
    func dumpVoices() {
        for availableVoice in AVSpeechSynthesisVoice.speechVoices() {
            //if ((availableVoice.language == AVSpeechSynthesisVoice.currentLanguageCode()) &&
            //    (availableVoice.quality == AVSpeechSynthesisVoiceQuality.enhanced)) {
                print("\(availableVoice.name) with Quality: \(availableVoice.quality.rawValue) \(availableVoice.identifier)")
            //}
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        dumpVoices()
        startPlayThrough()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                           willSpeakRangeOfSpeechString characterRange: NSRange,
                           utterance: AVSpeechUtterance) {
        //print(characterRange, utterance)
    }
}


