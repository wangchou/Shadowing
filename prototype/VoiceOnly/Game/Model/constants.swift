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
let fastRate = AVSpeechUtteranceDefaultSpeechRate * 1.1

// it's bad when monitoring at street
// if in quite place. turn micOutVolume to 3
let micOutVolume: Float = 0

let screen = UIScreen.main.bounds

let rihoUrl = "https://i2.kknews.cc/SIG=vanen8/66nn0002p026p2100op3.jpg"
let yuiUrl = "https://pgw.udn.com.tw/gw/photo.php?u=https://uc.udn.com.tw/photo/2018/03/06/draft/4545744.jpg&s=Y&x=307&y=3&sw=283&sh=283&sl=W&fw=360"
