//
//  GameTrophy.swift
//  今話したい
//
//  Created by Wangchou Lu on 3/22/31 H.
//  Copyright © 31 Heisei Lu, WangChou. All rights reserved.
//

import Foundation

private let trophyCountKey = "trophy Count key"
private var trophyCount: [Lang: Int] = [:]

func saveTrophyCount() {
    saveToUserDefault(object: trophyCount, key: trophyCountKey)
}

func loadTrophyCount() {
    easyLoad(object: &trophyCount, key: trophyCountKey)
}

struct GameTrophy {
    let trophiesPerLevel = 50

    private(set) var en: Int {
        get {
            return trophyCount[Lang.en] ?? 0
        }
        set {
            trophyCount[Lang.en] = newValue
        }
    }

    private(set) var jp: Int {
        get {
            return trophyCount[Lang.jp] ?? 0
        }
        set {
            trophyCount[Lang.jp] = newValue
        }
    }

    var all: Int {
        return en + jp
    }

    func getTrophyLevel(trophyCount: Int) -> Int {
        return trophyCount / trophiesPerLevel
    }

    func updateTrophies(record: inout GameRecord) {
        let reward = getTrophyRewards(record: record)
        record.trophyReward = reward
        trophyCount[gameLang] = max(0, (trophyCount[gameLang] ?? 0) + reward)
    }

    var count: Int {
        return trophyCount[gameLang] ?? 0
    }

    var lowLevel: Level {
        let lvl = getTrophyLevel(trophyCount: count)
        return Level(rawValue: lvl) ?? Level.lv9
    }
    var highLevel: Level {
        let lvl = getTrophyLevel(trophyCount: count + 50)
        return Level(rawValue: lvl) ?? Level.lv9
    }

    var lowPercent: Double {
        return Double(count % trophiesPerLevel) / Double(trophiesPerLevel)
    }

    private func getTrophyRewards(record: GameRecord) -> Int {
        let lvl = getTrophyLevel(trophyCount: trophyCount[gameLang] ?? 0)
        switch lvl {
        case 0 ... 4:
            return trophyUpdateByLevelAndRank[lvl][record.rank]!
        case 5 ... 9:
            return trophyUpdateByLevelAndRank[lvl][record.detailRank]!
        default:
            return trophyUpdateByLevelAndRank[9][record.detailRank]! - (record.p < 90 ? (9 - lvl) : 0)
        }
    }
}

// swiftlint:disable colon
private let trophyUpdateByLevelAndRank: [[Rank: Int]] = [
    [.ss:  15, .s:  10, .aP:  7, .a:  5, .bP:  4, .b:  4, .c:  3, .d:  1, .e:  -1, .f:  -3], // lv1
    [.ss:  15, .s:  10, .aP:  7, .a:  5, .bP:  3, .b:  3, .c:  1, .d: -1, .e:  -3, .f:  -5], // lv2
    [.ss:  15, .s:  10, .aP:  7, .a:  5, .bP:  2, .b:  2, .c:  0, .d: -2, .e:  -4, .f:  -6], // lv3
    [.ss:  15, .s:  10, .aP:  7, .a:  5, .bP:  2, .b:  2, .c: -1, .d: -3, .e:  -5, .f:  -7], // lv4
    [.ss:  15, .s:  10, .aP:  7, .a:  5, .bP:  2, .b:  2, .c: -2, .d: -4, .e:  -6, .f:  -8], // lv5
    // turn on detail plus mode
    [.ss:  15, .s:  10, .aP:  7, .a:  5, .bP:  2, .b:  1, .c: -2, .d: -4, .e:  -6, .f:  -8], // lv6
    [.ss:  15, .s:  10, .aP:  7, .a:  5, .bP:  2, .b:  1, .c: -3, .d: -5, .e:  -7, .f:  -9], // lv7
    [.ss:  15, .s:  10, .aP:  7, .a:  5, .bP:  2, .b:  0, .c: -3, .d: -5, .e:  -7, .f:  -9], // lv8
    [.ss:  15, .s:  10, .aP:  7, .a:  5, .bP:  2, .b: -1, .c: -4, .d: -6, .e:  -8, .f: -10], // lv9
    [.ss:  15, .s:  10, .aP:  7, .a:  5, .bP:  1, .b: -2, .c: -5, .d: -7, .e:  -9, .f: -11]  // lv10
]
// swiftlint:enable colon
