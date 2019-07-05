//
//  String+.swift
//  processVOC
//
//  Created by Wangchou Lu on 5/15/31 H.
//  Copyright © 31 Heisei Lu, WangChou. All rights reserved.
//

import Foundation

extension String {
    func trimSuffix(_ count: Int) -> String {
        guard self.count > count else { return self }
        return String(prefix(self.count - count))
    }

    func trimPrefix(_ count: Int) -> String {
        guard self.count > count else { return self }
        return String(suffix(self.count - count))
    }

    var isDigit: Bool {
        return Int(
            replacingOccurrences(of: ",", with: "")
                .replacingOccurrences(of: ".", with: "")
                .replacingOccurrences(of: "th", with: "")
                .replacingOccurrences(of: "st", with: "")
                .replacingOccurrences(of: "nd", with: "")
                .replacingOccurrences(of: "rd", with: "")

        ) != nil
    }

    var variations: [String] {
        var word = self
        if word.hasSuffix(".") {
            word = word.trimSuffix(1)
        }

        var words: [String] = []
        // Prefix
        if word.hasPrefix("un") || word.hasPrefix("im") || word.hasPrefix("in") {
            words = [word.trimPrefix(2)]
        }
        // suffix

        if word.hasSuffix(".") {
            words = [word.trimSuffix(1)]
        }

        if word.hasSuffix("ily") {
            words = [word.trimSuffix(3) + "y"]
        } else if word.hasSuffix("ly") {
            words = [word.trimSuffix(2), word.trimSuffix(2) + "e", word.trimSuffix(1) + "e"]
        }
        if word.hasSuffix("ing") {
            words = [word.trimSuffix(3), word.trimSuffix(4), word.trimSuffix(3) + "e"]
        }
        if word.hasSuffix("ied") {
            words = [word.trimSuffix(3) + "y"]
        } else if word.hasSuffix("ed") {
            words = [word.trimSuffix(2), word.trimSuffix(1)]
        }
        if word.hasSuffix("ier") {
            words = [word.trimSuffix(3) + "y"]
        } else if word.hasSuffix("er") {
            words = [word.trimSuffix(2), word.trimSuffix(3)] // higher, swimmer
        }
        if word.hasSuffix("iest") {
            words = [word.trimSuffix(4) + "y"]
        } else if word.hasSuffix("est") {
            words = [word.trimSuffix(3)]
        }
        if word.hasSuffix("iness") {
            words = [word.trimSuffix(5) + "y"]
        } else if word.hasSuffix("ness") {
            words = [word.trimSuffix(4)]
        } else if word.hasSuffix("less") {
            words = [word.trimSuffix(4)]
        } else if word.hasSuffix("es") {
            words = [word.trimSuffix(2)]
        } else if word.hasSuffix("s") {
            words = [word.trimSuffix(1)]
        }
        words.append(word)
        return words
    }
}
