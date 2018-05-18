//
//  Furigana.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/17.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//
// modified from
// https://stackoverflow.com/questions/46690337/swift-4-ctrubyannotation-dont-work

import Foundation
import UIKit
import Promises

enum JpnType {
    case noKanjiAndNumber
    case kanjiAndNumberOnly
    case mixed
}

func rubyAttrStr(_ string: String, _ ruby: String = "", fontSize: CGFloat = 20) -> NSAttributedString {
    let annotation = CTRubyAnnotationCreateWithAttributes(
        .auto, .auto, .before, ruby as CFString,
        [:] as CFDictionary)
    //[kCTForegroundColorAttributeName: UIColor.blue.cgColor] as CFDictionary)

    var font = UIFont.systemFont(ofSize: fontSize)
    if let hiraginoSan = UIFont(name: "HiraginoSans-W3", size: fontSize) {
        font = hiraginoSan
    }

    return NSAttributedString(
        string: string,
        attributes: [
            // need to use same font in CTRun or 7時 furigana will not aligned
            .font: font,
//            .font: UIFont(name: ".HiraKakuInterface-W6", size: 18.0)!,
//            .foregroundColor: UIColor.white,
//            .strokeColor: UIColor.black,
//            .strokeWidth: -1,
            kCTRubyAnnotationAttributeName as NSAttributedStringKey: annotation
        ]
    )
}

//    case 1:
//    parts: [わたし、| 気 | になります！]
//    kana: わたしきになります
//
//    case2:
//    parts: [逃 | げるは | 恥 | だが | 役 | に | 立 | つ]
//    kana: にげるははじだがやくにたつ
//    case3:
//    parts: [ブラック | 企業勤 | めのころ]
//    kana: ...
func getFuriganaAttrString(_ parts: [String], _ kana: String) -> NSMutableAttributedString {
    let attrStr = NSMutableAttributedString()
    if parts.isEmpty { return attrStr }

    if parts.count == 1 {
        let result = parts[0].jpnType == JpnType.noKanjiAndNumber ?
            rubyAttrStr(parts[0]) :
            rubyAttrStr(parts[0], kana)

        attrStr.append(result)
        return attrStr
    }

    for i in 0..<parts.count {
        if parts[i].jpnType != JpnType.noKanjiAndNumber &&
            kana.patternCount(parts[i].hiraganaOnly) != 1 {
            continue
        }

        var kanaParts = kana.components(separatedBy: parts[i].hiraganaOnly)
        kanaParts = kanaParts.filter { $0 != "" }

        if i > 0 {
            attrStr.append(getFuriganaAttrString(Array(parts[0..<i]), kanaParts[0]))
        }

        attrStr.append(rubyAttrStr(parts[i]))

        if i + 1 < parts.count {
            let suffixKanaPartsIndex = i == 0 ? 0 : 1
            attrStr.append(
                getFuriganaAttrString(Array(parts[i+1..<parts.count]), kanaParts[suffixKanaPartsIndex])
            )
        }

        return attrStr
    }

    var kanjiPart = ""
    for part in parts {
        kanjiPart += part
    }
    attrStr.append(rubyAttrStr(kanjiPart, kana))
    return attrStr
}

func getFuriganaString(tokenInfos: [[String]]) -> NSMutableAttributedString {
    let furiganaAttrStr = NSMutableAttributedString()
    for tokenInfo in tokenInfos {
        if tokenInfo.count == 8 { // number strings, ex: “307”号室
            furiganaAttrStr.append(rubyAttrStr(tokenInfo[0]))
            continue
        }
        if tokenInfo.count == 10 {
            let kanjiStr = tokenInfo[0]
            let kana = tokenInfo[8].kataganaToHiragana
            let parts = kanjiStr // [わたし、| 気 | になります！]
                .replace("([\\p{Han}\\d]*[\\p{Han}\\d])", "👻$1👻")
                .components(separatedBy: "👻")
                .filter { $0 != "" }

            furiganaAttrStr.append(getFuriganaAttrString(parts, kana))
            continue
        }
        print("unknown situation with tokenInfo: ", tokenInfo)
    }

    return furiganaAttrStr
}

extension String {

    func replace(_ pattern: String, _ template: String) -> String {
        do {
            let re = try NSRegularExpression(pattern: pattern, options: [])
            return re.stringByReplacingMatches(
                in: self,
                options: [],
                range: NSRange(location: 0, length: self.utf16.count),
                withTemplate: template)
        } catch {
            return self
        }
    }

    func patternCount(_ pattern: String) -> Int {
        return self.components(separatedBy: pattern).count - 1
    }

    var hiraganaOnly: String {
        let hiragana = self.kataganaToHiragana
        guard let hiraganaRange = hiragana.range(of: "\\p{Hiragana}*\\p{Hiragana}", options: .regularExpression)
            else { return "" }
        return String(hiragana[hiraganaRange])
    }

    var jpnType: JpnType {
        guard let kanjiRange = self.range(of: "[\\p{Han}\\d]*[\\p{Han}\\d]", options: .regularExpression) else { return JpnType.noKanjiAndNumber }

        if String(self[kanjiRange]).count == self.count {
            return JpnType.kanjiAndNumberOnly
        }
        return JpnType.mixed
    }

    var furiganaAttributedString: Promise<NSMutableAttributedString> {
        let promise = Promise<NSMutableAttributedString>.pending()

        getKanaTokenInfos(self).then {
            promise.fulfill(getFuriganaString(tokenInfos: $0))
        }
        return promise
    }

    // Hiragana: 3040-309F
    // Katakana: 30A0-30FF
    var kataganaToHiragana: String {
        var hiragana = ""
        for ch in self {
            let scalars = ch.unicodeScalars
            let chValue = scalars[scalars.startIndex].value
            if chValue >= 0x30A0 && chValue <= 0x30FF {
                if let newScalar = UnicodeScalar( chValue - 0x60) {
                    hiragana.append(Character(newScalar))
                } else {
                    print("kataganaToHiragana fail")
                }
            } else {
                hiragana.append(ch)
            }
        }
        return hiragana
    }
}
