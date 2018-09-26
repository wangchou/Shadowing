//
//  shadowingSentences.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 9/9/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation

var translations: [String: String] = [:]

var shadowingSentences: [[String]] =
    [dailyOne, dailyTwo, travel, polite, interaction, love, expressive, random]
    .flatMap { (element: [String]) -> [String] in
        return element
    }
    .map { paragraph in
        return paragraph
        .components(separatedBy: "\n")
        .filter { s in return s != ""}
        .map { sentence in
            let subSentences = sentence.components(separatedBy: "|")
            if subSentences.count > 1 {
                translations[subSentences[0]] = subSentences[1]
            }
            return subSentences[0]
        }
    }

enum ChatSpeaker: String, Codable {
    case system = "system default"
    case oren = "com.apple.ttsbundle.siri_female_ja-JP_compact"
    case kyoko = "com.apple.ttsbundle.Kyoko-compact"
    case hattori = "com.apple.ttsbundle.siri_male_ja-JP_compact"
    case otoya = "com.apple.ttsbundle.Otoya-compact"
    case meijia = "com.apple.ttsbundle.Mei-Jia-compact"
    case user = "user"
}
