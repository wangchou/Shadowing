//
//  main.swift
//  SentenceTests
//
//  Created by Wangchou Lu on R 2/11/12.
//

import Foundation

print("Hello, World!")

var isRequestDone = false
getKana("空銀子")
    .then { kana in
        isRequestDone = true
        print(kana.kataganaToHiragana)
    }

while(!isRequestDone) {
    RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))
}
