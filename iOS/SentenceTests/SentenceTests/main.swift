//
//  main.swift
//  SentenceTests
//
//  Created by Wangchou Lu on R 2/11/12.
//

import Foundation
import Promises

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

var swiftKana: [String: String] = [:]
var targetSize = 1000 // row.count
var finishedCount = 0
var batchSize = 10
for r in 0 ... targetSize {
    let jpn = rows[r][0]
    getKana(jpn, isFuri: true)
        .then { kana in
            swiftKana[jpn] = kana.kataganaToHiragana
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
    let jpn = row[0]
    let jsKana = row[9]
    if let outKana = swiftKana[jpn] {
        if(jsKana != outKana) {
            print(jpn)
            print("jsKana   :", jsKana)
            print("swiftKana:", outKana)
            print("--")
        }
    } else {
        print("Error:", r, jpn)
    }
}

print(1000, "Done")

while finishedCount < rows.count {
    RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.001))
}
