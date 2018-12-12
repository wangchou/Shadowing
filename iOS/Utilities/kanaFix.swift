//
//  kanaFix.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 10/17/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation

// fix mecab yomi error
var kanaFix: [String: String] = [
    "何時": "なんじ",
    "という": "トイウ",
    "事": "こと",
    "1日": "いちにち",
    "会い": "あい",
    "次": "つぎ",
    "米": "こめ",
    "涼": "スズ",
    "源": "ゲン",
    "魚": "サカナ",
    "蔵前": "クラマエ",
    "油": "アブラ",
    "鏡": "カガミ",
    "湖": "ミズウミ",
    "鶏肉": "とりにく",
    "欅坂46": "けやきざかフォーティーシックス",
    "乃木坂46": "のぎざかフォーティーシックス"
]
func findKanaFix(_ token: String) -> String? {
    return kanaFix[token]
}
