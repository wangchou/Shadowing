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

func loadGameMiscData() {
    guard userSaidSentences.isEmpty else { return }
    if let loadedSentences = loadFromUserDefault(type: type(of: userSaidSentences), key: userSaidSentencesKey + gameLang.key) {
        userSaidSentences = loadedSentences
    } else {
        print("[\(gameLang)] create new userSaidSentences")
        userSaidSentences = [:]
    }
    if let loadedScores = loadFromUserDefault(type: type(of: sentenceScores), key: sentenceScoreKey + gameLang.key) {
        sentenceScores = loadedScores
    } else {
        print("[\(gameLang)] create new sentencesScores")
        sentenceScores = [:]
    }
    if let loadedICSentences = loadFromUserDefault(type: type(of: lastInfiniteChallengeSentences), key: lastChallengeSenteceKey + gameLang.key) {
        lastInfiniteChallengeSentences = loadedICSentences
    } else {
        print("[\(gameLang)] create new lastInfiniteChallengeSentences")
        lastInfiniteChallengeSentences = [:]
    }

    if let loadedTranslations = loadFromUserDefault(type: type(of: translations), key: translationsKey + gameLang.key) {
        translations = loadedTranslations
    } else {
        print("[\(gameLang)] create new translations")
        translations = [:]
    }

    guard gameLang == Lang.jp else { return }

    if let loadedKanaTokenInfos = loadFromUserDefault(type: type(of: kanaTokenInfosCacheDictionary), key: kanaTokenInfosKey + gameLang.key) {
        loadedKanaTokenInfos.keys.forEach { key in
            kanaTokenInfosCacheDictionary[key] = loadedKanaTokenInfos[key]
        }
    } else {
        print("create new kanaTokenInfos")
    }
}
