//
//  GameMedal.swift
//  今話したい
//
//  Created by Wangchou Lu on 3/22/31 H.
//  Copyright © 31 Heisei Lu, WangChou. All rights reserved.
//

import Foundation

private let medalCountKey = "medal Count key"
private var medalCount: [Lang: Int] = [:]

func saveMedalCount() {
    saveToUserDefault(object: medalCount, key: medalCountKey)
}

func loadMedalCount() {
    easyLoad(object: &medalCount, key: medalCountKey)
}

struct GameMedal {
    let medalsPerLevel = 50

    var totalCount: Int {
        return (medalCount[.jp] ?? 0) +
               (medalCount[.en] ?? 0)
    }

    func getMedalLevel(medalCount: Int) -> Int {
        return medalCount / medalsPerLevel
    }

    func updateMedals(record: inout GameRecord) {
        let reward = getMedalRewards(record: record)
        record.medalReward = reward
        medalCount[gameLang] = max(0, (medalCount[gameLang] ?? 0) + reward)
    }

    var count: Int {
        return medalCount[gameLang] ?? 0
    }

    var lowLevel: Level {
        let lvl = getMedalLevel(medalCount: count)
        return Level(rawValue: lvl) ?? .lv9
    }
    var highLevel: Level {
        let lvl = getMedalLevel(medalCount: count + 50)
        return Level(rawValue: lvl) ?? .lv9
    }

    var lowPercent: Double {
        return 1 - Double(count % medalsPerLevel) / Double(medalsPerLevel)
    }

    var usingDetailRank: Bool {
        return getMedalLevel(medalCount: medalCount[gameLang] ?? 0) >= 4
    }

    private func getMedalRewards(record: GameRecord) -> Int {
        let lvl = getMedalLevel(medalCount: medalCount[gameLang] ?? 0)
        switch lvl {
        case 0 ... 4:
            return medalUpdateByLevelAndRank[lvl][record.rank]!
        case 5 ... 9:
            return medalUpdateByLevelAndRank[lvl][record.detailRank]!
        default:
            return medalUpdateByLevelAndRank[9][record.detailRank]! - (record.p < 90 ? (9 - lvl) : 0)
        }
    }
}

// swiftlint:disable colon
private let medalUpdateByLevelAndRank: [[Rank: Int]] = [
    [.ss:  30, .s:  15, .aP:  7, .a:  7, .bP:  5, .b:  5, .c:  3, .d:  1, .e:  -1, .f:  -3], // lv1
    [.ss:  30, .s:  15, .aP:  7, .a:  7, .bP:  4, .b:  4, .c:  2, .d:  0, .e:  -2, .f:  -4], // lv2
    [.ss:  20, .s:  10, .aP:  5, .a:  5, .bP:  3, .b:  3, .c:  1, .d: -1, .e:  -3, .f:  -5], // lv3
    [.ss:  20, .s:  10, .aP:  5, .a:  5, .bP:  2, .b:  2, .c:  0, .d: -2, .e:  -4, .f:  -5], // lv4
    // turn on detail plus mode
    [.ss:  20, .s:  10, .aP:  7, .a:  5, .bP:  3, .b:  1, .c: -1, .d: -3, .e:  -5, .f:  -7], // lv5
    [.ss:  20, .s:  10, .aP:  7, .a:  5, .bP:  3, .b:  1, .c: -1, .d: -3, .e:  -5, .f:  -7], // lv6
    [.ss:  20, .s:  10, .aP:  7, .a:  5, .bP:  3, .b:  1, .c: -1, .d: -3, .e:  -5, .f:  -7], // lv7
    [.ss:  20, .s:  10, .aP:  7, .a:  5, .bP:  3, .b:  1, .c: -1, .d: -3, .e:  -5, .f:  -7], // lv8
    [.ss:  20, .s:  10, .aP:  7, .a:  5, .bP:  2, .b:  0, .c: -2, .d: -4, .e:  -6, .f:  -8], // lv9
    [.ss:  20, .s:  10, .aP:  7, .a:  5, .bP:  2, .b:  0, .c: -2, .d: -4, .e:  -6, .f:  -8]  // lv10
]
// swiftlint:enable colon
