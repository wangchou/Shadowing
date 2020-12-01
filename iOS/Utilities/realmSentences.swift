//
//  sqliteSentences.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 10/11/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation
import Promises
import RealmSwift

struct Sentence: Hashable, Equatable {
    var id: Int
    var ja: String
    var en: String
    var cmn: String
    #if os(iOS)
    var origin: String {
        return gameLang == Lang.ja ? ja : en
    }

    var translation: String {
        switch GameContext.shared.gameSetting.translationLang {
        case .ja:
            return ja
        case .en:
            return en
        case .zh:
            return cmn
        default:
            return cmn
        }
    }
    #endif

    var ttsFixes: [(String, String)]

    func hash(into hasher: inout Hasher) {
        hasher.combine(ja)
        hasher.combine(en)
    }
    static func == (lhs: Sentence, rhs: Sentence) -> Bool {
        return lhs.ja == rhs.ja && lhs.en == rhs.en
    }
}

struct DifficultyInfo {
    var difficulty: Int
    var ids: Set<Int>
    var sentenceCount: Int {
        return ids.count
    }
}

struct TopicSentenceInfo {
    var ja: String
    var kanaCount: Int
}

var topicSentencesInfos: [String: TopicSentenceInfo] = [:]

let config = Realm.Configuration(
    fileURL: Bundle.main.url(forResource: "default", withExtension: "realm"),
    encryptionKey: dbKey,
    readOnly: true)

private var realm: Realm!

func initDB() {
    do {
        realm = try Realm(configuration: config)
    } catch {
        print(error.localizedDescription)
    }
}
#if os(iOS)
    var waitDifficultyDBLoaded = Promise<Void>.pending()
    func loadDifficultyInfo() {
        waitDifficultyDBLoaded = Promise<Void>.pending()

        for row in realm.objects(RMJaInfo.self) {
            let idArray: [Int] = decode(type: [Int].self, jsonString: row.ids) ?? []
            let ids: Set<Int> = Set(idArray)
            let difficulty = row.difficulty
            jaDifficultyInfos[difficulty] = DifficultyInfo(difficulty: difficulty, ids: ids)
        }

        for row in realm.objects(RMEnInfo.self) {
            let idArray: [Int] = decode(type: [Int].self, jsonString: row.ids) ?? []
            let ids: Set<Int> = Set(idArray)
            let difficulty = row.difficulty
            enDifficultyInfos[difficulty] = DifficultyInfo(difficulty: difficulty, ids: ids)
        }
        waitDifficultyDBLoaded.fulfill(())
    }

func loadTopicSentenceDB() {
    let t1 = getNow()
    guard topicSentencesInfos.isEmpty else { return }

    let topicSentences = rawDataSets.flatMap { $0 }
    topicSentences.forEach {ja in
        if let rmTokenInfos = realm.object(ofType: RMTokenInfos.self, forPrimaryKey: ja) {
            kanaTokenInfosCacheDictionary[ja] = stringToTokenInfos(jsonString: rmTokenInfos.tokenInfos)
            topicSentencesInfos[ja] = TopicSentenceInfo(ja: ja, kanaCount: rmTokenInfos.kanaCount)
        } else {
            print("cannot find tokenInfos with ja = \(ja)")
        }
    }
    print("topicSentences loaded in \(getNow() - t1)")
}

func loadTokenInfos(ja: String) {
    if let rmTokenInfos = realm.object(ofType: RMTokenInfos.self, forPrimaryKey: ja) {
        kanaTokenInfosCacheDictionary[ja] = stringToTokenInfos(jsonString: rmTokenInfos.tokenInfos)
        topicSentencesInfos[ja] = TopicSentenceInfo(ja: ja, kanaCount: rmTokenInfos.kanaCount)
    }
}

private func getSentencesByIds(ids: [Int]) -> [Sentence] {
    var sentences: [Sentence] = []
    ids.forEach { id in
        if let rmSentence = realm.object(ofType: RMSentence.self, forPrimaryKey: id) {
            let ttsFixes = arrayToPair(rmSentence.jaTTSFixes.components(separatedBy: " "))
            sentences.append(Sentence(id: rmSentence.id,
                                      ja: rmSentence.ja,
                                      en: rmSentence.en,
                                      cmn: rmSentence.cmn,
                                      ttsFixes: ttsFixes))
        } else {
            print("cannot find rmSentence with id = \(id)")
        }
    }
    return sentences
}

func getSentenceByString(_ string: String) -> Sentence {
    //print(string)
    if let rmStringToId = realm.object(ofType: RMStringToId.self, forPrimaryKey: string) {
        //print(rmStringToId)
        if let rmSentence = realm.object(ofType: RMSentence.self, forPrimaryKey: rmStringToId.id) {
            //print(rmSentence)
            let ttsFixes = arrayToPair(rmSentence.jaTTSFixes.components(separatedBy: " "))

            let sentence =  Sentence(id: rmSentence.id,
                            ja: rmSentence.ja,
                            en: rmSentence.en,
                            cmn: rmSentence.cmn,
                            ttsFixes: ttsFixes)
            return sentence
        } else {
            print("cannot find rmSentence with id = \(rmStringToId.id)")
        }
    } else {
        print("cannot find rmStringToId with string = \(string)")
    }
    return Sentence(id: -1, ja: "", en: "", cmn: "", ttsFixes: [])
}

func getSentenceCount(minKanaCount: Int, maxKanaCount: Int) -> Int {
    var sentenceCount = 0
    for kanaCount in minKanaCount ... maxKanaCount {
        if let count = gameLang.difficultyInfos[kanaCount]?.sentenceCount {
            sentenceCount += count
        }
    }

    return sentenceCount
}

func getRandSentences(level: Level, numOfSentences: Int) -> [Sentence] {
    let minKanaCount = level.minSyllablesCount
    let maxKanaCount = level.maxSyllablesCount
    var combinedIds: Set<Int> = []
    for kanaCount in minKanaCount ... maxKanaCount {
        if let ids = gameLang.difficultyInfos[kanaCount]?.ids {
            combinedIds = combinedIds.union(ids)
        }
    }

    var randomIds: [Int] = []
    var randomSentences: [Sentence] = []
    while randomSentences.count < numOfSentences {
        while randomIds.count < numOfSentences + numOfSentences / 2 {
            if let newId = combinedIds.randomElement() {
                if !randomIds.contains(newId) {
                    randomIds.append(newId)
                }
            }
        }

        let sentences = getSentencesByIds(ids: randomIds)
        for s in sentences {
            let isSame = !randomSentences.filter { randS in
                if gameLang == Lang.ja {
                    return s.ja == randS.ja
                } else {
                    return s.en == randS.en
                }
            }.isEmpty
            if !isSame {
                randomSentences.append(s)
                if randomSentences.count == numOfSentences {
                    return randomSentences
                }
            }
        }
    }
    return randomSentences
}
#endif
