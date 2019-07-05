//
//  kanaFix.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 10/17/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation

// MARK: Fix apple tts pronounciation Error

let ttsKanaFix: [String: String] = [
    "明日": "あした",
    "に行って": "にいって",
    "に行った": "にいった",
    "へ行って": "へいって",
    "へ行った": "へいった",
    "を行って": "をおこなって",
    "を行った": "をおこなった",
    "台湾人": "台湾じん",
    "辛い": "つらい",
    "何で": "なんで",
    "何の": "なんの",
    "何と": "なんと",
    "高すぎ": "たかすぎ",
    "後で": "あとで",
    "次いつ": "つぎいつ",
    "こちらの方": "こちらのほう",
    "米は不作": "こめは不作",
    "星野源": "ほしのげん",
    "宮城": "みやぎ",
    "原宿": "はぁらじゅく",
    "米、": "こめ、",
    "霞ケ関": "霞が関",
    "鶏肉": "とりにく",
    "欅坂46、乃木坂46": "欅坂フォーティーシックス、乃木坂フォーティーシックス",
    "二宮和也": "二宮かずなり",
    "隆盛": "たかもり",
    "博士": "はかせ",
    "私立学校": "しりつ学校",
    "強すぎ": "つよすぎ",
    "弾いて": "ひいて",
]

func getFixedKanaForTTS(_ text: String) -> String {
    var fixedText = text
    ttsKanaFix.forEach { kanji, kana in
        fixedText = fixedText.replacingOccurrences(of: kanji, with: kana)
    }
    return fixedText
}

// MARK: Fix mecab kanji to furigana error

// single word fix
var furiganaFix: [String: String] = [
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
    "深緑": "ふかみどり",
    "妹": "いもうと",
    "きょうは": "きょーわ", // 今日は vs 教派
    "弾き": "ひき", // 弾き: ひき vs はじき
    "後": "あと", // vs のち
    "昨夜": "さくや", // vs ゆうべ
    "ゆうべ": "ゆうべ",
    "誕生日": "たんじょうび", // vs たんじょーび
    "冷蔵庫": "れいぞうこ",
    "山": "やま", // vs さん
    "にんぎょう": "にんぎょー",
    "位": "くらい",
    "雨": "あめ", // vs う
    "土": "つち", // vs ど
]

func getFixedFuriganaForScore(_ token: String) -> String? {
    return furiganaFix[token]
}

// whole sentence fix by hard assign result
func doKanaCacheHardFix() {
    kanaTokenInfosCacheDictionary["大喜びだ。"] = [
        ["大", "接頭詞", "オオ", "オオ"],
        ["喜び", "名詞", "ヨロコビ", "ヨロコビ"],
        ["だ", "助動詞", "ダ", "ダ"],
    ]
}

private let threeRules = [["雪", "が", "降り", "フリ"]]

// swiftlint:disable for_where
// whole sentence fix by rules
func doKanaCacheRulesFix(kanaCache: [[String]]) -> [[String]] {
    var newCache = kanaCache
    guard kanaCache.count >= 3 else { return kanaCache }
    for i in 0 ..< kanaCache.count - 2 {
        for rule in threeRules {
            if kanaCache[i][0] == rule[0],
                kanaCache[i + 1][0] == rule[1],
                newCache[i + 2][0] == rule[2] {
                newCache[i + 2][2] = rule[3]
                newCache[i + 2][3] = rule[3]
            }
        }
    }
    return newCache
}
