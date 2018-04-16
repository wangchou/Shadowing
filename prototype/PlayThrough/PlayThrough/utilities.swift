//
//  utilities.swift
//  PlayThrough
//
//  Created by Wangchou Lu on H30/04/16.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import AVFoundation

func dumpVoices() {
    for availableVoice in AVSpeechSynthesisVoice.speechVoices() {
        //if ((availableVoice.language == AVSpeechSynthesisVoice.currentLanguageCode()) &&
        //    (availableVoice.quality == AVSpeechSynthesisVoiceQuality.enhanced)) {
        print("\(availableVoice.name) with Quality: \(availableVoice.quality.rawValue) \(availableVoice.identifier)")
        //}
    }
}

func configureAudioSession() {
    do {
        let session: AVAudioSession = AVAudioSession.sharedInstance()
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

// Latency tested result
// AVAudioEngine ~= 5.41ms
// AudioKit ~= 16.25ms
// Decision: use AVAudioEngine

// Tested setup
// channel one: sound -> iphone mic -> this play through app -> usb mixer -> garageband
// channel two: sound -> macbook mic -> garageband
// latency ~= the time interval between signal appear of channel one and channel two

/*
 test: AudioKit code with (mic -> speaker) latency ~= 16.25ms
 
 AKSettings.bufferLength = .Shortest
 let mic = AKMicrophone()
 AudioKit.output = mic
 AudioKit.start()
 */


