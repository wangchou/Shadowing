//
//  ViewController.swift
//  addTopicSentencesTable
//
//  Created by Wangchou Lu on 10/17/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Cocoa
import SQLite
import Promises

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        runAll()
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

private var topicTableName = "topicSentencesInfo"
private var sqliteFileName = "inf_sentences_100points_duolingo"
private var writableDBPath = ""
var dbW: Connection!

func createWritableDB() {
    let fileManager = FileManager.default
    do {
        writableDBPath = try fileManager
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("\(sqliteFileName)_with_topics.sqlite")
            .path

        if !fileManager.fileExists(atPath: writableDBPath) {
            print("not exist")
            let dbResourcePath = Bundle.main.path(forResource: sqliteFileName, ofType: "sqlite")!
            try fileManager.copyItem(atPath: dbResourcePath, toPath: writableDBPath)
        } else {
            print("exist")
        }
        dbW = try Connection(writableDBPath, readonly: false)
    } catch {
        print("\(error)")
    }
}

func runAll() {
    do {
        createWritableDB()
        dbW = try Connection(writableDBPath, readonly: false)
        let topicSentencesTable = Table(topicTableName)
        let id = Expression<Int>("id")
        let kana_count = Expression<Int>("kana_count")
        let ja = Expression<String>("ja")
        let tokenInfos = Expression<String>("tokenInfos")
        try dbW.run(topicSentencesTable.drop(ifExists: true))
        try dbW.run(topicSentencesTable.create { t in
            t.column(id, primaryKey: true)
            t.column(kana_count)
            t.column(ja)
            t.column(tokenInfos)
        })
        var sentences: [String] = []
        rawDataSets.forEach { sArray in
            sentences.append(contentsOf: sArray)
        }
        print(sentences.count)
        var kanaPromises: [Promise<String>] = []
        sentences.forEach {s in
            kanaPromises.append(getKana(s))
        }
        all(kanaPromises).then { kanas in
            for id in 0..<kanas.count {
                updateIdWithListened(id: id, kana_count: kanas[id].count, ja: sentences[id], tokenInfos: kanaTokenInfosCacheDictionary[sentences[id]] ?? [])
            }
        }

    } catch {
        print("db error: \(error)")
    }
}

func updateIdWithListened(id: Int, kana_count: Int, ja: String, tokenInfos: [[String]]) {
    do {
        let topicTable = Table(topicTableName)
        let dbId = Expression<Int>("id")
        let dbJa = Expression<String>("ja")
        let dbKanaCount = Expression<Int>("kana_count")
        let dbTokenInfos = Expression<String>("tokenInfos")

        let insertSql = topicTable.insert(dbId <- id, dbKanaCount <- kana_count, dbJa <- ja, dbTokenInfos <- tokenInfosToString(tokenInfos: tokenInfos))
        try dbW.run(insertSql)
    } catch {
        print("db update error: \(error)")
    }
}
