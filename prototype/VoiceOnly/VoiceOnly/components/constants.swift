//
//  constants.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/04/19.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import AVFoundation

let MeiJia = "com.apple.ttsbundle.Mei-Jia-compact"
let Otoya = "com.apple.ttsbundle.Otoya-premium"
let Kyoko = "com.apple.ttsbundle.Kyoko-premium"
let Oren = "com.apple.ttsbundle.siri_female_ja-JP_compact"
let Hattori = "com.apple.ttsbundle.siri_male_ja-JP_compact"

let I_SAY_YOU_SAY = "接下來，我說一句日文，你跟著說一句"
let CANNOT_HEAR_HINT = "聽不清楚、再一次。"
let I_HEAR_YOU_HINT = "我聽到你說："
let SPEAK_TO_ME_HINT = "請說日文給我聽"
let REPEAT_AFTER_ME_HINT = "請跟著唸日文"

let normalRate = AVSpeechUtteranceDefaultSpeechRate
let teachingRate = AVSpeechUtteranceDefaultSpeechRate * 0.7
let slowestRate = AVSpeechUtteranceDefaultSpeechRate * 0.6

let micVolumeIncreaseRate: Float = 3

var sentences: [String] = [
//    "安い",
//    "いいね",
//    "すごい",
//    "はじめまして",
//    "こんにちは",
//    "なぜですか？",
    "どうしましたか？",
    "おねさま",
    "真実はいつもひとつ！",
    "わたし、気になります！",
    "おまえはもう死んでる",
    "わーい！たーのしー！すごい！",
    "はじめまして",
    "頑張ります！",
    "はい、わかりました",
    "うるさい、うるさい！",
    "どなたですか",
    "あんたバカ？",
]
