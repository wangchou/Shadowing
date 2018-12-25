//
//  String+Utilities.swift
//  今話したい
//
//  Created by Wangchou Lu on 12/23/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation
import Promises

// MARK: Japanese

enum JpnType {
    case noKanjiAndNumber
    case kanjiAndNumberOnly
    case mixed
}

extension String {
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

    // https://ja.wikipedia.org/wiki/助詞
    var isImportantParticle: Bool {
        // 係助詞
        let particleGroup0 = ["は", "も", "ぞ", "なむ", "や", "か", "こそ", "によって", "にとって"]
        // 格助詞
        let particleGroup1 = ["が", "の", "を", "に", "へ", "と", "より", "から", "にて", "して", "ので", "たり", "けど"]
        // 接續助詞
        let particleGroup2 = ["ば", "とも", "ど", "ども", "が", "に", "を", "て", "して", "で", "つつ", "ながら", "ものの", "ものを", "ものから"]
        // 副助詞
        let particleGroup3 = ["だけ", "まで", "のみ", "しか", "でも", "ばかり", "くらい", "など", "ほど", "さえ", "こそ", "きり"]

        if  particleGroup0.contains(self) ||
            particleGroup1.contains(self) ||
            particleGroup2.contains(self) ||
            particleGroup3.contains(self) {
            return true
        }

        return false
    }
}

// MARK: English
private func getEnglishNumber(number: Int?) -> String {
    guard let number = number else { return "" }
    let userLocale = Locale(identifier: "en")
    let formatter = NumberFormatter()
    formatter.numberStyle = .spellOut
    formatter.locale = userLocale
    return formatter.string(from: NSNumber(value: number)) ?? ""
}

extension String {
    func spellOutNumbers() -> String {
        var tmpText = self
        let matches = self.matches(for: "[0-9]+")
        for match in matches {
            tmpText = tmpText.replace(match, getEnglishNumber(number: Int(match)))
        }
        return tmpText
    }
}

// MARK: general operation
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

    func substring(with nsrange: NSRange) -> Substring? {
        guard let range = Range(nsrange, in: self) else { return nil }
        return self[range]
    }

    var fullRange: NSRange {
        return NSRange(location: 0, length: self.count)
    }

    func padWidthTo(_ width: Int, isBothSide: Bool = false) -> String {
        let padCount = max(width - self.count, 0)

        func getEmptySpaces(_ padCount: Int) -> String {
            guard padCount > 0 else { return "" }
            var spaces = ""
            for _ in 1...padCount { spaces += " " }
            return spaces
        }

        if isBothSide {
            let leftPadCount =  padCount / 2
            let rightPadCount = padCount - leftPadCount
            return getEmptySpaces(leftPadCount) + self + getEmptySpaces(rightPadCount)
        }

        return getEmptySpaces(padCount) + self
    }
}