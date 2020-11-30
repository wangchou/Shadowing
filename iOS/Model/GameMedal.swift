//
//  GameMedal.swift
//  今話したい
//
//  Created by Wangchou Lu on 3/22/31 H.
//  Copyright © 31 Heisei Lu, WangChou. All rights reserved.
//

import Foundation

let medalsPerLevel = 50

private var medalCount: [Lang: Int] = [:]

struct GameMedal {
    var totalCount: Int {
        return (medalCount[.ja] ?? 0) +
            (medalCount[.en] ?? 0)
    }

    func updateMedals(record: inout GameRecord) {
        let reward = getMedalRewards(record: record)
        record.medalReward = reward
        medalCount[gameLang] = max(0, (medalCount[gameLang] ?? 0) + reward)
    }

    var count: Int {
        //if isSimulator { return 235 }
        return medalCount[gameLang] ?? 0
    }

    var lowLevel: Level {
        return Level(medalCount: count)
    }

    var highLevel: Level {
        return Level(medalCount: count + medalsPerLevel)
    }

    var lowPercent: Double {
        return 1 - Double(count % medalsPerLevel) / Double(medalsPerLevel)
    }

    var usingDetailRank: Bool {
        return Level(medalCount: medalCount[gameLang] ?? 0).rawValue >= 2
    }

    private func getMedalRewards(record: GameRecord) -> Int {
        let lvl = Level(medalCount: medalCount[gameLang] ?? 0).rawValue
        switch lvl {
        case 0 ... 1:
            return medalUpdateByLevelAndRank[lvl][record.rank]!
        default:
            return medalUpdateByLevelAndRank[lvl][record.detailRank]!
        }
    }
}

private let medalUpdateByLevelAndRank: [[Rank: Int]] = [
    [.ss: 30, .s: 15, .aP: 7, .a: 7, .bP: 5, .b: 5, .cP: 3, .c: 3, .d: 1, .e: -1, .f: -3], // lv1  avg 55
    [.ss: 20, .s: 10, .aP: 7, .a: 5, .bP: 3, .b: 3, .cP: 1, .c: 1, .d: -1, .e: -3, .f: -5], // lv2  avg 65
    // turn on detail mode (add A+ & B+ & C+)
    [.ss: 20, .s: 10, .aP: 7, .a: 5, .bP: 3, .b: 1, .cP: 0, .c: -1, .d: -3, .e: -5, .f: -7], // lv3  avg 75
    [.ss: 20, .s: 10, .aP: 7, .a: 5, .bP: 3, .b: 1, .cP: 0, .c: -1, .d: -3, .e: -5, .f: -7], // lv4  avg 75
    [.ss: 20, .s: 10, .aP: 7, .a: 5, .bP: 3, .b: 0, .cP: -1, .c: -3, .d: -5, .e: -7, .f: -9], // lv5  avg 77.5
    [.ss: 20, .s: 10, .aP: 7, .a: 5, .bP: 3, .b: 0, .cP: -1, .c: -3, .d: -5, .e: -7, .f: -9], // lv6
    [.ss: 20, .s: 10, .aP: 7, .a: 5, .bP: 2, .b: 0, .cP: -2, .c: -4, .d: -6, .e: -8, .f: -10], // lv7  avg 80 4000 sentences
    [.ss: 20, .s: 10, .aP: 7, .a: 5, .bP: 2, .b: 0, .cP: -2, .c: -4, .d: -6, .e: -8, .f: -10], // lv8
    [.ss: 20, .s: 10, .aP: 7, .a: 5, .bP: 2, .b: 0, .cP: -2, .c: -4, .d: -6, .e: -8, .f: -10], // lv9  avg 80 5000 sentences
    [.ss: 20, .s: 10, .aP: 7, .a: 5, .bP: 2, .b: 0, .cP: -2, .c: -4, .d: -6, .e: -8, .f: -10], // lv10
    [.ss: 20, .s: 10, .aP: 7, .a: 5, .bP: 2, .b: 0, .cP: -2, .c: -4, .d: -6, .e: -8, .f: -10], // lv11
    [.ss: 20, .s: 10, .aP: 7, .a: 5, .bP: 2, .b: 0, .cP: -2, .c: -4, .d: -6, .e: -8, .f: -10], // lv12
]

// MARK: Save/Load

private let medalCountKey = "medal Count key"

func saveMedalCount() {
    saveToUserDefault(object: medalCount, key: medalCountKey)
}

func loadMedalCount() {
    loadObject(object: &medalCount, key: medalCountKey)
}
