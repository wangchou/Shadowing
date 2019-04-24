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

var enHistory: [GameRecord] = []
var jpHistory: [GameRecord] = []

func saveGameHistory() {
    saveToUserDefault(object: context.gameHistory, key: gameHistoryKey + gameLang.key)
}

func loadGameHistory() {
    if let gameHistory = loadFromUserDefault(type: [GameRecord].self, key: gameHistoryKey + Lang.jp.key) {

        jpHistory = gameHistory
    } else {
        print("[\(gameLang)] create new gameHistory")
        jpHistory = [GameRecord]()
    }
    if let gameHistory = loadFromUserDefault(type: [GameRecord].self, key: gameHistoryKey + Lang.en.key) {

        enHistory = gameHistory
    } else {
        print("[\(gameLang)] create new gameHistory")
        enHistory = [GameRecord]()
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
            insertRecord(record)
            context.gameRecord?.isNewRecord = true
        } else {
            appendRecord(record)
            context.gameRecord?.isNewRecord = false
        }
    } else {
        appendRecord(record)
        context.gameRecord?.isNewRecord = true
    }
    saveGameHistory()
}

private func insertRecord(_ record: GameRecord) {
    if gameLang == .jp {
        jpHistory.insert(record, at: 0)
    }
    if gameLang == .en {
        enHistory.insert(record, at: 0)
    }
}

private func appendRecord(_ record: GameRecord) {
    if gameLang == .jp {
        jpHistory.append(record)
    }
    if gameLang == .en {
        enHistory.append(record)
    }
}

struct GameRecord: Codable {
    var gameFlowMode: GameFlowMode = .shadowing // deprecated, only for conform previous records
    var startedTime: Date
    var playDuration: Int = 0
    let dataSetKey: String
    let sentencesCount: Int
    let level: Level
    var isNewRecord = false
    var medalReward: Int?
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
        return getRank(isDetail: false)
    }

    var detailRank: Rank {
        return getRank(isDetail: true)
    }

    private func getRank(isDetail: Bool = false) -> Rank {
        if p == 100 && perfectCount.f * 1.3 >=  sentencesCount.f { return .ss }
        if p == 100 { return .s }
        if p >= 95 && isDetail { return .aP }
        if p >= 90 { return .a }
        if p >= 85 && isDetail { return .bP }
        if p >= 80 { return .b }
        if p >= 75 && isDetail { return .cP }
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
