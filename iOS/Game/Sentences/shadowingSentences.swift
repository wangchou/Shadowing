//
//  shadowingSentences.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 9/9/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation

var translations: [String: String] = [:]

var datasetKeyToTags: [String: [String]] = [:]
var tags: [String] = []
var shadowingSentences: [[String]] =
    [dailyOne, expressive, travel, polite, love, speech]
    .flatMap { (element: [String]) -> [String] in
        return element
    }
    .map { paragraph in
        var currentTags: [String] = []
        let sentences: [String] = paragraph
        .components(separatedBy: "\n")
        .filter {s in
            if s.contains("#") {
                s.matches(for: "#[^ ]+")
                 .forEach { s in
                    if !tags.contains(s) {
                        tags.append(s)
                    }
                    currentTags.append(s)
                 }
                return false
            }
            return s != ""
        }.map { sentence in
            let subSentences = sentence.components(separatedBy: "|")
            if subSentences.count > 1 {
                translations[subSentences[0]] = subSentences[1]
            }
            return subSentences[0]
        }

        if !sentences.isEmpty {
            datasetKeyToTags[sentences[0]] = currentTags
        }

        return sentences
    }

enum ChatSpeaker: String, Codable {
    case system = "system default"
    case oren = "com.apple.ttsbundle.siri_female_ja-JP_compact"
    case kyoko = "com.apple.ttsbundle.Kyoko-compact"
    case kyokoPremium = "com.apple.ttsbundle.Kyoko-premium"
    case hattori = "com.apple.ttsbundle.siri_male_ja-JP_compact"
    case otoya = "com.apple.ttsbundle.Otoya-compact"
    case otoyaPremium = "com.apple.ttsbundle.Otoya-premium"
    case meijia = "com.apple.ttsbundle.Mei-Jia-compact"
    case user = "user"
}
