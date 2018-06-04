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

struct GameRecord: Codable {
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
        var levelFactor: Float = level.rawValue.f/10

        let base = (perfectCount * 3 + greatCount * 2 + goodCount * 1 + playDuration/5)
        levelFactor *= isNewRecord ? 1.2 : 1.0
        return Int(base.f * levelFactor)
    }

    var gold: Int {
        var levelFactor: Float = level.rawValue.f/10

        let base = perfectCount * 2 + greatCount
        levelFactor *= isNewRecord ? 1.2 : 1.0
        return Int(base.f * levelFactor)
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

    init(_ dataSetKey: String, sentencesCount: Int, level: Level) {
        self.dataSetKey = dataSetKey
        self.sentencesCount = sentencesCount
        self.level = level
        self.sentencesScore = [:]
        self.startedTime = Date()
    }
}
