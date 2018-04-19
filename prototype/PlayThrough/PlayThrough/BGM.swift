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
    var tmpVolume: Float? = nil
    
    init() {
        do {
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
    
    func reduceVolume() {
        if tmpVolume == nil {
            tmpVolume = node.volume
            node.volume = 0.2 * node.volume
        } else {
            print("Error: cannot reduce volume twice. restore it first")
        }
    }
    
    func restoreVolume() {
        if let tmpVolume = tmpVolume {
            node.volume = tmpVolume
            self.tmpVolume = nil
        }
    }
}
