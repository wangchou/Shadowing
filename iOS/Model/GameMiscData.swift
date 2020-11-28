//
//  UserSaidSentences.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 9/17/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation
import Promises

private let context = GameContext.shared

// Global
// look up table for last said sentence and its score
var userSaidSentences: [String: String] = [:]
var sentenceScores: [String: Score] = [:]
var lastInfiniteChallengeSentences: [Level: [String]] = [:]
var kanaTokenInfosCacheDictionary: [String: [[String]]] = [:] //tokenInfo =[kanji, 詞性, furikana, yomikana]

// MARK: - Save and Load

private let userSaidSentencesKey = "user said sentences key"
private let sentenceScoreKey = "sentence score key"
private let lastChallengeSenteceKey = "last challenge senteces key 1.4.0"
private let lastEnChallengeSenteceKey = "last english challenge senteces key 1.4.0"
private let kanaTokenInfosKey = "kanaTokenInfos key"
private let translationsKey = "translation key"

func saveGameMiscData() {
    DispatchQueue.global().async {
        saveToUserDefault(object: userSaidSentences, key: userSaidSentencesKey + gameLang.key)
        saveToUserDefault(object: sentenceScores, key: sentenceScoreKey + gameLang.key)
        saveToUserDefault(object: lastInfiniteChallengeSentences, key: lastChallengeSenteceKey + gameLang.key)
        guard gameLang == Lang.ja else { return }
        saveToUserDefault(object: kanaTokenInfosCacheDictionary, key: kanaTokenInfosKey + gameLang.key)
    }
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

var waitSentenceScoresLoaded = fulfilledVoidPromise()
var waitUserSaidSentencesLoaded = fulfilledVoidPromise()
var waitKanaInfoLoaded = Promise<Void>.pending()

func loadGameMiscData(isLoadKana: Bool = false) {
    waitSentenceScoresLoaded = Promise<Void>.pending()
    waitUserSaidSentencesLoaded = Promise<Void>.pending()

    DispatchQueue.global().async {
        easyLoad(object: &userSaidSentences, key: userSaidSentencesKey + gameLang.key)
        waitUserSaidSentencesLoaded.fulfill(())
    }
    DispatchQueue.global().async {
        easyLoad(object: &sentenceScores, key: sentenceScoreKey + gameLang.key)
        waitSentenceScoresLoaded.fulfill(())
    }
    DispatchQueue.global().async {
        easyLoad(object: &lastInfiniteChallengeSentences, key: lastChallengeSenteceKey + gameLang.key)
    }

    guard isLoadKana else { return }
    if let loadedKanaTokenInfos = loadFromUserDefault(type: type(of: kanaTokenInfosCacheDictionary),
                                                      key: kanaTokenInfosKey + Lang.ja.key) {
        loadedKanaTokenInfos.keys.forEach { key in
            guard kanaTokenInfosCacheDictionary[key] == nil else { return }
            kanaTokenInfosCacheDictionary[key] = loadedKanaTokenInfos[key]
        }
    } else {
        print("use new kanaTokenInfos")
    }
    waitKanaInfoLoaded.fulfill(())
}
