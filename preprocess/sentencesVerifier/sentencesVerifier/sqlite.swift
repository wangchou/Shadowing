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

func loadSentenceDB() {
    guard let path = Bundle.main.path(forResource: sqliteFileName, ofType: "sqlite") else {
        print("sqlite file not found"); return
    }
    do {
        let db = try Connection(path, readonly: false)
        let kanaInfoTable = Table("kanaInfo")
        let kanaCount = Expression<Int>("kana_count")
        let startId = Expression<Int>("start_id")
        let sentenceCount = Expression<Int>("sentence_count")
        for row in try db.prepare(kanaInfoTable) {
            let kanaInfo = KanaInfo(kanaCount: row[kanaCount], startId: row[startId], sentenceCount: row[sentenceCount])
            kanaInfos[row[kanaCount]] = kanaInfo
        }
    } catch {
        print("db error")
    }
}

func getSentencesByIds(ids: [Int]) -> [String] {
    var sentences: [String] = []
    guard let path = Bundle.main.path(forResource: sqliteFileName, ofType: "sqlite") else {
        print("sqlite file not found"); return sentences
    }
    do {
        let db = try Connection(path, readonly: false)
        let sentenceTable = Table("sentences")
        let dbId = Expression<Int>("id")
        let dbJa = Expression<String>("ja")
        try ids.forEach { id throws in
            let query = sentenceTable.select(dbJa)
                .filter(dbId == id)
            for s in try db.prepare(query) {
                sentences.append(s[dbJa])
            }
        }

    } catch {
        print("db error")
    }
    return sentences
}

func updateIdWithListened(id: Int, siriSaid: String) {
    guard let path = Bundle.main.path(forResource: sqliteFileName, ofType: "sqlite") else {
        print("sqlite file not found"); return
    }
    do {
        let db = try Connection(writableDBPath, readonly: false)
        let sentenceTable = Table("sentences")
        let dbId = Expression<Int>("id")
        let dbSiriSaid = Expression<String>("siriSaid")
        let target = sentenceTable.filter(dbId == id)

        try db.run(target.update(dbSiriSaid <- siriSaid))
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
    } catch {
        print("\(error)")
    }
}
