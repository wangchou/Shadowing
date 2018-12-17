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
import Promises

enum JpnType {
    case noKanjiAndNumber
    case kanjiAndNumberOnly
    case mixed
}

#if os(iOS)
import UIKit

// fonts
// .HiraKakuInterface-W2
// HiraKakuProN-W3
// HiraginoSans-W3
// HiraMinProN-W6
func rubyAttrStr(
    _ string: String,
    _ ruby: String = "",
    fontSize: CGFloat = 20,
    color: UIColor = .black,
    isWithStroke: Bool = false,
    backgroundColor: UIColor = .clear
    ) -> NSAttributedString {

    let fontRuby = MyFont.thin(ofSize: fontSize/2)
    let fontRegular = MyFont.regular(ofSize: fontSize)
    let fontBold = MyFont.bold(ofSize: fontSize)

    let alignMode: CTRubyAlignment = ruby.count >= string.count * 2 ? .center : .auto
    let annotation = CTRubyAnnotationCreateWithAttributes(
        alignMode, .auto, .before, ruby as CFString,
        [ kCTFontAttributeName: fontRuby ] as CFDictionary
    )

    if color == .black || !isWithStroke {
        return NSAttributedString(
            string: string,
            attributes: [
                .font: fontRegular,
                .foregroundColor: color,
                .backgroundColor: backgroundColor,
                kCTRubyAnnotationAttributeName as NSAttributedString.Key: annotation
            ]
        )
    } else {
        return NSAttributedString(
            string: string,
            attributes: [
                .font: fontBold,
                .foregroundColor: color,
                .backgroundColor: backgroundColor,
                .strokeColor: UIColor.black,
                .strokeWidth: -1.5,
                kCTRubyAnnotationAttributeName as NSAttributedString.Key: annotation
        ])
    }

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
func getFuriganaAttrString(_ parts: [String],
                           _ kana: String,
                           color: UIColor = .black,
                           highlightRange: NSRange? = nil
                           ) -> NSMutableAttributedString {

    var currentIndex = 0
    func isInRange() -> Bool {
        guard let r = highlightRange else { return false }
        return r.contains(currentIndex)
    }
    func getBackgroundColor() -> UIColor {
        return isInRange() ? highlightColor : .clear
    }

    let attrStr = NSMutableAttributedString()

    if parts.isEmpty { return attrStr }

    if parts.count == 1 {
        let backgroundColor = getBackgroundColor()
        let result = parts[0].jpnType == JpnType.noKanjiAndNumber ?
            rubyAttrStr(parts[0], color: color, isWithStroke: color != .black, backgroundColor: backgroundColor ) :
            rubyAttrStr(parts[0], kana, color: color, isWithStroke: color != .black, backgroundColor: backgroundColor)

        attrStr.append(result)
        return attrStr
    }

    // divider is first "kanji or number part" in parts
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
            attrStr.append(getFuriganaAttrString(
                parts[..<dividerIndex].a,
                kana[..<range.lowerBound].s,
                highlightRange: highlightRange?.subRange(startIndex: currentIndex)
            ))
            currentIndex += parts[..<dividerIndex].a.reduce(0, { result, part in
                return result + part.count
            })
        }

        // divider
        attrStr.append(rubyAttrStr(divider, color: color, isWithStroke: color != .black, backgroundColor: getBackgroundColor()))
        currentIndex += parts[dividerIndex].count

        // after divider part
        if dividerIndex + 1 < parts.count {
            attrStr.append(getFuriganaAttrString(
                parts[(dividerIndex+1)...].a,
                kana[range.upperBound...].s,
                highlightRange: highlightRange?.subRange(startIndex: currentIndex)))
        }

        return attrStr
    }

    attrStr.append(rubyAttrStr(parts.joined(), kana, color: color))
    return attrStr
}

extension NSRange {
    // subRange from startIndex of old string
    func subRange(startIndex: Int) -> NSRange? {
        guard startIndex < self.upperBound else { return nil }

        return NSRange(
            location: max(self.lowerBound - startIndex, 0),
            length: self.upperBound - startIndex)
    }
}

// tokenInfo = [kanji, 詞性, furikana, yomikana]
func getFuriganaString(tokenInfos: [[String]], highlightRange: NSRange? = nil) -> NSMutableAttributedString {
    let furiganaAttrStr = NSMutableAttributedString()
    var currentIndex = 0
    func isInRange() -> Bool {
        guard let r = highlightRange else { return false }
        return r.contains(currentIndex)
    }
    for tokenInfo in tokenInfos {
        if tokenInfo.last == "*" { // number strings, ex: “307”号室
            furiganaAttrStr.append(rubyAttrStr(tokenInfo[0], backgroundColor: isInRange() ? highlightColor : .clear))
        } else {
            let kanjiStr = tokenInfo[0]
            let kana = getFixedFuriganaForScore(kanjiStr) ?? tokenInfo[tokenInfo.count-2].kataganaToHiragana
            let parts = kanjiStr // [わたし、| 気 | になります！]
                .replace("([\\p{Han}\\d]*[\\p{Han}\\d])", "👻$1👻")
                .components(separatedBy: "👻")
                .filter { $0 != "" }
            let color: UIColor = (tokenInfo[1] == "助詞" &&
                                  (kana == "は" || kana == "が" || kana == "と" ||
                                   kana == "で" || kana == "に" || kana == "を" ||
                                   kana == "へ" || kana == "て"))
                                    ? myWaterBlue : .black

            furiganaAttrStr.append(getFuriganaAttrString(
                parts,
                kana,
                color: color,
                highlightRange: highlightRange?.subRange(startIndex: currentIndex)))
        }
        currentIndex += tokenInfo[0].count
    }

    return furiganaAttrStr
}
#else
// OSX code
#endif

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

    func spellOutNumbers() -> String {
        var tmpText = self
        let matches = self.matches(for: "[0-9]+")
        for match in matches {
            tmpText = tmpText.replace(match, getEnglishNumber(number: Int(match)))
        }
        return tmpText
    }

    func patternCount(_ pattern: String) -> Int {
        return self.components(separatedBy: pattern).count - 1
    }

    // https://stackoverflow.com/questions/27880650/swift-extract-regex-matches
    func matches(for regex: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: self,
                                        range: NSRange(self.startIndex..., in: self))
            return results.compactMap {
                Range($0.range, in: self).map { String(self[$0]) }
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }

    var hiraganaOnly: String {
        let hiragana = self.kataganaToHiragana
        guard let hiraganaRange = hiragana.range(of: "[\\p{Hiragana}ー]*[\\p{Hiragana}ー]", options: .regularExpression)
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
    #if os(iOS)
    var furiganaAttributedString: Promise<NSMutableAttributedString> {
        let promise = Promise<NSMutableAttributedString>.pending()

        getKanaTokenInfos(self).then {
            promise.fulfill(getFuriganaString(tokenInfos: $0))
        }

        return promise
    }
    #endif

    // Hiragana: 3040-309F
    // Katakana: 30A0-30FF
    var kataganaToHiragana: String {
        var hiragana = ""
        for ch in self {
            let scalars = ch.unicodeScalars
            let chValue = scalars[scalars.startIndex].value
            // 30FC is 長音（ー）there is no match in hiragana
            if chValue >= 0x30A0 && chValue <= 0x30FB {
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


    func substring(with nsrange: NSRange) -> Substring? {
        guard let range = Range(nsrange, in: self) else { return nil }
        return self[range]
    }
}
