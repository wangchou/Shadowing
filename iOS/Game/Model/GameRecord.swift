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
    saveToUserDefault(object: context.gameHistory, key: gameHistoryKey)
}

func loadGameHistory() {
    if let gameHistory = loadFromUserDefault(type: [GameRecord].self, key: gameHistoryKey) {
        context.gameHistory = gameHistory
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
            context.newRecordIncrease = bestRecord.abilityPoint - (context.gameRecord?.abilityPoint ?? 0)
        } else {
            context.gameHistory.append(record)
            context.gameRecord?.isNewRecord = false
        }
    } else {
        context.gameHistory.append(record)
        context.gameRecord?.isNewRecord = true
        context.newRecordIncrease = context.gameRecord?.abilityPoint ?? 0
    }
    saveGameHistory()
}

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

    var sentencesScore: [String: Score]

    // the sentence have 20 kana with 80 score => 20 x 0.80 = 16 ability point
    // harder game will get higher points
    var abilityPoint: Int {
        guard !sentencesScore.isEmpty else { return 0 }
        var scoreSum: Int = 0
        for (sentence, score) in sentencesScore {
            let kana = getKanaSync(sentence)
            switch score.type {
            case .perfect:
                scoreSum += kana.count * 100

            case .great:
                scoreSum += kana.count * 80

            case .good:
                scoreSum += kana.count * 50

            case .poor:
                scoreSum += kana.count * 0
            }
        }
        return scoreSum/100
    }

    var p: Float {
        let sum = perfectCount.f + greatCount.f + goodCount.f * 0.5
        return 100 * sum / sentencesCount.f
    }

    var progress: String {
        return "\(p.i)"
    }

    var pointText: String {
        return "\(abilityPoint)"
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

func getAbilityPointMax(_ dataSetKey: String) -> Int {
    guard let sentences = allSentences[dataSetKey] else { return 0 }
    var kanaCount: Int = 0
    for (_, sentence) in sentences {
        let kana = getKanaSync(sentence)
        kanaCount += kana.count
    }
    return kanaCount
}
