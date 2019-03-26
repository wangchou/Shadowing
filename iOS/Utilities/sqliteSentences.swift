//
//  sqliteSentences.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 10/11/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation
import SQLite

struct SentenceInfo {
    var syllablesCount: Int
    var ids: Set<Int>
    var sentenceCount: Int
}

struct TopicSentenceInfo {
    var kanaCount: Int
    var ja: String
    var tokenInfos: [[String]]? //tokenInfo =[kanji, 詞性, furikana, yomikana]
}

var topicSentencesInfos: [String: TopicSentenceInfo] = [:]
private var sqliteFileName = "inf_sentences_100points_duolingo_with_topics"

#if os(iOS)
func loadSentenceDB() {
    guard let path = Bundle.main.path(forResource: sqliteFileName, ofType: "sqlite") else {
        print("sqlite file not found"); return
    }
    do {
        // kanaInfos
        let db = try Connection(path, readonly: true)
        let kanaInfoTable = Table("kanaInfo")
        let kanaCount = Expression<Int>("kana_count")
        let ids = Expression<String>("ids")
        let sentenceCount = Expression<Int>("sentence_count")
        for row in try db.prepare(kanaInfoTable) {
            let ids: Set<Int> = Set(row[ids].split(separator: ",")
                                     .map { Int($0.s) ?? -1 }
                                     .filter { $0 != -1}
                                )
            jaSentenceInfos[row[kanaCount]] = SentenceInfo(syllablesCount: row[kanaCount], ids: ids, sentenceCount: row[sentenceCount])
        }

        // syllablesInfo
        let syllablesInfoTable = Table("syllablesInfo")
        let syllablesCount = Expression<Int>("syllables_count")
        for row in try db.prepare(syllablesInfoTable) {
            let ids: Set<Int> = Set(row[ids].split(separator: ",")
                .map { Int($0.s) ?? -1 }
                .filter { $0 != -1}
            )
            enSentenceInfos[row[syllablesCount]] = SentenceInfo(syllablesCount: row[syllablesCount], ids: ids, sentenceCount: row[sentenceCount])
        }

        let topicSentencesInfoTable = Table("topicSentencesInfo")
        let ja = Expression<String>("ja")
        let tokenInfos = Expression<String>("tokenInfos")
        for row in try db.prepare(topicSentencesInfoTable) {
            let topicSentenceInfo = TopicSentenceInfo(
                kanaCount: row[kanaCount],
                ja: row[ja],
                tokenInfos: stringToTokenInfos(jsonString: row[tokenInfos])
            )
            topicSentencesInfos[row[ja]] = topicSentenceInfo
            if let tmpTokenInfos = topicSentenceInfo.tokenInfos {
                kanaTokenInfosCacheDictionary[row[ja]] = tmpTokenInfos
            }
        }
    } catch {
        print("db error")
    }
}
#endif

func loadTopSentencesInfoDB() {
    guard topicSentencesInfos.isEmpty else { return }

    guard let path = Bundle.main.path(forResource: sqliteFileName, ofType: "sqlite") else {
        print("sqlite file not found"); return
    }
    do {
        let db = try Connection(path, readonly: true)
        let kanaCount = Expression<Int>("kana_count")
        let ja = Expression<String>("ja")
        let topicSentencesInfoTable = Table("topicSentencesInfo")
        let tokenInfos = Expression<String>("tokenInfos")
        for row in try db.prepare(topicSentencesInfoTable) {
            let topicSentenceInfo = TopicSentenceInfo(
                kanaCount: row[kanaCount],
                ja: row[ja],
                tokenInfos: stringToTokenInfos(jsonString: row[tokenInfos])
            )
            topicSentencesInfos[row[ja]] = topicSentenceInfo
            if let tmpTokenInfos = topicSentenceInfo.tokenInfos {
                kanaTokenInfosCacheDictionary[row[ja]] = tmpTokenInfos
            }
        }
    } catch {
        print("db error")
    }
}

private func getSentencesById(id: Int) -> String {
    guard let path = Bundle.main.path(forResource: sqliteFileName, ofType: "sqlite") else {
        print("sqlite file not found"); return "Not Found"
    }
    do {
        let db = try Connection(path, readonly: true)
        let sentenceTable = Table("sentences")
        let dbId = Expression<Int>("id")
        let dbJa = Expression<String>("ja")
        let dbEn = Expression<String>("en")

        let query = sentenceTable.select(dbJa, dbEn)
            .filter(dbId == id)
        for s in try db.prepare(query) {
            if gameLang == .jp {
                translations[s[dbJa]]=s[dbEn]
                return s[dbJa]
            }
            if gameLang == .en {
                translations[s[dbEn]]=s[dbJa]
                return s[dbEn]
            }
        }

    } catch {
        print("db error")
    }
    return ""
}

func getSentenceCount(minKanaCount: Int, maxKanaCount: Int) -> Int {
    var sentenceCount = 0
    for kanaCount in minKanaCount...maxKanaCount {
        if let count = gameLang.sentenceInfos[kanaCount]?.sentenceCount {
            sentenceCount += count
        }
    }

    return sentenceCount
}

func getRandSentences(level: Level, numOfSentences: Int) -> [String] {
    let minKanaCount = level.minSyllablesCount
    let maxKanaCount = level.maxSyllablesCount
    var combinedIds: Set<Int> = []
    for kanaCount in minKanaCount...maxKanaCount {
        if let ids = gameLang.sentenceInfos[kanaCount]?.ids {
            combinedIds = combinedIds.union(ids)
        }
    }

    var randomSentences: [String] = []
    while randomSentences.count < numOfSentences {
        if let newId = combinedIds.randomElement() {
            let str = getSentencesById(id: newId)
            if !randomSentences.contains(str) {
                randomSentences.append(str)
            }
        }
    }

    return randomSentences
}
