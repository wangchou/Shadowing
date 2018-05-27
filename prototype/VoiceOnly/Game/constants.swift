//
//  constants.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/04/19.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//
import UIKit
import Foundation
import AVFoundation

// kyoko & meijia compact is included default iOS no need to download
let kyokoSan = "com.apple.ttsbundle.Kyoko-compact"
let meijiaSan = "com.apple.ttsbundle.Mei-Jia-compact"

#if targetEnvironment(simulator)
    let isSimulator = true
    let orenSan = kyokoSan
    let hattoriSan = kyokoSan
#else
    let isSimulator = false
    let orenSan = "com.apple.ttsbundle.siri_female_ja-JP_compact"
    let hattoriSan = "com.apple.ttsbundle.siri_male_ja-JP_compact"
#endif

let normalRate = AVSpeechUtteranceDefaultSpeechRate

// it's bad when monitoring at street
// if in quite place. turn micOutVolume to 3
let micOutVolume: Float = 0

let screen = UIScreen.main.bounds
