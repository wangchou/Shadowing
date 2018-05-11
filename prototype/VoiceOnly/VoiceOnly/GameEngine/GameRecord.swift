//
//  GameRecord.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/10.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation

fileprivate let context = GameContext.shared

let defaults = UserDefaults.standard
let gameHistoryKey = "game record array"

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
    var perfectCount: Int
    var greatCount: Int
    var goodCount: Int
    
    func getP() -> Int {
        let sum = Float(perfectCount + greatCount) + Float(goodCount) * 0.5
        return Int(100 * sum / Float(sentencesCount))
    }
    
    func getGreatP() -> Int {
        let sum = Float(perfectCount + greatCount)
        return Int(100 * sum / Float(sentencesCount))
    }
    
    var rank: String {
        let p = getGreatP()
        if p == 100 && Int(Float(perfectCount) * 1.2) >=  sentencesCount { return "SS" }
        if p == 100 { return "S" }
        if p >= 90 { return "A" }
        if p >= 80 { return "B" }
        if p >= 70 { return "C" }
        if p >= 60 { return "D" }
        if p >= 40 { return "E" }
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
    
    required init(coder decoder: NSCoder) {
        //Error here "missing argument for parameter name in call
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
