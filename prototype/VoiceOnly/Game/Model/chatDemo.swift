//
//  chat.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 9/3/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation

enum ChatSpeaker: String {
    case woman1
    case woman2
    case man1
    case man2
    case narrator
    case user
}

let chatDemo: [(speaker: ChatSpeaker, string: String)] = [
    (.man1, "佐藤さん、こんにちは"),
    (.user, "こんにちは"),
    (.man1, "今日は、いい天気ですね"),
    (.user, "そうですね"),
    (.man1, "最近お元気ですか？"),
    (.user, "ええ、元気ですよ"),
    (.man1, "今日はどちらへ？"),
    (.user, "ちょっと買い物に"),
    (.man1, "次の水曜日、一緒にカラオケへ行きませんか？"),
    (.user, "いいですよ、ぜひ"),
    (.man1, "じゃ、お先に失礼します"),
    (.user, "じゃ、また。")
]
