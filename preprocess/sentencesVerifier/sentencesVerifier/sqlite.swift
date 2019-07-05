//
import Foundation
import SQLite
//  sqlite.swift
//  sentencesVerifier
//
//  Created by Wangchou Lu on 10/14/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//
import SwiftSyllablesMac

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
var idToSyllablesLen: [Int: Int] = [:]
var dbR: Connection!
var dbW: Connection!

private let sentenceTable = Table("sentences")
private let dbId = Expression<Int>("id")

func getSentencesByIds(ids: [Int]) -> [String] {
    return ids.map { id in idToSentences[id] ?? "" }
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

func updateSiriSaidAndScore(id: Int, siriSaid: String, score: Score) {
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

func updateEnDifficuty(id: Int, difficulty: Int) {
    let dbEnDifficuty = Expression<Int>("en_voc_difficulty")
    do {
        let target = sentenceTable.filter(dbId == id)
        try dbW.run(target.update(
            dbEnDifficuty <- difficulty
        ))
    } catch {
        print("db update error: \(error)")
    }
}

func loadWritableDb() {
    let fileManager = FileManager.default
    do {
        writableDBPath = try fileManager
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("\(sqliteFileName).sqlite")
            .path

        if !fileManager.fileExists(atPath: writableDBPath) {
            print("not exist")
        } else {
            print("exist")
        }
        dbW = try Connection(writableDBPath, readonly: false)
        let sentencesTable = Table("sentences")
        let originalText = (speaker == .otoya || speaker == .kyoko) ?
            Expression<String>("ja") :
            Expression<String>("en")
        let siriSaid = Expression<String>(speaker.dbField)
        let pairedScore = Expression<Int>(speaker.pairDbScoreField)
        let score = Expression<Int>(speaker.dbScoreField)
        let kanaCount = Expression<Int>("kana_count")
        let syllablesCount = Expression<Int>("syllables_count")
        let id = Expression<Int>("id")
        startTime = now()
        for row in try dbW.prepare(sentencesTable) {
            idToSentences[row[id]] = row[originalText]
            do {
                idToSiriSaid[row[id]] = try row.get(siriSaid)
            } catch {
                // print(error)
            }
            do {
                idToPairedScore[row[id]] = try row.get(pairedScore)
            } catch {
                // print(error)
            }
            do {
                idToScore[row[id]] = try row.get(score)
            } catch {
                // print(error)
            }
            switch speaker {
            case .otoya, .kyoko:
                idToSyllablesLen[row[id]] = try row.get(kanaCount)
            case .alex, .samantha:
                do {
                    idToSyllablesLen[row[id]] = try row.get(syllablesCount)
                } catch {
                    if let s = idToSentences[row[id]] {
                        idToSyllablesLen[row[id]] = SwiftSyllables.getSyllables(s)
                    }
                }
            }
        }
    } catch {
        print("\(error)")
    }
}
