//
//  GameRecord.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/10.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation

private let context = GameContext.shared

private let gameHistoryKey = "game record array json"

func saveGameHistory() {
    saveToUserDefault(object: context.gameHistory, key: gameHistoryKey + gameLang.key)
}

func loadGameHistory() {
    if let gameHistory = loadFromUserDefault(type: [GameRecord].self, key: gameHistoryKey + gameLang.key) {
        context.gameHistory = gameHistory
    } else {
        print("[\(gameLang)] create new gameHistory")
        context.gameHistory = [GameRecord]()
    }
}

func getAllGameHistory() -> [GameRecord] {
    var records: [GameRecord] = []
    [Lang.en, Lang.jp].forEach { lang in
        if let loadedRecords = loadFromUserDefault(type: [GameRecord].self, key: gameHistoryKey + lang.key) {
            records.append(contentsOf: loadedRecords)
        }
    }
    return records
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
            context.newRecordIncrease = (record.p - bestRecord.p).i
        } else {
            context.gameHistory.append(record)
            context.gameRecord?.isNewRecord = false
        }
    } else {
        context.gameHistory.append(record)
        context.gameRecord?.isNewRecord = true
        context.newRecordIncrease = record.p.i
    }
    saveGameHistory()
}

struct GameRecord: Codable {
    var gameFlowMode: GameFlowMode = .shadowing // deprecated, only for conform previous records
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
    var correctCount: Int {
        return perfectCount + greatCount
    }
    var dateKey: String {
        return getDateKey(date: startedTime)
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
