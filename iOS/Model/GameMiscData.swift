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
var translations: [String: String] = [:] // en => ja & ja => en

// MARK: - Save and Load
private let userSaidSentencesKey = "user said sentences key"
private let sentenceScoreKey = "sentence score key"
private let lastChallengeSenteceKey = "last challenge senteces key"
private let lastEnChallengeSenteceKey = "last english challenge senteces key"
private let kanaTokenInfosKey = "kanaTokenInfos key"
private let translationsKey = "translation key"

func saveGameMiscData() {
    DispatchQueue.global().async {
        saveToUserDefault(object: userSaidSentences, key: userSaidSentencesKey + gameLang.key)
        saveToUserDefault(object: sentenceScores, key: sentenceScoreKey + gameLang.key)
        saveToUserDefault(object: lastInfiniteChallengeSentences, key: lastChallengeSenteceKey + gameLang.key)
        saveToUserDefault(object: translations, key: translationsKey + gameLang.key)

        guard gameLang == Lang.jp else { return }
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
        easyLoad(object: &translations, key: translationsKey + gameLang.key)
    }
    DispatchQueue.global().async {
        easyLoad(object: &userSaidSentences, key: userSaidSentencesKey + gameLang.key)
        waitUserSaidSentencesLoaded.fulfill(())
    }
    DispatchQueue.global().async {
        easyLoad(object: &sentenceScores, key: sentenceScoreKey  + gameLang.key)
        waitSentenceScoresLoaded.fulfill(())
    }
    DispatchQueue.global().async {
        easyLoad(object: &lastInfiniteChallengeSentences, key: lastChallengeSenteceKey + gameLang.key)
        clear130KanaSideEffect()
    }

    guard isLoadKana else { return }

    DispatchQueue.global().async {
        if let loadedKanaTokenInfos = loadFromUserDefault(type: type(of: kanaTokenInfosCacheDictionary),
                                                          key: kanaTokenInfosKey + Lang.jp.key) {
            loadedKanaTokenInfos.keys.forEach { key in
                guard kanaTokenInfosCacheDictionary[key] == nil else { return }
                kanaTokenInfosCacheDictionary[key] = loadedKanaTokenInfos[key]
            }
            doKanaCacheHardFix()
        } else {
            print("use new kanaTokenInfos")
        }
        waitKanaInfoLoaded.fulfill(())
    }
}

// clear version 1.3.0 & 1.3.1 kana is cleared side effect
// should be remove after 1.4.0
var sideEffectIsCleared = false

func clear130KanaSideEffect() {
    guard gameLang == .jp, !sideEffectIsCleared else { return }

    waitKanaInfoLoaded.then { _ in
        // said topic sentences
        rawDataSets.forEach { sentences in
            sentences.forEach { sentence in
                if let userSaidSentence = userSaidSentences[sentence],
                    userSaidSentence != "",
                    kanaTokenInfosCacheDictionary[userSaidSentence] == nil {
                    _ = userSaidSentence.furiganaAttributedString
                }
            }
        }

        // said ic sentences
        for (_, sentences) in lastInfiniteChallengeSentences {
            sentences.forEach { sentence in
                if kanaTokenInfosCacheDictionary[sentence] == nil {
                    _ = sentence.furiganaAttributedString
                }
                if let userSaidSentence = userSaidSentences[sentence],
                    userSaidSentence != "",
                    kanaTokenInfosCacheDictionary[userSaidSentence] == nil {
                    _ = userSaidSentence.furiganaAttributedString
                }
            }
        }

        sideEffectIsCleared = true
    }
}
