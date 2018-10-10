//
//  InfiniteChanllengePage.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 10/8/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit
import SQLite

struct KanaInfo {
    var kanaCount: Int
    var startId: Int
    var sentenceCount: Int
}

private var kanaInfos: [Int: KanaInfo] = [:]

class InfiniteChallengePage: UIViewController {
    @IBOutlet weak var topBarView: TopBarView!
    var topBarTitle: String = "無限挑戰模式"
    var topBarLeftText: String = ""
    var topBarRightText: String = ""
    var level: Level = .lv0
    var minKanaCount: Int {
        return level.minKanaCount
    }
    var maxKanaCount: Int {
        return level.maxKanaCount
    }
    @IBOutlet weak var infoView: ICInfoView!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadSentenceDB()
        updateUI()
        infoView.viewWillAppear()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        infoView.level = level
        infoView.minKanaCount = minKanaCount
        infoView.maxKanaCount = maxKanaCount
        infoView.sentencesCount = getSentenceCount(minKanaCount: minKanaCount, maxKanaCount: maxKanaCount)
        infoView.viewWillAppear()
    }

    func updateUI() {
        if topBarRightText == "" {
            topBarView.rightButton.isHidden = true
        } else {
            topBarView.rightButton.setIconImage(named: "round_arrow_forward_ios_black_48pt", title: topBarRightText, isIconOnLeft: false)
        }
        if topBarLeftText != "" {
            topBarView.leftButton.setIconImage(named: "round_arrow_back_ios_black_48pt", title: topBarLeftText)
        } else {
            topBarView.leftButton.setIconImage(named: "outline_settings_black_48pt")
        }
        topBarView.titleLabel.text = topBarTitle
    }
}

func loadSentenceDB() {
    guard let path = Bundle.main.path(forResource: "infinite_sentences", ofType: "sqlite") else {
        print("sqlite file not found"); return
    }
    do {
        let db = try Connection(path, readonly: true)
        let kanaInfoTable = Table("kanaInfo")
        let kanaCount = Expression<Int>("kana_count")
        let startId = Expression<Int>("start_id")
        let sentenceCount = Expression<Int>("sentence_count")
        for row in try db.prepare(kanaInfoTable) {
            let kanaInfo = KanaInfo(kanaCount: row[kanaCount], startId: row[startId], sentenceCount: row[sentenceCount])
            kanaInfos[row[kanaCount]] = kanaInfo
        }
    } catch {
        print("db error")
    }
}

func getSentencesByIds(ids: [Int]) -> [String] {
    var sentences: [String] = []
    guard let path = Bundle.main.path(forResource: "infinite_sentences", ofType: "sqlite") else {
        print("sqlite file not found"); return sentences
    }
    do {
        let db = try Connection(path, readonly: true)
        let sentenceTable = Table("sentences")
        let dbId = Expression<Int>("id")
        let dbJa = Expression<String>("ja")
        try ids.forEach { id throws in
            let query = sentenceTable.select(dbJa)
                                     .filter(dbId == id)
            for s in try db.prepare(query) {
                sentences.append(s[dbJa])
            }
        }

    } catch {
        print("db error")
    }
    return sentences
}

func getSentenceCount(minKanaCount: Int, maxKanaCount: Int) -> Int {
    guard let startKanaInfo = kanaInfos[minKanaCount],
          let endKanaInfo = kanaInfos[maxKanaCount] else { print("err in getSentenceCount"); return -1}

    let startId = startKanaInfo.startId
    let endId = endKanaInfo.startId + endKanaInfo.sentenceCount - 1

    return endId - startId
}

func randSentenceIds(minKanaCount: Int, maxKanaCount: Int, numOfSentences: Int) -> [Int] {
    guard let startKanaInfo = kanaInfos[minKanaCount],
        let endKanaInfo = kanaInfos[maxKanaCount] else { print("err in randSentenceIds"); return []}

    let startId = startKanaInfo.startId
    let endId = endKanaInfo.startId + endKanaInfo.sentenceCount - 1

    var randomIds: [Int] = []
    for _ in 0..<numOfSentences {
        randomIds.append(Int(arc4random_uniform(UInt32(endId - startId))) + startId)
    }

    return randomIds

}
