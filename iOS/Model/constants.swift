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
let iconSize = isIPad ? "48pt" : "24pt"

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

// safe area padding
func getTopPadding() -> CGFloat {
    if #available(iOS 11.0, *) {
        let window = UIApplication.shared.keyWindow
        return window?.safeAreaInsets.top ?? 0
    }
    return 0
}

func getBottomPadding() -> CGFloat {
    if #available(iOS 11.0, *) {
        let window = UIApplication.shared.keyWindow
        return window?.safeAreaInsets.bottom ?? 0
    }
    return 0
}

// listening duration = speakDuration + 0.4 secs
let pauseDuration: Float = 0.4
let practicePauseDuration: Float = 0.6 //longer for waiting table animation in practice

let abilities = ["日常", "旅遊", "戀愛", "名言", "N5", "N4", "敬語", "論述", "單字"]
let jaAbilities = ["日常", "旅行", "恋", "名言", "N5", "N4", "敬語", "命題", "単語"]

let medalModeKey = "Medal Mode Key"

func getBottomButtonFont() -> UIFont {
    let fontSize =  getStep() * 3
    if i18n.isJa || i18n.isZh {
        return MyFont.regular(ofSize: fontSize)
    }
    return UIFont.systemFont(ofSize: fontSize, weight: .regular)
}

func getStep() -> CGFloat {
    return screen.width/48
}

func getBottomButtonHeight() -> CGFloat {
    return max(getBottomButtonTextAreaHeight(), getBottomPadding() + 5 * getStep())
}

func getBottomButtonTextAreaHeight() -> CGFloat {
    return 7 * getStep()
}
