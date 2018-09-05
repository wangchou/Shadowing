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

// fonts
// .HiraKakuInterface-W2
// HiraKakuProN-W3
// HiraginoSans-W3
// HiraMinProN-W6
func rubyAttrStr(
    _ string: String,
    _ ruby: String = "",
    fontSize: CGFloat = 20,
    color: UIColor = .black
    ) -> NSAttributedString {
//    print("main=\(string), ruby=\(ruby)")
    let fontRuby = MyFont.thin(ofSize: fontSize/2)
    let fontRegular = MyFont.regular(ofSize: fontSize)
    let fontBold = MyFont.bold(ofSize: fontSize)

    let alignMode: CTRubyAlignment = ruby.count >= string.count * 2 ? .center : .auto
    let annotation = CTRubyAnnotationCreateWithAttributes(
        alignMode, .auto, .before, ruby as CFString,
        [ kCTFontAttributeName: fontRuby ] as CFDictionary
    )

    let isSpecial = color != .black
    if !isSpecial {
        return NSAttributedString(
            string: string,
            attributes: [
                .font: fontRegular,
                .foregroundColor: color,
                kCTRubyAnnotationAttributeName as NSAttributedStringKey: annotation
            ]
        )
    } else {
        return NSAttributedString(
            string: string,
            attributes: [
                .font: fontBold,
                .foregroundColor: color,
                .strokeColor: UIColor.black,
                .strokeWidth: -1.5,
                kCTRubyAnnotationAttributeName as NSAttributedStringKey: annotation
        ])
    }

}

func testGetFurigana() {
    _ = "本命チョコ、義理チョコ".furiganaAttributedString
    _ = "男の子女の子".furiganaAttributedString
    _ = "わたし、気になります！".furiganaAttributedString
    _ = "逃げるは恥だが役に立つ".furiganaAttributedString
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
//    case4:
//    parts: [男 | の | 子女 | の | 子]
//    kana: おとこのこおんなのこ
func getFuriganaAttrString(_ parts: [String], _ kana: String, color: UIColor = .black) -> NSMutableAttributedString {
    let attrStr = NSMutableAttributedString()
    if parts.isEmpty { return attrStr }

    if parts.count == 1 {
        let result = parts[0].jpnType == JpnType.noKanjiAndNumber ?
            rubyAttrStr(parts[0], color: color) :
            rubyAttrStr(parts[0], kana, color: color)

        attrStr.append(result)
        return attrStr
    }

    for dividerIndex in 0..<parts.count {
        let divider = parts[dividerIndex]
        guard divider.jpnType == JpnType.noKanjiAndNumber &&
            kana.patternCount(divider.hiraganaOnly) == (parts.filter {$0.hiraganaOnly == divider.hiraganaOnly}).count
            else {
            continue
        }

        guard let range = kana.range(of: divider.hiraganaOnly) else { continue }

        // before divider part
        if dividerIndex > 0 {
            attrStr.append(getFuriganaAttrString(parts[..<dividerIndex].a, kana[..<range.lowerBound].s))
        }

        // divider
        attrStr.append(rubyAttrStr(divider, color: color))

        // after divider part
        if dividerIndex + 1 < parts.count {
            attrStr.append(getFuriganaAttrString(parts[(dividerIndex+1)...].a, kana[range.upperBound...].s))
        }

        return attrStr
    }

    attrStr.append(rubyAttrStr(parts.joined(), kana, color: color))
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
            let color: UIColor = (tokenInfo[1] == "助詞" &&
                                  (kana == "は" || kana == "が" || kana == "と" ||
                                   kana == "で" || kana == "に" || kana == "を"))
                                    ? myWaterBlue : .black

            furiganaAttrStr.append(getFuriganaAttrString(parts, kana, color: color))
            continue
        }
        print("unknown situation with tokenInfo: ", tokenInfo)
    }

    return furiganaAttrStr
}

extension Substring {
    var s: String { return String(self) }
}

extension ArraySlice {
    var a: [Element] { return Array(self) }
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
