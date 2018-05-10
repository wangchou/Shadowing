//
//  GameRecord.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/10.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation

struct GameRecord {
    let dataSetKey: String
    let sentencesCount: Int
    var perfectCount: Int
    var greatCount: Int
    var goodCount: Int
    
    func getP() -> Int {
        return 100 * (perfectCount + greatCount + goodCount) / sentencesCount
    }
    
    func getGreatP() -> Int {
        return 100 * (perfectCount + greatCount) / sentencesCount
    }
    
    var rank: String {
        let p = getGreatP()
        if p == 100 && perfectCount == sentencesCount { return "SS" }
        if p == 100 { return "S" }
        if p > 90 { return "A" }
        if p > 80 { return "B" }
        if p > 70 { return "C" }
        if p > 60 { return "D" }
        if p > 50 { return "E" }
        return "F"
    }
    
    init(_ dataSetKey: String, sentencesCount: Int, perfectCount: Int = 0, greatCount: Int = 0, goodCount: Int = 0) {
        self.dataSetKey = dataSetKey
        self.sentencesCount = sentencesCount
        self.perfectCount = perfectCount
        self.greatCount = greatCount
        self.goodCount = goodCount
    }
    
    var progress: String {
        let p = getP()
        let prefix = p < 10 ? "0" : ""
        return "\(prefix)\(getP())%"
    }
}
