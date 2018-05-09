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

let HARUHI = "ただの人間には興味ありません。この中に宇宙人、未来人、異世界人、超能力者がいたら、あたしのところに来なさい。以上。"

let normalRate = AVSpeechUtteranceDefaultSpeechRate
let slowestRate = AVSpeechUtteranceDefaultSpeechRate * 0.6

// it's bad when monitoring at street
// if in quite place. turn micOutVolume to 3
let micOutVolume: Float = 0



