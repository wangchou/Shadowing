//
//  main.swift
//  SentenceTests
//
//  Created by Wangchou Lu on R 2/11/12.
//

import Foundation
import Promises
import SwiftSyllables

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
    return rows
}

var rows = getSentences()
print(rows.count)

var targetSize = 1000//rows.count
var batchSize = 10
var jpn100Count = 0
var en100Count = 0
var both100Count = 0
var bothBadCount = 0
var sentenceCount = 0
for r in 0 ... targetSize {
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
        if(sentenceCount%100 == 0) {
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

/* checking
var swiftKana: [String: String] = [:]

var finishedCount = 0
for r in 0 ... targetSize {
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

while finishedCount < targetSize + 1 {
    RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.001))
}

for r in 0 ... targetSize {
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
        if(kana0 != sKana0 ||
           kana1 != sKana1 ||
           kana2 != sKana2) {
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
*/
print(targetSize, "Done")

while sentenceCount < targetSize {
    RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.001))
}
