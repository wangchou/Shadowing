//
//  GameLang.swift
//  今話したい
//
//  Created by Wangchou Lu on 11/2/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation
import Promises

// Global
var jaDifficultyInfos: [Int: DifficultyInfo] = [:]
var enDifficultyInfos: [Int: DifficultyInfo] = [:]

var gameLang: Lang = Lang.jp

enum Lang: Int, Codable {
    case jp, en, unset

    var key: String {
        if self == .jp { return "" }
        if self == .en { return "en" }
        return "unset"
    }

    var isSupportTopicMode: Bool {
        if self == .jp { return true }
        return false
    }

    var difficultyInfos: [Int: DifficultyInfo] {
        switch self {
        case .jp:
            return jaDifficultyInfos
        case .en:
            return enDifficultyInfos
        case .unset:
            return [:]
        }
    }

    var prefix: String {
        switch self {
        case .jp:
            return "ja"
        case .en:
            return "en"
        case .unset:
            return "unset"
        }
    }
}

// https://stackoverflow.com/questions/44580719/how-do-i-make-an-enum-decodable-in-swift-4
private let gameLangKey = "GameLangKey 2018/11/23"

private struct LangForEncode: Codable {
    var lang: Lang
}

func saveGameLang() {
    let lang: LangForEncode = LangForEncode(lang: gameLang)
    saveToUserDefault(object: lang, key: gameLangKey)
}

func loadGameLang() {
    if let loadedGameLang = loadFromUserDefault(type: LangForEncode.self, key: gameLangKey) {
        gameLang = loadedGameLang.lang
        if gameLang != .jp {
            GameContext.shared.bottomTab = .infiniteChallenge
        }
    }
}

func changeGameLangTo(lang: Lang) {
    gameLang = lang
    saveGameLang()
    loadGameSetting()
    loadGameMiscData(isLoadKana: false)
    DispatchQueue.main.async {
        if gameLang == .en {
            GameContext.shared.bottomTab = .infiniteChallenge
            rootViewController.showInfiniteChallengePage(idx: 1)
        }
        rootViewController.reloadTableData()
        rootViewController.rerenderTopView(updateByRecords: true)
    }

}
