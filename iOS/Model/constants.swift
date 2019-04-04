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

let IDIOM = UI_USER_INTERFACE_IDIOM()
let isIPad = IDIOM == UIUserInterfaceIdiom.pad

#if targetEnvironment(simulator)
    let isSimulator = true
    let dailyFreeLimit = 1000
#else
    let isSimulator = false
    let dailyFreeLimit = 100
#endif

let normalRate = AVSpeechUtteranceDefaultSpeechRate
let fastRate = AVSpeechUtteranceDefaultSpeechRate * 1.1

// it's bad when monitoring at street
// if in quite place. turn micOutVolume to 3
let micOutVolume: Float = 0

let screen = UIScreen.main.bounds

// listening duration = speakDuration + 0.4 secs
let pauseDuration: Float = 0.4
let practicePauseDuration: Float = 0.6 //longer for waiting table animation in practice

let abilities = ["日常", "旅遊", "N5", "N4", "敬語", "戀愛", "論述", "單字"]

let medalModeKey = "Medal Mode Key"
