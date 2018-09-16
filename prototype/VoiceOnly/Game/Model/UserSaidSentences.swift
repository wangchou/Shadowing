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

var userSaidSentences: [String: String] = [:]

func saveUserSaidSentences() {
    saveToUserDefault(object: userSaidSentences, key: userSaidSentencesKey)
}

func loadUserSaidSentences() {
    if let loadedSentences = loadFromUserDefault(type: type(of: userSaidSentences), key: userSaidSentencesKey) {
        userSaidSentences = loadedSentences
    } else {
        print("error load userSaidSentences failed")
    }
}
