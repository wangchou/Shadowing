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
    "何時": "なんじ"
]
func findKanaFix(_ token: String) -> String? {
    return kanaFix[token]
}
