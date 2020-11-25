//
//  Level.swift
//  今話したい
//
//  Created by Wangchou Lu on 10/24/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import AVFoundation
import UIKit

var avgKanaCountDict: [String: Float] = [:]
// for ja
private let minKanaCounts = [2, 7, 10, 12, 14, 16, 19, 23, 27, 31, 34, 37]
private let maxKanaCounts = [6, 9, 11, 13, 15, 18, 22, 26, 30, 33, 36, 40]
// for en
private let minSyllablesCounts = [1, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 27]
private let maxSyllablesCounts = [5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 26, 31]

private let colors = [myRed, myRed, myOrange, myOrange,
                      myGreen, myGreen, myBlue, myBlue,
                      myPurple, myPurple, myPurple, myPurple]

private let titles = ["入門一", "入門二", "初級一", "初級二",
                      "中級一", "中級二", "上級一", "上級二",
                      "超難問一", "超難問二", "超難問三", "超難問四"]

private let enTitles = ["Level 1", "Level 2", "Level 3", "Level 4",
                        "Level 5", "Level 6", "Level 7", "Level 8",
                        "Level 9", "Level 10", "Level 11", "Level 12"]
let allLevels: [Level] = [.lv0, .lv1, .lv2, .lv3, .lv4, .lv5, .lv6, .lv7, .lv8, .lv9, .lv10, .lv11]

enum Level: Int, Codable {
    case lv0, lv1, lv2, lv3, lv4, lv5, lv6, lv7, lv8, lv9, lv10, lv11

    init(medalCount: Int) {
        let lvl = medalCount / medalsPerLevel
        self = Level(rawValue: lvl) ?? .lv11
    }

    init(avgSyllablesCount: Float) {
        for i in 0 ..< allLevels.count where avgSyllablesCount < (allLevels[i].maxSyllablesCount.f + 1) {
            self = allLevels[i]
            return
        }
        self = Level.lv11
    }

    var levelCount: Int {
        return allLevels.count
    }

    var next: Level {
        return Level(rawValue: (rawValue + 1) % levelCount)!
    }

    var previous: Level {
        return Level(rawValue: (rawValue + levelCount - 1) % levelCount)!
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
        return "Level DataSet Key \(rawValue)\(gameLang.key)"
    }

    var title: String {
        if i18n.isJa || i18n.isZh {
            return titles[self.rawValue]
        }
        return enTitles[self.rawValue]
    }

    var lvlTitle: String {
        return "Lv.\(rawValue + 1)"
    }

    var character: String {
        if i18n.isJa || i18n.isZh {
            return title.prefix(1).s
        }
        return "L\(title.suffix(1).s)"
    }

    var bestInfinteChallengeRank: String? {
        return findBestRecord(dataSetKey: infinteChallengeDatasetKey)?.rank.rawValue
    }

    var bestInfinteChallengeProgress: String? {
        return findBestRecord(dataSetKey: infinteChallengeDatasetKey)?.progress
    }
}

enum Rank: String, Codable {
    case ss = "SS"
    case s = "S"
    case aP = "A+"
    case a = "A"
    case bP = "B+"
    case b = "B"
    case cP = "C+"
    case c = "C"
    case d = "D"
    case e = "E"
    case f = "F"

    var color: UIColor {
        switch self {
        case .s, .ss:
            return myBlue
        case .aP, .a, .bP:
            return myGreen
        case .b, .cP, .c, .d:
            return myOrange
        case .e, .f:
            return myRed
        }
    }
}
