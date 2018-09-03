//
//  chat.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 9/3/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation

enum ChatSpeaker {
    case oren
    case hattori
    case kyoko
    case user
}

let chatDemo: [(speaker: ChatSpeaker, string: String)] = [
    (.oren, "おはよう"),
    (.user, "あ...おはようございます"),
    (.oren, "今日は早いですようね"),
    (.user, "はい、今日学校が始まります"),
    (.oren, "そうれは、よっかた"),
    (.user, "じゃ、行ってきます"),
    (.oren, "バイバイ")
]
