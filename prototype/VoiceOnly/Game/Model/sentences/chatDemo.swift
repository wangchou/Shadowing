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
    (.man1, "佐藤さん"),
    (.woman1, "おはよう〜"),
    (.man1, "おはようございます。"),
    (.woman1, "今日は、早いですね。"),
    (.man1, "はい、今日学校が始まります。"),
    (.woman1, "夏休みが終わりましたか。"),
    (.man1, "はい、お先に失礼します。"),
    (.woman1, "頑張ったね")
]

let chatDemo2: [(speaker: ChatSpeaker, string: String)] = [
    (.man1, "お腹が減ったな。何か食べようかな。"),
    (.woman1, "またインスタントラーメン？野菜は食べてるの？"),
    (.man1, "ネットで安売りしてたからね。佐藤さんは手作り弁当？"),
    (.woman1, "今日は時間がなかったから作らなかった。外で食べるつもり。"),
    (.man1, "じゃあ帰りに肉まんを買って来てよ。"),
    (.woman1, "肉まんも食べるの？")
]
