//
//  Level.swift
//  今話したい
//
//  Created by Wangchou Lu on 10/24/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import UIKit

var avgKanaCountDict: [String: Int] = [:]
private let minKanaCounts = [2, 7, 9, 12, 15, 17, 19, 22, 27]
private let maxKanaCounts = [6, 8, 11, 14, 16, 18, 21, 26, 36]
private let colors = [myRed, myRed, myOrange, myOrange, myGreen, myGreen, myBlue, myBlue, .purple]
private let titles = ["入門一", "入門二", "初級一", "初級二",
                      "中級一", "中級二", "上級一", "上級二", "超難問"]
let allLevels: [Level] = [.lv0, .lv1, .lv2, .lv3, .lv4, .lv5, .lv6, .lv7, .lv8]

func getLevel(avgKanaCount: Int) -> Level {
    for i in 0..<allLevels.count where avgKanaCount <= maxKanaCounts[i] {
        return allLevels[i]
    }
    return Level.lv8
}

enum Level: Int, Codable {
    case lv0=0, lv1=1, lv2=2, lv3=3, lv4=4, lv5=5, lv6=6, lv7=7, lv8=8
    var color: UIColor {
        return colors[self.rawValue]
    }

    var minKanaCount: Int {
        return minKanaCounts[self.rawValue]
    }

    var maxKanaCount: Int {
        return maxKanaCounts[self.rawValue]
    }

    var infinteChallengeDatasetKey: String {
        return "Level DataSet Key \(self.rawValue)"
    }

    var title: String {
        return titles[self.rawValue]
    }

    var character: String {
        return title.prefix(1).s
    }
}

enum Rank: String, Codable {
    case ss = "SS"
    case s = "S"
    case a = "A"
    case b = "B"
    case c = "C"
    case d = "D"
    case e = "E"
    case f = "F"

    var color: UIColor {
        switch self {
        case .s, .ss:
            return myBlue
        case .a:
            return myGreen
        case .b, .c, .d:
            return myOrange
        case .e, .f:
            return myRed
        }
    }
}