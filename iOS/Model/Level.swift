//
//  Level.swift
//  今話したい
//
//  Created by Wangchou Lu on 10/24/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import UIKit
import AVFoundation

var avgKanaCountDict: [String: Float] = [:]
// for ja
private let minKanaCounts = [2, 7, 10, 12, 14, 16, 19, 23, 27, 32]
private let maxKanaCounts = [6, 9, 11, 13, 15, 18, 22, 26, 31, 40]
//for en
private let minSyllablesCounts = [1, 4, 6, 8, 10, 12, 14, 17, 20, 24]
private let maxSyllablesCounts = [3, 5, 7, 9, 11, 13, 16, 19, 23, 30]

private let colors = [myRed, myRed, myOrange, myOrange, myGreen, myGreen, myBlue, myBlue, myPurple, myPurple]
private let titles = ["入門一", "入門二", "初級一", "初級二",
                      "中級一", "中級二", "上級一", "上級二", "超難問一", "超難問二"]
let allLevels: [Level] = [.lv0, .lv1, .lv2, .lv3, .lv4, .lv5, .lv6, .lv7, .lv8, .lv9]

func getLevel(avgSyllablesCount: Float) -> Level {
    for i in 0..<allLevels.count where avgSyllablesCount < (allLevels[i].maxSyllablesCount.f + 1) {
        return allLevels[i]
    }
    return Level.lv9
}

enum Level: Int, Codable {
    case lv0=0, lv1=1, lv2=2, lv3=3, lv4=4, lv5=5, lv6=6, lv7=7, lv8=8, lv9=9

    var next: Level {
        return Level(rawValue: (self.rawValue + 1) % 10)!
    }

    var previous: Level {
        return Level(rawValue: (self.rawValue + 9) % 10)!
    }

    var color: UIColor {
        return colors[self.rawValue]
    }

    var lockPercentage: Float {
        switch self {
        case .lv0:
            return 75
        case .lv1:
            return 80
        case .lv2:
            return 85
        default:
            return 90
        }
    }

    var minSyllablesCount: Int {
        return gameLang == .jp ? minKanaCounts[self.rawValue] : minSyllablesCounts[self.rawValue]
    }

    var maxSyllablesCount: Int {
        return gameLang == .jp ? maxKanaCounts[self.rawValue] : maxSyllablesCounts[self.rawValue]
    }

    var infinteChallengeDatasetKey: String {
        return "Level DataSet Key \(self.rawValue)\(gameLang.key)"
    }

    var title: String {
        return titles[self.rawValue]
    }

    var character: String {
        return title.prefix(1).s
    }

    var bestInfinteChallengeRank: String? {
        return findBestRecord(key: self.infinteChallengeDatasetKey)?.rank.rawValue
    }

    var bestInfinteChallengeProgress: String? {
        return findBestRecord(key: self.infinteChallengeDatasetKey)?.progress
    }

    var autoSpeed: Float {
        return AVSpeechUtteranceDefaultSpeechRate * min(1.1, (0.5 + Float(self.rawValue) * 0.07))
    }
}

enum Rank: String, Codable {
    case ss = "SS"
    case s = "S"
    case aP = "A+"
    case a = "A"
    case bP = "B+"
    case b = "B"
    case c = "C"
    case d = "D"
    case e = "E"
    case f = "F"

    var color: UIColor {
        switch self {
        case .s, .ss:
            return myBlue
        case .aP, .a, .bP :
            return myGreen
        case .b, .c, .d:
            return myOrange
        case .e, .f:
            return myRed
        }
    }
}
