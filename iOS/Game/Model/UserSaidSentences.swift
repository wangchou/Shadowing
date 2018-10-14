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

// look up table for last said sentence and its score
var userSaidSentences: [String: String] = [:]
var sentenceScores: [String: Score] = [:]
var lastInfiniteChallengeSentences: [Level: [String]] = [:]

func saveUserSaidSentencesAndScore() {
    saveToUserDefault(object: userSaidSentences, key: userSaidSentencesKey)
    saveToUserDefault(object: sentenceScores, key: sentenceScoreKey)
    saveToUserDefault(object: lastInfiniteChallengeSentences, key: lastChallengeSenteceKey)
}

func loadUserSaidSentencesAndScore() {
    if let loadedSentences = loadFromUserDefault(type: type(of: userSaidSentences), key: userSaidSentencesKey) {
        userSaidSentences = loadedSentences
    } else {
        print("error load userSaidSentences failed")
    }
    if let loadedScores = loadFromUserDefault(type: type(of: sentenceScores), key: sentenceScoreKey) {
        sentenceScores = loadedScores
    } else {
        print("error load scores fail")
    }
    if let loadedICSentences = loadFromUserDefault(type: type(of: lastInfiniteChallengeSentences), key: lastChallengeSenteceKey) {
        lastInfiniteChallengeSentences = loadedICSentences
    } else {
        print("error load infinite challenge sentences fail")
    }
}