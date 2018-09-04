//
//  chat.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 9/3/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation

enum ChatSpeaker: String {
    case oren
    case hattori
    case kyoko
}

let chatDemo: [(speaker: ChatSpeaker, string: String)] = [
    (.oren, "おはよう〜"),
    (.hattori, "おはようございます。"),
    (.oren, "今日は、早いですね。"),
    (.hattori, "はい、今日学校が始まります。"),
    (.oren, "そうか。"),
    (.hattori, "じゃ、お先に。"),
    (.oren, "バイバイ。")
]
