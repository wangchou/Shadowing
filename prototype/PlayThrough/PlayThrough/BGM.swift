//
//  BGM.swift
//  PlayThrough
//
//  Created by Wangchou Lu on H30/04/16.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import AVFoundation

class BGM {
    public var node: AVAudioPlayerNode = AVAudioPlayerNode()
    var file: AVAudioFile!
    public var buffer: AVAudioPCMBuffer!
    
    init() {
        do {
            node.pan = -0.5 // -1.0 ~ 1.0
            let path = Bundle.main.path(forResource: "drumLoop", ofType: "caf")!
            let url = URL(fileURLWithPath: path)
            file = try AVAudioFile(forReading: url)
            buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: UInt32(file.length))
            try file.read(into: buffer)
        } catch {
            print("prepare bgm with \(error)")
        }
    }
    
    func play() {
        node.scheduleBuffer(buffer, at: nil, options: .loops)
        node.play()
    }
}
