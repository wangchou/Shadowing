//
//  checks.swift
//  preprocess
//
//  Created by Wangchou Lu on R 2/11/21.
//

import Foundation
import Promises

var targetIndex = 2000 // rows.count - 1
var batchSize = 10
func checkKanaFixes(rows: [[String]]) {
    var swiftKana: [String: String] = [:]
    var finishedCount = 0
    for r in 0 ... targetIndex {
        let jpn0 = rows[r][0]
        let jpn1 = rows[r][3]
        let jpn2 = rows[r][4]
        all([
            getKana(jpn0, isFuri: true, originalString: jpn0),
            getKana(jpn1, isFuri: true, originalString: jpn0),
            getKana(jpn2, isFuri: true, originalString: jpn0),
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

func checkTTSFixes(rows: [[String]]) {
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
