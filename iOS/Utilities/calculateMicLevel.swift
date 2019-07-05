//
//  calculateMicLevel.swift
//  今話したい
//
//  Created by Wangchou Lu on 3/17/31 H.
//  Copyright © 31 Heisei Lu, WangChou. All rights reserved.
//

import AVFoundation

private let minDb: Float = -55

private func scaledPower(power: Float) -> Float {
    guard power.isFinite else { return 0.0 }

    if power < minDb {
        return 0.0
    } else if power >= 1.0 {
        return 1.0
    } else {
        return (abs(minDb) - abs(power)) / abs(minDb)
    }
}

func calculateMicLevel(buffer: AVAudioPCMBuffer) {
    // calculate mic volume
    // https://www.raywenderlich.com/5154-avaudioengine-tutorial-for-ios-getting-started
    DispatchQueue.global().async {
        guard let data = buffer.floatChannelData?.pointee else { return }
        let squareSum = stride(from: 0,
                               to: Int(buffer.frameLength),
                               by: buffer.stride)
            .map { (i: Int) in data[i] * data[i] }
            .reduce(0) { (sum: Float, square: Float) in sum + square }

        let rms = sqrt(squareSum / Float(buffer.frameLength))
        let avgPower = 20 * log10(rms)
        let meterLevel = scaledPower(power: avgPower)
        postEvent(.levelMeterUpdate, int: Int(meterLevel * 100))
    }
}
