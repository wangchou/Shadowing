//
//  GameRecord.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/10.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation

private let context = GameContext.shared

private let defaults = UserDefaults.standard
private let gameHistoryKey = "game record array json"

func saveGameHistory() {
    let encoder = JSONEncoder()

    if let encoded = try? encoder.encode(context.gameHistory) {
        UserDefaults.standard.set(encoded, forKey: gameHistoryKey)
    } else {
        print("saveGameCharacter Failed")
    }

}

func loadGameHistory() {
    let decoder = JSONDecoder()
    if let gameHistoryData = UserDefaults.standard.data(forKey: gameHistoryKey),
       let gameHistory = try? decoder.decode([GameRecord].self, from: gameHistoryData) {
        context.gameHistory = gameHistory
    } else {
        print("loadGameHistory Failed")
    }
}

func isBetter(_ record: GameRecord, to bestRecord: GameRecord) -> Bool {
    return record.p > bestRecord.p || record.rank == .ss
}

func findBestRecord(key: String) -> GameRecord? {
    return context.gameHistory.first(where: {$0.dataSetKey == key})
}

// best record will insert at array HEAD
func updateGameHistory() {
    guard let record = context.gameRecord else { return }
    if let bestRecord = findBestRecord(key: record.dataSetKey) {
        if isBetter(record, to: bestRecord) {
            context.gameHistory.insert(record, at: 0)
            context.gameRecord?.isNewRecord = true
        } else {
            context.gameRecord?.isNewRecord = false
        }
    } else {
        context.gameHistory.append(record)
        context.gameRecord?.isNewRecord = true
    }
    saveGameHistory()
}

// https://docs.google.com/spreadsheets/d/1n19cAjeKv2G3t_Nz5rgvEyZm5C8ksjxFhHiqMZxTNus/edit#gid=0
private let expLevelBase: [Int] = [
    97,
    176,
    285,
    445,
    785,
    1359,
    2330,
    3969
]

private let goldLevelBase: [Int] = [
    24,
    37,
    52,
    71,
    106,
    156,
    227,
    330
]

struct GameRecord: Codable {
    var gameFlowMode: GameFlowMode = .shadowing
    var startedTime: Date
    var playDuration: Int = 0
    let dataSetKey: String
    let sentencesCount: Int
    let level: Level
    var isNewRecord = false
    var perfectCount = 0
    var greatCount = 0
    var goodCount = 0
    var missedCount: Int {
        return sentencesCount - perfectCount - greatCount - goodCount
    }

    var exp: Int {
        let base = expLevelBase[level.rawValue].f * p/100
        let factor: Float = isNewRecord ? 1.2 : 1.0
        return Int(base * factor)
    }

    var gold: Int {
        let base = goldLevelBase[level.rawValue].f * p/100
        let factor: Float = isNewRecord ? 1.2 : 1.0
        return max(Int(base * factor), 1)
    }

    var sentencesScore: [String: Score]

    var p: Float {
        let sum = perfectCount.f + greatCount.f + goodCount.f * 0.5
        return 100 * sum / sentencesCount.f
    }

    var progress: String {
        return "\(p.i)"
    }

    var rank: Rank {
        if p == 100 && perfectCount.f * 1.2 >=  sentencesCount.f { return .ss }
        if p == 100 { return .s }
        if p >= 90 { return .a }
        if p >= 80 { return .b }
        if p >= 70 { return .c }
        if p >= 60 { return .d }
        if p >= 40 { return .e }
        return .f
    }

    init(_ dataSetKey: String, sentencesCount: Int, level: Level, flowMode: GameFlowMode) {
        self.dataSetKey = dataSetKey
        self.sentencesCount = sentencesCount
        self.level = level
        self.sentencesScore = [:]
        self.startedTime = Date()
        self.gameFlowMode = flowMode
    }
}
