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

let meijiaSan = "com.apple.ttsbundle.Mei-Jia-compact"
let orenSan = "com.apple.ttsbundle.siri_female_ja-JP_compact"
let hattoriSan = "com.apple.ttsbundle.siri_male_ja-JP_compact"

let normalRate = AVSpeechUtteranceDefaultSpeechRate

// it's bad when monitoring at street
// if in quite place. turn micOutVolume to 3
let micOutVolume: Float = 0

let screenSize = UIScreen.main.bounds
