//
//  sqliteSentences.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 10/11/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation
import SQLite
import Promises

struct Sentence: Hashable, Equatable {
    var id: Int
    var ja: String
    var en: String
    var cmn: String
    #if os(iOS)
    var origin: String {
        return gameLang == Lang.jp ? ja : en
    }

    var translation: String {
        switch GameContext.shared.gameSetting.translationLang {
        case .jp:
            return ja
        case .en:
            return en
        case .zh:
            return cmn
        default:
            return cmn
        }
    }
    #endif

    var ttsFixes: [(String, String)]

    func hash(into hasher: inout Hasher) {
        hasher.combine(ja)
        hasher.combine(en)
    }
    static func == (lhs: Sentence, rhs: Sentence) -> Bool {
        return lhs.ja == rhs.ja && lhs.en == rhs.en
    }
}

struct DifficultyInfo {
    var difficulty: Int
    var ids: Set<Int>
    var sentenceCount: Int {
        return ids.count
    }
}

struct TopicSentenceInfo {
    var ja: String
    var kanaCount: Int
}

var topicSentencesInfos: [String: TopicSentenceInfo] = [:]
private var sqliteFileName = "sentences20201118"
var tokenInfosTableName = "tokenInfos"
var sentencesTableName = "sentence"
var stringToIdTableName = "stringToId"
var jpInfoTableName = "jpInfo" // sentence ids sorted by difficulty
var enInfoTableName = "enInfo"

private let dbPath = Bundle.main.path(forResource: sqliteFileName, ofType: "sqlite") ?? ""
#if os(iOS)
    var waitDifficultyDBLoaded = Promise<Void>.pending()
    func loadDifficultyInfo() {
        waitDifficultyDBLoaded = Promise<Void>.pending()
        do {
            // jpInfos
            let db = try Connection(dbPath, readonly: true)
            let dbDifficulty = Expression<Int>("difficulty")
            let dbIds = Expression<String>("ids")

            let jpInfoTable = Table(jpInfoTableName)
            for row in try db.prepare(jpInfoTable) {
                let idArray: [Int] = decode(type: [Int].self, jsonString: row[dbIds]) ?? []
                let ids: Set<Int> = Set(idArray)
                let difficulty = row[dbDifficulty]
                jaDifficultyInfos[difficulty] = DifficultyInfo(difficulty: difficulty, ids: ids)
            }
            // enInfos
            let enInfoTable = Table(enInfoTableName)
            for row in try db.prepare(enInfoTable) {
                let idArray: [Int] = decode(type: [Int].self, jsonString: row[dbIds]) ?? []
                let ids: Set<Int> = Set(idArray)
                let difficulty = row[dbDifficulty]
                enDifficultyInfos[difficulty] = DifficultyInfo(difficulty: difficulty, ids: ids)
            }
        } catch {
            print("db error 1:\(error)")
        }
        waitDifficultyDBLoaded.fulfill(())
    }

func loadTopicSentenceDB() {
    guard topicSentencesInfos.isEmpty else { return }
    do {
        let db = try Connection(dbPath, readonly: true)
        let tokenInfosTable = Table(tokenInfosTableName)
        let dbJa = Expression<String>("ja")
        let dbKanaCount = Expression<Int>("kana_count")
        let dbTokenInfos = Expression<String>("tokenInfos")
        let topicSentences = rawDataSets.flatMap { $0 }
        let query = tokenInfosTable.select(dbJa, dbKanaCount, dbTokenInfos)
                                   .filter(topicSentences.contains(dbJa))
        for row in try db.prepare(query) {
            let ja = row[dbJa]
            kanaTokenInfosCacheDictionary[ja] = stringToTokenInfos(jsonString: row[dbTokenInfos])
            topicSentencesInfos[ja] = TopicSentenceInfo(ja: ja, kanaCount: row[dbKanaCount])
        }
    } catch {
        print("db error 2:\(error)")
    }
}

func loadTokenInfos(ja: String) {
    do {
        let db = try Connection(dbPath, readonly: true)
        let tokenInfosTable = Table(tokenInfosTableName)
        let dbJa = Expression<String>("ja")
        let dbKanaCount = Expression<Int>("kana_count")
        let dbTokenInfos = Expression<String>("tokenInfos")

        let query = tokenInfosTable.select(dbJa, dbKanaCount, dbTokenInfos)
            .filter(dbJa == ja)
        for row in try db.prepare(query) {
            let tokenInfos = stringToTokenInfos(jsonString: row[dbTokenInfos])
            kanaTokenInfosCacheDictionary[ja] = tokenInfos
        }
    } catch {
        print(error)
    }
}

private func getSentencesByIds(ids: [Int]) -> [Sentence] {
    do {
        let db = try Connection(dbPath, readonly: true)
        let sentenceTable = Table(sentencesTableName)
        let dbId = Expression<Int>("id")
        let dbJa = Expression<String>("ja")
        let dbEn = Expression<String>("en")
        let dbCmn = Expression<String>("cmn")
        let dbJaTTSFixes = Expression<String>("ja_tts_fixes")

        let query = sentenceTable.select(dbId, dbJa, dbEn, dbCmn, dbJaTTSFixes)
            .filter(ids.contains(dbId))
        var sentences: [Sentence] = []
        for row in try db.prepare(query) {
            let ttsFixes = arrayToPair(row[dbJaTTSFixes].components(separatedBy: " "))
            sentences.append(Sentence(id: row[dbId],
                                      ja: row[dbJa],
                                      en: row[dbEn],
                                      cmn: row[dbCmn],
                                      ttsFixes: ttsFixes))
        }
        return sentences
    } catch {
        print("db error 3:\(error)")
    }
    return []
}

func getSentenceByString(_ string: String) -> Sentence {
    do {
        let db = try Connection(dbPath, readonly: true)
        let stringToIdTable = Table(stringToIdTableName)
        let dbId = Expression<Int>("id")
        let dbOrigin = Expression<String>("origin")
        var id = -1
        var query = stringToIdTable.select(dbId)
            .filter(string == dbOrigin)
        for row in try db.prepare(query) {
            id = row[dbId]
        }

        let sentenceTable = Table(sentencesTableName)
        let dbJa = Expression<String>("ja")
        let dbEn = Expression<String>("en")
        let dbCmn = Expression<String>("cmn")
        let dbJaTTSFixes = Expression<String>("ja_tts_fixes")

        query = sentenceTable.select(dbId, dbJa, dbEn, dbCmn, dbJaTTSFixes)
            .filter(dbId == id)
        for row in try db.prepare(query) {
            let ttsFixes = arrayToPair(row[dbJaTTSFixes].components(separatedBy: " "))
            return Sentence(id: row[dbId],
                            ja: row[dbJa],
                            en: row[dbEn],
                            cmn: row[dbCmn],
                            ttsFixes: ttsFixes)
        }

    } catch {
        print("db error 3:\(error)")
    }
    print("Error: cannnot find sentence by \(string)")
    return Sentence(id: -1, ja: "", en: "", cmn: "", ttsFixes: [])
}

func getSentenceCount(minKanaCount: Int, maxKanaCount: Int) -> Int {
    var sentenceCount = 0
    for kanaCount in minKanaCount ... maxKanaCount {
        if let count = gameLang.difficultyInfos[kanaCount]?.sentenceCount {
            sentenceCount += count
        }
    }

    return sentenceCount
}

func getRandSentences(level: Level, numOfSentences: Int) -> [Sentence] {
    let minKanaCount = level.minSyllablesCount
    let maxKanaCount = level.maxSyllablesCount
    var combinedIds: Set<Int> = []
    for kanaCount in minKanaCount ... maxKanaCount {
        if let ids = gameLang.difficultyInfos[kanaCount]?.ids {
            combinedIds = combinedIds.union(ids)
        }
    }

    var randomIds: [Int] = []
    var randomSentences: [Sentence] = []
    while randomSentences.count < numOfSentences {
        while randomIds.count < numOfSentences + numOfSentences / 2 {
            if let newId = combinedIds.randomElement() {
                if !randomIds.contains(newId) {
                    randomIds.append(newId)
                }
            }
        }

        let sentences = getSentencesByIds(ids: randomIds)
        for s in sentences {
            let isSame = !randomSentences.filter { randS in
                if gameLang == Lang.jp {
                    return s.ja == randS.ja
                } else {
                    return s.en == randS.en
                }
            }.isEmpty
            if !isSame {
                randomSentences.append(s)
                if randomSentences.count == numOfSentences {
                    return randomSentences
                }
            }
        }
    }
    return randomSentences
}
#endif
