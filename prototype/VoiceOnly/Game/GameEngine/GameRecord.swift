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
private let gameHistoryKey = "game record array"

func saveGameHistory() {
    let gameHistoryData = NSKeyedArchiver.archivedData(withRootObject: Array(context.gameHistory))
    defaults.set(gameHistoryData, forKey: gameHistoryKey)
}

func loadGameHistory() {
    guard let gameHistoryData = defaults.data(forKey: gameHistoryKey) else { return }
    guard let gameHistoryArray = NSKeyedUnarchiver.unarchiveObject(with: gameHistoryData) as? [GameRecord] else { return }
    context.gameHistory = gameHistoryArray
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
            context.isNewRecord = true
        }
        context.isNewRecord = false
    } else {
        context.gameHistory.append(record)
        context.isNewRecord = true
    }
    saveGameHistory()
}

class GameRecord: NSObject, NSCoding {
    var startedTime: Date
    var playDuration: Int = 0
    let dataSetKey: String
    let sentencesCount: Int
    let level: Level
    var perfectCount = 0
    var greatCount = 0
    var goodCount = 0
    var sentencesScore: [String: Score]

    var p: Float {
        let sum = perfectCount.f + greatCount.f + goodCount.f * 0.5
        return 100 * sum / sentencesCount.f
    }

    var progress: String {
        let prefix = p < 10 ? "0" : ""
        return "\(prefix)\(p.i)%"
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

    required init(coder decoder: NSCoder) {
        if let dataSetKey = decoder.decodeObject(forKey: "dataSetKey") as? String,
           let sentencesIntScore = decoder.decodeObject(forKey: "sentencesScore") as? [String: Int] {
            self.dataSetKey = dataSetKey
            var sentencesScore: [String: Score] = [:]
            for (key, value) in sentencesIntScore {
                sentencesScore[key] = Score(value: value)
            }
            self.sentencesScore = sentencesScore
        } else {
            self.dataSetKey = ""
            self.sentencesScore = [:]
            print("get dataSetKey or sentenceCount from localStorage failed")
        }
        self.sentencesCount = decoder.decodeInteger(forKey: "sentencesCount")
        self.perfectCount = decoder.decodeInteger(forKey: "perfectCount")
        self.greatCount = decoder.decodeInteger(forKey: "greatCount")
        self.goodCount = decoder.decodeInteger(forKey: "goodCount")
        self.playDuration = decoder.decodeInteger(forKey: "playDuration")
        self.level = allLevels[self.dataSetKey] ??
                     Level(rawValue: decoder.decodeInteger(forKey: "level")) ??
                     .n5
        if let startedTime = decoder.decodeObject(forKey: "startedTime") as? Date {
            self.startedTime = startedTime
        } else {
            print("decode started time as Date failed")

            // random date for test
            let date = Date()
            var dateComponent = DateComponents()
            dateComponent.day = -1 * Int(arc4random_uniform(14))
            self.startedTime = Calendar.current.date(byAdding: dateComponent, to: date) ?? date
        }
        super.init()
    }

    func encode(with coder: NSCoder) {
        coder.encode(self.dataSetKey, forKey: "dataSetKey")
        coder.encodeCInt(Int32(self.sentencesCount), forKey: "sentencesCount")
        coder.encodeCInt(Int32(self.perfectCount), forKey: "perfectCount")
        coder.encodeCInt(Int32(self.greatCount), forKey: "greatCount")
        coder.encodeCInt(Int32(self.goodCount), forKey: "goodCount")
        coder.encodeCInt(Int32(self.playDuration), forKey: "playDuration")
        coder.encodeCInt(Int32(self.level.rawValue), forKey: "level")
        var sentencesIntScore: [String: Int] = [:]
        for (key, score) in self.sentencesScore {
            sentencesIntScore[key] = score.value
        }
        coder.encode(sentencesIntScore, forKey: "sentencesScore")
        coder.encode(self.startedTime, forKey: "startedTime")
    }
}
