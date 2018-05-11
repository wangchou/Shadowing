//
//  GameRecord.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/10.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation

fileprivate let context = GameContext.shared

fileprivate let defaults = UserDefaults.standard
fileprivate let gameHistoryKey = "game record array"

func saveGameHistory() {
    let gameHistoryData = NSKeyedArchiver.archivedData(withRootObject: Array(context.gameHistory.values))
    defaults.set(gameHistoryData, forKey: gameHistoryKey)
}

func loadGameHistory() {
    guard let gameHistoryData = defaults.data(forKey: gameHistoryKey) else { return }
    let gameHistoryArray = NSKeyedUnarchiver.unarchiveObject(with: gameHistoryData) as! [GameRecord]
    for gameRecord in gameHistoryArray {
        context.gameHistory[gameRecord.dataSetKey] = gameRecord
    }
}

class GameRecord: NSObject, NSCoding {
    let dataSetKey: String
    let sentencesCount: Int
    var perfectCount = 0
    var greatCount = 0
    var goodCount = 0
    
    var p: Float {
        let sum = perfectCount.f + greatCount.f + goodCount.f * 0.5
        return 100 * sum / sentencesCount.f
    }
    
    var progress: String {
        let prefix = p < 10 ? "0" : ""
        return "\(prefix)\(p.i)%"
    }
    
    func getGreatP() -> Float {
        let sum = (perfectCount + greatCount).f
        return 100 * sum / sentencesCount.f
    }
    
    var rank: String {
        let p = getGreatP()
        if p == 100 && perfectCount.f * 1.2 >=  sentencesCount.f { return "SS" }
        if p == 100 { return "S" }
        if p >= 90 { return "A" }
        if p >= 80 { return "B" }
        if p >= 70 { return "C" }
        if p >= 60 { return "D" }
        if p >= 40 { return "E" }
        return "F"
    }
    
    init(_ dataSetKey: String, sentencesCount: Int) {
        self.dataSetKey = dataSetKey
        self.sentencesCount = sentencesCount
    }
    
    required init(coder decoder: NSCoder) {
        self.dataSetKey = decoder.decodeObject(forKey: "dataSetKey") as! String
        self.sentencesCount = decoder.decodeInteger(forKey: "sentencesCount")
        self.perfectCount = decoder.decodeInteger(forKey: "perfectCount")
        self.greatCount = decoder.decodeInteger(forKey: "greatCount")
        self.goodCount = decoder.decodeInteger(forKey: "goodCount")
        super.init()
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.dataSetKey, forKey: "dataSetKey")
        coder.encodeCInt(Int32(self.sentencesCount), forKey: "sentencesCount")
        coder.encodeCInt(Int32(self.perfectCount), forKey: "perfectCount")
        coder.encodeCInt(Int32(self.greatCount), forKey: "greatCount")
        coder.encodeCInt(Int32(self.goodCount), forKey: "goodCount")
    }
}
