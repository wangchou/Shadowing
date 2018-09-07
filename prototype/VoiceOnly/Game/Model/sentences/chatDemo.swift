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
}

let chatDemo: [(speaker: ChatSpeaker, string: String)] = [
    (.man1, "佐藤さん、こんにちは"),
    (.woman1, "こんにちは"),
    (.man1, "今日は、いい天気ですね"),
    (.woman1, "そうですね"),
    (.man1, "最近お元気ですか？"),
    (.woman1, "ええ、元気ですよ"),
    (.man1, "今日はどちらへ？"),
    (.woman1, "ちょっと買い物に"),
    (.man1, "次の水曜日、一緒にカラオケへ行きませんか？"),
    (.woman1, "いいですよ、ぜひ"),
    (.man1, "じゃ、お先に失礼します"),
    (.woman1, "じゃ、また。")
]

let chatDemo2: [(speaker: ChatSpeaker, string: String)] = [
    (.man1, "お腹が減ったな。何か食べようかな。"),
    (.woman1, "またインスタントラーメン？野菜は食べてるの？"),
    (.man1, "ネットで安売りしてたからね。佐藤さんは手作り弁当？"),
    (.woman1, "今日は時間がなかったから作らなかった。外で食べるつもり。"),
    (.man1, "じゃあ帰りに肉まんを買って来てよ。"),
    (.woman1, "肉まんも食べるの？")
]
