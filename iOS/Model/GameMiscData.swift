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
private let kanaTokenInfosKey = "kanaTokenInfos key"

// look up table for last said sentence and its score
var userSaidSentences: [String: String] = [:]
var sentenceScores: [String: Score] = [:]
var lastInfiniteChallengeSentences: [Level: [String]] = [:]
var kanaTokenInfosCacheDictionary: [String: [[String]]] = [:] //tokenInfo =[kanji, 詞性, furikana, yomikana]

func saveGameMiscData() {
    saveToUserDefault(object: userSaidSentences, key: userSaidSentencesKey + gameLang.rawValue)
    saveToUserDefault(object: sentenceScores, key: sentenceScoreKey + gameLang.rawValue)
    saveToUserDefault(object: lastInfiniteChallengeSentences, key: lastChallengeSenteceKey + gameLang.rawValue)

    guard gameLang == Lang.jp else { return }
    saveToUserDefault(object: kanaTokenInfosCacheDictionary, key: kanaTokenInfosKey + gameLang.rawValue)
}

func loadGameMiscData() {
    guard userSaidSentences.isEmpty else { return }
    if let loadedSentences = loadFromUserDefault(type: type(of: userSaidSentences), key: userSaidSentencesKey + gameLang.rawValue) {
        userSaidSentences = loadedSentences
    } else {
        print("[\(gameLang)] create new userSaidSentences")
        userSaidSentences = [:]
    }
    if let loadedScores = loadFromUserDefault(type: type(of: sentenceScores), key: sentenceScoreKey + gameLang.rawValue) {
        sentenceScores = loadedScores
    } else {
        print("[\(gameLang)] create new sentencesScores")
        sentenceScores = [:]
    }
    if let loadedICSentences = loadFromUserDefault(type: type(of: lastInfiniteChallengeSentences), key: lastChallengeSenteceKey + gameLang.rawValue) {
        lastInfiniteChallengeSentences = loadedICSentences
    } else {
        print("[\(gameLang)] create new lastInfiniteChallengeSentences")
        lastInfiniteChallengeSentences = [:]
    }

    guard gameLang == Lang.jp else { return }

    if let loadedKanaTokenInfos = loadFromUserDefault(type: type(of: kanaTokenInfosCacheDictionary), key: kanaTokenInfosKey + gameLang.rawValue) {
        loadedKanaTokenInfos.keys.forEach { key in
            kanaTokenInfosCacheDictionary[key] = loadedKanaTokenInfos[key]
        }
    } else {
        print("create new kanaTokenInfos")
    }
}
