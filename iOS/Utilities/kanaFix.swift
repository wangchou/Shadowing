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
    "涼": "すず",
    "源": "げん",
    "魚": "さかな",
    "蔵前": "くらまえ",
    "油": "あぶら",
    "鏡": "かがみ",
    "湖": "みずうみ",
    "鶏肉": "とりにく",
    "欅坂46": "けやきざかフォーティーシックス",
    "乃木坂46": "のぎざかフォーティーシックス",
    "隆盛": "たかもり",
    "深緑": "ふかみどり"
]
func findKanaFix(_ token: String) -> String? {
    return kanaFix[token]
}
