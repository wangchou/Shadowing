//
//  sqlite.swift
//  sentencesVerifier
//
//  Created by Wangchou Lu on 10/14/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation
import SQLite

struct KanaInfo {
    var kanaCount: Int
    var startId: Int
    var sentenceCount: Int
}

private var kanaInfos: [Int: KanaInfo] = [:]
private var sqliteFileName = "inf_sentences"
private var writableDBPath = ""
var idToSentences: [Int: String] = [:]
var idToSiriSaid: [Int: String] = [:]
var idToPairedScore: [Int: Int] = [:]
var idToScore: [Int: Int] = [:]
var dbR: Connection!
var dbW: Connection!

private let sentenceTable = Table("sentences")
private let dbId = Expression<Int>("id")

func loadSentenceDB() {
    guard let path = Bundle.main.path(forResource: sqliteFileName, ofType: "sqlite") else {
        print("sqlite file not found"); return
    }
    do {
        dbR = try Connection(path, readonly: true)
        let kanaInfoTable = Table("kanaInfo")
        let sentencesTable = Table("sentences")
        let ja = Expression<String>("ja")
        let en = Expression<String>("en")
        let id = Expression<Int>("id")
        let kanaCount = Expression<Int>("kana_count")
        let startId = Expression<Int>("start_id")
        let sentenceCount = Expression<Int>("sentence_count")
        for row in try dbR.prepare(kanaInfoTable) {
            guard speaker == .otoya || speaker == .kyoko else { continue }

            let kanaInfo = KanaInfo(kanaCount: row[kanaCount], startId: row[startId], sentenceCount: row[sentenceCount])
            kanaInfos[row[kanaCount]] = kanaInfo
        }
        for row in try dbR.prepare(sentencesTable) {
            if speaker == .alex || speaker == .samantha {
                idToSentences[row[id]] = row[en]
            } else {
                idToSentences[row[id]] = row[ja]
            }
        }
    } catch {
        print("db error")
    }
}

func getSentencesByIds(ids: [Int]) -> [String] {
    return ids.map { id in return idToSentences[id] ?? "" }
}


func updateIdWithListened(id: Int, siriSaid: String) {
    let dbSiriSaid = Expression<String>(speaker.dbField)
    do {
        let target = sentenceTable.filter(dbId == id)
        try dbW.run(target.update(dbSiriSaid <- siriSaid))
        print(id, siriSaid)
    } catch {
        print("db update error: \(error)")
    }
}

func updateSaidAndScore(id: Int, siriSaid: String, score: Score) {
    let dbSiriSaid = Expression<String>(speaker.dbField)
    let dbScore = Expression<Int>(speaker.dbScoreField)
    do {
        let target = sentenceTable.filter(dbId == id)
        try dbW.run(target.update(
            dbScore <- score.value,
            dbSiriSaid <- siriSaid
        ))
    } catch {
        print("db update error: \(error)")
    }
}

func updateScore(id: Int, score: Score) {
    let dbScore = Expression<Int>(speaker.dbScoreField)
    do {
        let target = sentenceTable.filter(dbId == id)
        try dbW.run(target.update(
            dbScore <- score.value
        ))
    } catch {
        print("db update error: \(error)")
    }
}

func updateSyllablesCount(id: Int, syllablesCount: Int) {
    let dbSyllablesCount = Expression<Int>("syllables_count")
    do {
        let target = sentenceTable.filter(dbId == id)
        try dbW.run(target.update(
            dbSyllablesCount <- syllablesCount
        ))
    } catch {
        print("db update error: \(error)")
    }
}

func getSentenceCount(minKanaCount: Int, maxKanaCount: Int) -> Int {
    guard let startKanaInfo = kanaInfos[minKanaCount],
        let endKanaInfo = kanaInfos[maxKanaCount] else { print("err in getSentenceCount"); return -1}

    let startId = startKanaInfo.startId
    let endId = endKanaInfo.startId + endKanaInfo.sentenceCount - 1

    return endId - startId
}

func randSentenceIds(minKanaCount: Int, maxKanaCount: Int, numOfSentences: Int) -> [Int] {
    guard let startKanaInfo = kanaInfos[minKanaCount],
          let endKanaInfo = kanaInfos[maxKanaCount] else { print("err in randSentenceIds"); return []}

    let startId = startKanaInfo.startId
    let endId = endKanaInfo.startId + endKanaInfo.sentenceCount - 1

    var randomIds: [Int] = []
    let maxCount = min(getSentenceCount(minKanaCount: minKanaCount, maxKanaCount: maxKanaCount), numOfSentences)
    for _ in 0..<maxCount {
        randomIds.append(Int(arc4random_uniform(UInt32(endId - startId))) + startId)
    }

    return randomIds
}

func createWritableDB() {
    let fileManager = FileManager.default
    do {
        writableDBPath = try fileManager
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("\(sqliteFileName).sqlite")
            .path

        if !fileManager.fileExists(atPath: writableDBPath) {
            print("not exist")
            let dbResourcePath = Bundle.main.path(forResource: sqliteFileName, ofType: "sqlite")!
            try fileManager.copyItem(atPath: dbResourcePath, toPath: writableDBPath)
        } else {
            print("exist")
        }
        dbW = try Connection(writableDBPath, readonly: false)
        let sentencesTable = Table("sentences")
        let siriSaid = Expression<String>(speaker.dbField)
        let pairedScore = Expression<Int>(speaker.pairDbScoreField)
        let score = Expression<Int>(speaker.dbScoreField)
        let id = Expression<Int>("id")
        for row in try dbW.prepare(sentencesTable) {
            idToSiriSaid[row[id]] = row[siriSaid]
            do {
                idToPairedScore[row[id]] = try row.get(pairedScore)
            } catch {
                //print(error)
            }
            do {
                idToScore[row[id]] = try row.get(score)
            } catch {
                //print(error)
            }
        }
    } catch {
        print("\(error)")
    }
}
