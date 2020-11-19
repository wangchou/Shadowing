//
//  main.swift
//  SentenceTests
//
//  Created by Wangchou Lu on R 2/11/12.
//

import Foundation
import Promises
import SwiftSyllables
import SQLite

func getSentences() -> [[String]] {
    let file = "sentences.tsv"
    var rows: [[String]] = []
    if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
        let fileURL = dir.appendingPathComponent(file)
        print(fileURL)
        do {
            rows = try String(contentsOf: fileURL, encoding: .utf8)
                .components(separatedBy: "\n")
                .map { str in
                    return str.components(separatedBy: "\t")
                }
        } catch let error {
            print(error)
        }
    }
    return rows.filter { row in
        return !row.isEmpty
    }
}

var rows = getSentences()
            .filter {row in return row.count > 5}
print(rows.count)

var targetIndex = 2000 //rows.count - 1
var batchSize = 10
func showStatus() {
    var jpn100Count = 0
    var en100Count = 0
    var both100Count = 0
    var bothBadCount = 0
    var sentenceCount = 0
    for r in 0 ... targetIndex {
        let row = rows[r]
        let jpn0 = row[0]
        let eng0 = row[1]
        //let cmn0 = row[2]
        let jpn1 = row[3]
        let jpn2 = row[4]
        let eng1 = row[5]
        let eng2 = row[6]
        let eng3 = row[7]
        let eng4 = row[8]
        let enSyllablesCount = SwiftSyllables.getSyllables(eng0.spellOutNumbers())
        let enDifficulty = DifficultyCalculator.shred.getDifficulty(sentence: eng0)
        let kanaCount = row[9].count
        //let kana1 = row[10]
        //let kana2 = row[11]
        all([
            calculateScore(jpn0, jpn1),
            calculateScore(jpn0, jpn2),
            calculateScoreEn(eng0, eng1),
            calculateScoreEn(eng0, eng2),
            calculateScoreEn(eng0, eng3),
            calculateScoreEn(eng0, eng4)
        ]).then { scores in
            let jpnOK = scores[0].value == 100 && scores[1].value == 100
            let enOK = scores[2].value == 100 && scores[3].value == 100 &&
                scores[4].value == 100 && scores[5].value == 100
            jpn100Count += jpnOK ? 1 :0
            en100Count += enOK ? 1 : 0
            both100Count += jpnOK && enOK ? 1 : 0
            bothBadCount += !jpnOK && !enOK ? 1 : 0
            sentenceCount += 1
            if sentenceCount%100 == 0 {
                print("---")
                print(jpn100Count, en100Count, both100Count, bothBadCount, sentenceCount)
                print(jpn0)
                print(eng0)
                print("syllables :", enSyllablesCount)
                print("difficulty:", enDifficulty)
                print("kanaCount :", kanaCount)
            }
        }

        while sentenceCount < r - batchSize {
            RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.001))
        }
    }

    while sentenceCount < targetIndex {
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.001))
    }
}

func checkKanaFixes() {
    var swiftKana: [String: String] = [:]
    var finishedCount = 0
    for r in 0 ... targetIndex {
        let jpn0 = rows[r][0]
        let jpn1 = rows[r][3]
        let jpn2 = rows[r][4]
        all([
            getKana(jpn0, isFuri: true, originalString: jpn0),
            getKana(jpn1, isFuri: true, originalString: jpn0),
            getKana(jpn2, isFuri: true, originalString: jpn0)
        ])
        .then { kanas in
            swiftKana[jpn0] = kanas[0].kataganaToHiragana
            swiftKana[jpn1] = kanas[1].kataganaToHiragana
            swiftKana[jpn2] = kanas[2].kataganaToHiragana
            finishedCount += 1
        }

        while finishedCount < r - batchSize {
            RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.001))
        }
    }

    while finishedCount < targetIndex + 1 {
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.001))
    }

    for r in 0 ... targetIndex {
        let row = rows[r]
        let jpn0 = row[0]
        let jpn1 = row[3]
        let jpn2 = row[4]
        let kana0 = row[9]
        let kana1 = row[10]
        let kana2 = row[11]
        if let sKana0 = swiftKana[jpn0],
           let sKana1 = swiftKana[jpn1],
           let sKana2 = swiftKana[jpn2] {
            if kana0 != sKana0 ||
                kana1 != sKana1 ||
                kana2 != sKana2 {
                print(jpn0)
                print("jsKana   :", kana0)
                print("swiftKana:", sKana0)
                print(jpn1)
                print("jsKana   :", kana1)
                print("swiftKana:", sKana1)
                print(jpn2)
                print("jsKana   :", kana2)
                print("swiftKana:", sKana2)
                print("--")
            }
        } else {
            print("Error:", r, jpn0)
        }
    }
    while finishedCount < targetIndex {
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.001))
    }
    print(targetIndex, "Done")
}

func checkTTSFixes() {
    var sentenceCount = 0
    for r in 0 ... targetIndex {
        if r % 1000 == 0 { print(r) }
        let jpn0 = rows[r][0]
        let jsTTSStr = rows[r][12]
        let ttsFixes = rows[r][14].components(separatedBy: " ")
        let localFixes: [(String, String)] = arrayToPair(ttsFixes)

        getFixedTTSString(jpn0, localFixes: localFixes)
            .then { swiftTTSStr, _ in
                if jsTTSStr != swiftTTSStr {
                    print(r)
                    print(jpn0)
                    print("js   :", jsTTSStr)
                    print("swift:", swiftTTSStr)
                    dump(localFixes)
                }
                sentenceCount += 1
            }
        while sentenceCount <= r - 3 {
            RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.001))
        }
    }

    while sentenceCount <= targetIndex {
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.001))
    }
}

//checkTTSFixes()

private var sqliteFileName = "sentences20201118.sqlite"
private var tokenInfosTableName = "tokenInfos"
private var sentencesTableName = "sentence"
private var jpInfoTableName = "jpInfo" // sentence ids sorted by difficulty
private var enInfoTableName = "enInfo"

private var writableDBPath = ""
var dbW: Connection!

func createWritableDB() {
    let fileManager = FileManager.default
    do {
        writableDBPath = try fileManager
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("\(sqliteFileName)")
            .path

        if fileManager.fileExists(atPath: writableDBPath) {
            try fileManager.removeItem(atPath: writableDBPath)
        }
        dbW = try Connection(writableDBPath, readonly: false)
    } catch {
        print("\(error)")
    }
}
var isAddedToTokenInfo: [String: Bool] = [:]
func updateIdWithListened(ja: String, kana_count: Int,  tokenInfos: [[String]]) {
    guard isAddedToTokenInfo[ja] != true else { return }
    do {
        let table = Table(tokenInfosTableName)
        let dbJa = Expression<String>("ja")
        let dbKanaCount = Expression<Int>("kana_count")
        let dbTokenInfos = Expression<String>("tokenInfos")

        let insertSql = table.insert(dbJa <- ja,
                                     dbKanaCount <- kana_count,
                                     dbTokenInfos <- tokenInfosToString(tokenInfos: tokenInfos))
        try dbW.run(insertSql)
        isAddedToTokenInfo[ja] = true
    } catch {
        print("db update error: \(error)")
    }
}

private var isFinished = false
func waitForFinishing() {
    while !isFinished {
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.001))
    }
}

func addTokenInfosTable() {
    do {
        let tokenInfosTable = Table(tokenInfosTableName)
        let ja = Expression<String>("ja")
        let kana_count = Expression<Int>("kana_count")
        let tokenInfos = Expression<String>("tokenInfos")
        try dbW.run(tokenInfosTable.drop(ifExists: true))
        try dbW.run(tokenInfosTable.create { t in
            t.column(ja, primaryKey: true)
            t.column(kana_count)
            t.column(tokenInfos)
        })
        var sentences: [String] = []
        rawDataSets.forEach { sArray in
            sentences.append(contentsOf: sArray)
        }
        print(sentences.count)
        for (_, jpn) in sentences.enumerated() {
            isFinished = false
            getKana(jpn, originalString: jpn).then { kana in
                updateIdWithListened(ja: jpn,
                                    kana_count: kana.count,
                                    tokenInfos: kanaTokenInfosCacheDictionary[jpn] ?? [])
                isFinished = true
            }
            waitForFinishing()
        }
    } catch {
        print("db error: \(error)")
    }
}

var jpnOK : [String: Bool] = [:]
var engOK : [String: Bool] = [:]
var jpnDifficulty : [String: Int] = [:]
var engDifficulty : [String: Int] = [:]
var sentences: [(id: Int, jpn: String, eng: String)] = []
func addSentencesTable() {
    do {
        let sentencesTable = Table(sentencesTableName)
        let dbId = Expression<Int>("id")
        let dbJa = Expression<String>("ja")
        let dbEn = Expression<String>("en")
        let dbCmn = Expression<String>("cmn")
        let dbJaTTSFixes = Expression<String>("ja_tts_fixes")
        try dbW.run(sentencesTable.drop(ifExists: true))
        try dbW.run(sentencesTable.create { t in
            t.column(dbId, primaryKey: true)
            t.column(dbJa)
            t.column(dbEn)
            t.column(dbCmn)
            t.column(dbJaTTSFixes)
        })
        for (i, row) in rows.enumerated() {
            //if(i % 500 == 0) {
                print(i)
            //}
//            if(i > 2000) {
//                break
//            }

            let jpn0 = row[0]
            let eng0 = row[1]
            sentences.append((id: i, jpn: jpn0, eng: eng0))

            let cmn = row[2]
            let jpn1 = row[3]
            let jpn2 = row[4]
            let eng1 = row[5]
            let eng2 = row[6]
            let eng3 = row[7]
            let eng4 = row[8]
            let ttsFixes = row[14]
            let enSyllablesCount = SwiftSyllables.getSyllables(eng0.spellOutNumbers())
            let enWordDifficulty = DifficultyCalculator.shred.getDifficulty(sentence: eng0)

            engDifficulty[eng0] = enSyllablesCount + Int(Double(enWordDifficulty) * 0.7)

            isFinished = false
            all([
                calculateScore(jpn0, jpn1),
                calculateScore(jpn0, jpn2),
                calculateScoreEn(eng0, eng1),
                calculateScoreEn(eng0, eng2),
                calculateScoreEn(eng0, eng3),
                calculateScoreEn(eng0, eng4)
            ]).then { scores in
                jpnOK[jpn0] = scores[0].value == 100 &&
                              scores[1].value == 100
                engOK[eng0] = scores[2].value == 100 &&
                              scores[3].value == 100 &&
                              scores[4].value == 100 &&
                              scores[5].value == 100
                isFinished = true
            }
            waitForFinishing()

            isFinished = false
            getKana(jpn0, isFuri: true, originalString: jpn0)
                .then { kana in
                    let insertSql = sentencesTable.insert(
                        dbId <- i,
                        dbJa <- jpn0,
                        dbEn <- eng0,
                        dbCmn <- cmn,
                        dbJaTTSFixes <- ttsFixes
                    )
                    try dbW.run(insertSql)
                    jpnDifficulty[jpn0] = kana.count

                    updateIdWithListened(ja: jpn0,
                                         kana_count: kana.count,
                                         tokenInfos: kanaTokenInfosCacheDictionary[jpn0] ?? [])
                    isFinished = true
                }
            waitForFinishing()
        }
    } catch {
        print("db error: \(error)")
    }
}

func addJpInfoTables() {
    do {
        let jpInfoTable = Table(jpInfoTableName)
        let dbDifficulty = Expression<Int>("difficulty")
        let dbIds = Expression<String>("ids")
        try dbW.run(jpInfoTable.drop(ifExists: true))
        try dbW.run(jpInfoTable.create { t in
            t.column(dbDifficulty, primaryKey: true)
            t.column(dbIds)
        })

        var isAdded: [String: Bool] = [:]
        var difficultyIds: [Int: [Int]] = [:]
        for difficulty in 0 ... 1000 {
            difficultyIds[difficulty] = []
        }
        for (id, row) in rows.enumerated() {
            let jpn = row[0]
            if let isScoreOK = jpnOK[jpn],
               isScoreOK,
               isAdded[jpn] == nil,
               let difficulty = jpnDifficulty[jpn] {
                isAdded[jpn] = true
                difficultyIds[difficulty]?.append(id)
            }
        }
        print("- jpn difficulty -")
        for difficulty in 0 ... 1000 {
            if let ids = difficultyIds[difficulty],
               ids.count > 0 {
                let insertSql = jpInfoTable.insert(
                    dbDifficulty <- difficulty,
                    dbIds <- encode(ids) ?? ""
                )
                print(difficulty, ids.count)
                try dbW.run(insertSql)
            }
        }


    } catch {
        print("db error: \(error)")
    }
}
func addEnInfoTables() {
    do {
        let enInfoTable = Table(enInfoTableName)
        let dbDifficulty = Expression<Int>("difficulty")
        let dbIds = Expression<String>("ids")
        try dbW.run(enInfoTable.drop(ifExists: true))
        try dbW.run(enInfoTable.create { t in
            t.column(dbDifficulty, primaryKey: true)
            t.column(dbIds)
        })

        var isAdded: [String: Bool] = [:]
        var difficultyIds: [Int: [Int]] = [:]
        for difficulty in 0 ... 1000 {
            difficultyIds[difficulty] = []
        }
        for (id, row) in rows.enumerated() {
            let eng = row[1]
            if let isScoreOK = engOK[eng],
               isScoreOK,
               isAdded[eng] == nil,
               let difficulty = engDifficulty[eng] {
                isAdded[eng] = true
                difficultyIds[difficulty]?.append(id)
            }
        }

        print("- en difficulty -")
        for difficulty in 0 ... 1000 {
            if let ids = difficultyIds[difficulty],
               ids.count > 0 {
                let insertSql = enInfoTable.insert(
                    dbDifficulty <- difficulty,
                    dbIds <- encode(ids) ?? ""
                )
                print(difficulty, ids.count)
                try dbW.run(insertSql)
            }
        }


    } catch {
        print("db error: \(error)")
    }
}
func runAll() {
    do {
        createWritableDB()
        dbW = try Connection(writableDBPath, readonly: false)
        addTokenInfosTable()
        addSentencesTable()
        addJpInfoTables()
        addEnInfoTables()
    } catch {
        print("db error: \(error)")
    }

}

runAll()
