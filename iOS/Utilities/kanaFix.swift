//
//  kanaFix.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 10/17/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation
import Promises

// MARK: Fix apple tts pronounciation Error

let ttsGlobalFixes: [(String, String)] = [
    // newly added
    ("一人前", "いちにんまえ"),
    ("フランス人", "フランスじん"),
    ("アメリカ人", "アメリカじん"),
    ("イタリア人", "イタリアじん"),
    ("ロシア人", "ロシアじん"),
    ("ブラジル人", "ブラジルじん"),
    ("イギリス人", "イギリスじん"),
    ("露語", "ろ語"),
    ("断った", "ことわった"),
    ("低すぎ", "ひくすぎ"),
    ("弾く", "ひく"),
    ("何だ", "なんだ"),
    ("何て", "なんて"),
    ("今学期", "こん学期"),
    ("一日", "いちにち"),
    ("床板", "ゆかいた"),
    ("緑色", "みどりいろ"),
    ("灯火", "とうか"),
    ("一曲", "いっきょく"),
    ("一足", "いっそく"),
    ("三匹", "さんびき"),
    ("6匹", "ろっぴき"),
    ("七時", "しちじ"),
    ("一冊", "いっさつ"),
    ("1冊", "いっさつ"),
    ("一軒", "いっけん"),
    ("真っ暗", "まっくら"),
    ("1曲", "いっきょく"),
    ("多すぎ", "おおすぎ"),
    ("弾き", "ひき"),
    ("難しすぎ", "むずかしすぎ"),
    ("ブドウ酒", "ブドウしゅ"),
    ("弾け", "ひけ"),
    ("西方", "せいほう"),
    ("真ん前", "まん前"),
    ("遅すぎ", "おそすぎ"),
    ("間に合", "まに合"),
    ("弾ける", "ひける"),
    ("その後", "そのあと"),
    ("木の下", "きのした"),
    ("国中", "くにじゅう"),
    ("大火事", "おおかじ"),
    ("小船", "こぶね"),
    ("今夕", "こんせき"),
    ("村中", "むらじゅう"),
    ("百歳", "ひゃくさい"),
    ("観に", "みに"),
    ("道々", "みちみち"),
    ("二、三日", "にさんにち"),
    ("2、3日", "にさんにち"),
    ("花々", "はなばな"),
    ("何杯", "なんばい"),
    ("何匹", "なんびき"),
    ("僕等", "ぼくら"),
    ("異母妹", "いぼまい"),
    ("風呂場", "ふろば"),
    ("一箱", "ひと箱"),
    ("1箱", "ひと箱"),
    ("一種", "いっしゅ"),
    ("1種", "いっしゅ"),
    ("若すぎ", "わかすぎ"),
    ("一瓶", "ひとびん"),
    ("1瓶", "ひとびん"),
    ("三杯", "さんばい"),
    ("出来る", "できる"),
    ("来る", "くる"),
    ("港市", "こうし"),
    ("弾いた", "ひいた"),
    ("小猫", "こねこ"),
    ("洗濯物", "せんたくもの"),
    ("剣歯虎", "けんしこ"),
    ("1日中", "いちにちじゅう"),
    ("一匹", "いっぴき"),
    ("1匹", "いっぴき"),
    ("私立", "しりつ"),
    ("九時", "くじ"),
    ("釣に", "つりに"),
    ("大地震", "おおじしん"),
    ("玩具", "おもちゃ"),

    //old
    ("明日", "あした"),
    ("に行って", "にいって"),
    ("に行った", "にいった"),
    ("へ行って", "へいって"),
    ("へ行った", "へいった"),
    ("を行って", "をおこなって"),
    ("を行った", "をおこなった"),
    ("台湾人", "台湾じん"),
    ("辛い", "つらい"),
    ("何で", "なんで"),
    ("何の", "なんの"),
    ("何と", "なんと"),
    ("高すぎ", "タカすぎ"),
    ("後で", "あとで"),
    ("次いつ", "つぎいつ"),
    ("こちらの方", "こちらのほう"),
    ("米は不作", "こめは不作"),
    ("星野源", "ほしのげん"),
    ("宮城", "みやぎ"),
    ("原宿", "はぁらじゅく"),
    ("米、", "こめ、"),
    ("霞ケ関", "霞が関"),
    ("鶏肉", "とりにく"),
    ("欅坂46、乃木坂46", "欅坂フォーティーシックス、乃木坂フォーティーシックス"),
    ("二宮和也", "二宮かずなり"),
    ("隆盛", "たかもり"),
    ("博士", "はかせ"),
    ("私立学校", "しりつ学校"),
    ("強すぎ", "つよすぎ"),
    ("弾いて", "ひいて"),
]

func getUpdateTextMap(map: [Int],
                     ranges: [(lower: Int, upper: Int)],
                     fixString: String) -> [Int] {
    var newMap: [Int] = map
    //replace from upper ranges
    ranges.reversed().forEach { range in
        newMap.replaceSubrange(range.lower ..< range.upper,
                              with: repeatElement(map[range.upper - 1], count: fixString.count))
    }
    return newMap
}

func getFixedTTSString(_ text: String, localFixes: [(String, String)] = [], isJP: Bool = true) -> Promise<(String, [Int])> {
    let promise = Promise<(String, [Int])>.pending()
    guard isJP else {
        promise.fulfill((text, Array(0 ..< text.count)))
        return promise
    }

    var fixedText = ""
    getKanaTokenInfos(text, originalString: text).then { tokenInfos in
        tokenInfos.forEach { tokenInfo in
            fixedText += tokenInfo[0]
        }

        var allFixes = localFixes
        allFixes.append(contentsOf: ttsGlobalFixes)

        var ttsToDisplayMap = Array(0 ..< fixedText.count)
        allFixes.forEach { kanji, fix in
            let ranges = fixedText.ranges(of: kanji)
            if !ranges.isEmpty {
//                if(kanji.count != fix.count) {
//                    print(fixedText, fixedText.count)
//                }
                ttsToDisplayMap = getUpdateTextMap(map: ttsToDisplayMap,
                                                  ranges: ranges,
                                                  fixString: fix)
                fixedText = fixedText.replacingOccurrences(of: kanji, with: fix)
//                if(kanji.count != fix.count) {
//                    print("\t\(kanji) -> \(fix)", ranges)
//                    print("\t ttsMap(\(ttsToDisplayMap.count)) :", ttsToDisplayMap)
//                    print("\t ttsText(\(fixedText.count)):", fixedText)
//                }
            }
        }

        promise.fulfill((fixedText, ttsToDisplayMap))
    }

    return promise
}

// MARK: Fix mecab kanji to furigana error

extension StringProtocol {
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [(lower: Int, upper: Int)] {
        var result: [Range<String.Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                result.append(range)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result.map { range in
            let boundPair = (
                lower: self.distance(from: self.startIndex, to: range.lowerBound),
                upper: self.distance(from: self.startIndex, to: range.upperBound)
            )
            return boundPair
        }
    }
}
