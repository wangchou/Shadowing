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
    "米": "こめ"
]
func findKanaFix(_ token: String) -> String? {
    return kanaFix[token]
}
