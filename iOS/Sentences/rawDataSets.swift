//
//  shadowingSentences.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 9/9/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation

var chTranslations: [String: String] = [:]

var datasetKeyToTags: [String: [String]] = [:]
private var tags: [String] = []
var rawDataSets: [[String]] =
    //[dailyOne, expressive, travel, polite, love, speech, vocabulary1, vocabulary2]
    [inWork]
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
                chTranslations[subSentences[0]] = subSentences[1]
            }
            return subSentences[0]
        }

        if !sentences.isEmpty {
            datasetKeyToTags[sentences[0]] = currentTags
        }

        return sentences
    }
