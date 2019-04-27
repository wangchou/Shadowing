//
//  UserSaidSentences.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 9/17/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation

private let context = GameContext.shared

private let userSaidSentencesKey = "user said sentences key"
private let sentenceScoreKey = "sentence score key"
private let lastChallengeSenteceKey = "last challenge senteces key"
private let lastEnChallengeSenteceKey = "last english challenge senteces key"
private let kanaTokenInfosKey = "kanaTokenInfos key"
private let translationsKey = "translation key"

// look up table for last said sentence and its score
var userSaidSentences: [String: String] = [:]
var sentenceScores: [String: Score] = [:]
var lastInfiniteChallengeSentences: [Level: [String]] = [:]
var kanaTokenInfosCacheDictionary: [String: [[String]]] = [:] //tokenInfo =[kanji, 詞性, furikana, yomikana]
var translations: [String: String] = [:] // en => ja & ja => en

func saveGameMiscData() {
    saveToUserDefault(object: userSaidSentences, key: userSaidSentencesKey + gameLang.key)
    saveToUserDefault(object: sentenceScores, key: sentenceScoreKey + gameLang.key)
    saveToUserDefault(object: lastInfiniteChallengeSentences, key: lastChallengeSenteceKey + gameLang.key)
    saveToUserDefault(object: translations, key: translationsKey + gameLang.key)

    guard gameLang == Lang.jp else { return }
    saveToUserDefault(object: kanaTokenInfosCacheDictionary, key: kanaTokenInfosKey + gameLang.key)
}

func easyLoad<T: Codable>(object: inout T, key: String) {
    // swiftlint:disable force_cast
    if let loaded = loadFromUserDefault(type: type(of: object), key: key) {
        object = loaded
    } else {
        print("[\(gameLang)] create new object")
        object = [:] as! T
    }
    // swiftlint:enable force_cast
}

func loadGameMiscData(isLoadKana: Bool = false, isAsync: Bool = false) {
    if isAsync {
        DispatchQueue.global().async {
            easyLoad(object: &translations, key: translationsKey + gameLang.key)
        }
        DispatchQueue.global().async {
            easyLoad(object: &userSaidSentences, key: userSaidSentencesKey + gameLang.key)
        }
        DispatchQueue.global().async {
            easyLoad(object: &sentenceScores, key: sentenceScoreKey  + gameLang.key)
        }
        DispatchQueue.global().async {
            easyLoad(object: &lastInfiniteChallengeSentences, key: lastChallengeSenteceKey + gameLang.key)
        }
    } else {
        easyLoad(object: &translations, key: translationsKey + gameLang.key)
        easyLoad(object: &userSaidSentences, key: userSaidSentencesKey + gameLang.key)
        easyLoad(object: &sentenceScores, key: sentenceScoreKey  + gameLang.key)
        easyLoad(object: &lastInfiniteChallengeSentences, key: lastChallengeSenteceKey + gameLang.key)
    }
    guard isLoadKana else { return }

    DispatchQueue.global().async {
        if let loadedKanaTokenInfos = loadFromUserDefault(type: type(of: kanaTokenInfosCacheDictionary), key: kanaTokenInfosKey + Lang.jp.key) {
            let validSentenceSet: Set<String> = Set(userSaidSentences.values).union(Set(userSaidSentences.keys))
            //print("\t\t key count: \(validSentenceSet.count) / \(loadedKanaTokenInfos.keys.count)")
            for key in validSentenceSet {
                if let value = loadedKanaTokenInfos[key] {
                    kanaTokenInfosCacheDictionary[key] = value
                }
            }
            print("kanaInfo loaded")
        } else {
            print("create new kanaTokenInfos")
        }
    }

}
