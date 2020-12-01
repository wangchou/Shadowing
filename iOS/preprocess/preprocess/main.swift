//
//  main.swift
//  SentenceTests
//
//  Created by Wangchou Lu on R 2/11/12.
//
// swiftlint:disable force_try
import Foundation
import Promises
import SwiftSyllables
import RealmSwift

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
    return rows.filter { row in
        return row.count > 5
    }
}

var rows = getSentences()
print(rows.count)

// checkKanaFixes(rows: rows)
// checkTTSFixes(rows: rows)
private var isCopyOnly = true
private var realm: Realm!

func createWritableDB() {
    do {
        if isCopyOnly {
            let config = Realm.Configuration(
                readOnly: true)
            realm = try Realm(configuration: config)
        } else {
            realm = try Realm()
        }
    } catch {
        print("db update error: \(error)")
    }
}

var isAddedToTokenInfo: [String: Bool] = [:]
func updateIdWithListened(ja: String, kanaCount: Int, tokenInfos: [[String]]) {
    guard isAddedToTokenInfo[ja] != true else { return }
    do {
        let rmTokenInfos = RMTokenInfos()
        rmTokenInfos.ja = ja
        rmTokenInfos.kanaCount = kanaCount
        rmTokenInfos.tokenInfos = tokenInfosToString(tokenInfos: tokenInfos)
        try realm.write {                  // 新增資料
            realm.add(rmTokenInfos)
        }
        isAddedToTokenInfo[ja] = true
    } catch {
        print("db update error: \(error)")
    }
}

private var isFinished = false
func waitForFinishing() {
    while !isFinished {
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.001))
    }
}

func addTokenInfosTable() {
    var sentences: [String] = []
    rawDataSets.forEach { sArray in
        sentences.append(contentsOf: sArray)
    }
    print(sentences.count)
    for jpn in sentences {
        isFinished = false
        getKana(jpn, originalString: jpn).then { kana in
            updateIdWithListened(ja: jpn,
                                 kanaCount: kana.count,
                                 tokenInfos: kanaTokenInfosCacheDictionary[jpn] ?? [])
            isFinished = true
        }
        waitForFinishing()
    }
}

var jpnOK: [String: Bool] = [:]
var engOK: [String: Bool] = [:]
var jpnDifficulty: [String: Int] = [:]
var engDifficulty: [String: Int] = [:]
var sentences: [(id: Int, jpn: String, eng: String)] = []
var isAddToTranslation: [String: Bool] = [:]
private var topicSentenceIdStart = 1000000

func addStringToIdTable() {
    func addTranslation(origin: String, id: Int) {
        do {
            guard isAddToTranslation[origin] == nil else { return }
            let rmStringToId = RMStringToId()
            rmStringToId.origin = origin
            rmStringToId.id = id

            try realm.write {
                realm.add(rmStringToId)
            }

            isAddToTranslation[origin] = true
        } catch {
            print(error)
        }
    }

    for (id, row) in rows.enumerated() {
        let jpn = row[0]
        let eng = row[1]
        if jpnOK[jpn] == true {
            addTranslation(origin: jpn, id: id)
        }
        if engOK[eng] == true {
            addTranslation(origin: eng, id: id)
        }
    }

    // topic sentence
    var topicSentenceId = topicSentenceIdStart
    for sArray in rawDataSets {
        for topicSentence in sArray {
            topicSentenceId += 1
            addTranslation(origin: topicSentence, id: topicSentenceId)
        }
    }
}

func addSentencesTable() {
    do {
        for (id, row) in rows.enumerated() {
            //if(i % 500 == 0) {
                print(id)
            //}
//            if(i > 2000) {
//                break
//            }

            let jpn0 = row[0]
            let eng0 = row[1]
            sentences.append((id: id, jpn: jpn0, eng: eng0))

            let cmn = row[2]
            let jpn1 = row[3]
            let jpn2 = row[4]
            let eng1 = row[5]
            let eng2 = row[6]
            let eng3 = row[7]
            let eng4 = row[8]
            let ttsFixes = row[14]
            let enSyllablesCount = SwiftSyllables.getSyllables(eng0.spellOutNumbers())
            let enWordDifficulty = DifficultyCalculator.shred.getDifficulty(sentence: eng0)

            engDifficulty[eng0] = enSyllablesCount + Int(Double(enWordDifficulty) * 0.7)

            isFinished = false
            all([
                calculateScore(jpn0, jpn1),
                calculateScore(jpn0, jpn2),
                calculateScoreEn(eng0, eng1),
                calculateScoreEn(eng0, eng2),
                calculateScoreEn(eng0, eng3),
                calculateScoreEn(eng0, eng4)
            ]).then { scores in
                jpnOK[jpn0] = scores[0].value == 100 &&
                              scores[1].value == 100

                // 16202(4 ok) -> 20044 (3 ok) -> 17302 (4 ok or 3 ok + diff > 13)
                var enOKCount = 0
                enOKCount += scores[2].value == 100 ? 1 : 0
                enOKCount += scores[3].value == 100 ? 1 : 0
                enOKCount += scores[4].value == 100 ? 1 : 0
                enOKCount += scores[5].value == 100 ? 1 : 0
                engOK[eng0] = enOKCount == 4 ||
                              (enOKCount >= 3 && (engDifficulty[eng0] ?? 0) > 13)

                isFinished = true
            }
            waitForFinishing()

            isFinished = false
            getKana(jpn0, isFuri: true, originalString: jpn0)
                .then { kana in

                    let rmSentence = RMSentence()
                    rmSentence.id = id
                    rmSentence.ja = jpn0
                    rmSentence.en = eng0
                    rmSentence.cmn = cmn
                    rmSentence.jaTTSFixes = ttsFixes

                    try realm.write {
                        realm.add(rmSentence)
                    }
                    jpnDifficulty[jpn0] = kana.count

                    updateIdWithListened(ja: jpn0,
                                         kanaCount: kana.count,
                                         tokenInfos: kanaTokenInfosCacheDictionary[jpn0] ?? [])
                    isFinished = true
                }
            waitForFinishing()
        }
        // topic sentence
        var topicSentenceId = topicSentenceIdStart
        for sArray in rawDataSets {
            for topicSentence in sArray {
                topicSentenceId += 1
                let rmSentence = RMSentence()
                rmSentence.id = topicSentenceId
                rmSentence.ja = topicSentence
                rmSentence.en = ""
                rmSentence.cmn = topicTranslation[topicSentence] ?? ""
                rmSentence.jaTTSFixes = ""

                try realm.write {
                    realm.add(rmSentence)
                }
            }
        }
    } catch {
        print("db error 5: \(error)")
    }
}

func addJpInfoTables() {
    var isAdded: [String: Bool] = [:]
    var difficultyIds: [Int: [Int]] = [:]
    for difficulty in 0 ... 1000 {
        difficultyIds[difficulty] = []
    }
    for (id, row) in rows.enumerated() {
        let jpn = row[0]
        if let isScoreOK = jpnOK[jpn],
           isScoreOK,
           isAdded[jpn] == nil,
           let difficulty = jpnDifficulty[jpn] {
            isAdded[jpn] = true
            difficultyIds[difficulty]?.append(id)
        }
    }
    var totalJpCount = 0
    print("- jpn difficulty -")
    for difficulty in 0 ... 1000 {
        if let ids = difficultyIds[difficulty],
           !ids.isEmpty {
            let jpInfo = RMJaInfo()
            jpInfo.difficulty = difficulty
            jpInfo.ids = encode(ids) ?? ""
            try! realm.write {
                realm.add(jpInfo)
            }
            print(difficulty, ids.count)
            totalJpCount += ids.count
        }
    }
    print("totalJpCount: \(totalJpCount)")
}

func addEnInfoTables() {
    var isAdded: [String: Bool] = [:]
    var difficultyIds: [Int: [Int]] = [:]
    for difficulty in 0 ... 1000 {
        difficultyIds[difficulty] = []
    }
    for (id, row) in rows.enumerated() {
        let eng = row[1]
        if let isScoreOK = engOK[eng],
           isScoreOK,
           isAdded[eng] == nil,
           let difficulty = engDifficulty[eng] {
            isAdded[eng] = true
            difficultyIds[difficulty]?.append(id)
        }
    }
    var totalEnCount = 0
    print("- en difficulty -")
    for difficulty in 0 ... 1000 {
        if let ids = difficultyIds[difficulty],
           !ids.isEmpty {
            let enInfo = RMEnInfo()
            enInfo.difficulty = difficulty
            enInfo.ids = encode(ids) ?? ""
            try! realm.write {
                realm.add(enInfo)
            }
            print(difficulty, ids.count)
            totalEnCount += ids.count
        }
    }
    print("totalEnCount: \(totalEnCount)")
}

func encryptDBAndCopy() {
    if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
        let fileURL = dir.appendingPathComponent("default.realm")
        print(fileURL)
        do {
            // Generate 64 bytes of random data to serve as the encryption key
            let key = NSMutableData(length: 64)!
            let status = SecRandomCopyBytes(kSecRandomDefault,
                                           key.length,
                                           key.mutableBytes)
            guard status == 0 else {
                print("generate key failed")
                return
            }
            print((key as Data).hexadecimal)
            try realm.writeCopy(toFile: fileURL,
                                encryptionKey: key as Data)
            print("copy and encrypted to fileURL: \(fileURL)")
        } catch {
            print(error)
        }
    }
}

func runAll() {
    createWritableDB()
    if !isCopyOnly {
        addTokenInfosTable()
        addSentencesTable()
        addStringToIdTable()
        addJpInfoTables()
        addEnInfoTables()
        print("unencrypted fileURL: \(realm.configuration.fileURL!)")
    }
    encryptDBAndCopy()
}

runAll()

// https://stackoverflow.com/a/26502285/2797799
extension Data {

    /// Hexadecimal string representation of `Data` object.

    var hexadecimal: String {
        return map { String(format: "%02x", $0) }
            .joined()
    }
}
