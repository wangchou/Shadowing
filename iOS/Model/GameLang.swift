//
//  GameLang.swift
//  今話したい
//
//  Created by Wangchou Lu on 11/2/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//
import AVFoundation
import Foundation
import Promises

// Global
var jaDifficultyInfos: [Int: DifficultyInfo] = [:]
var enDifficultyInfos: [Int: DifficultyInfo] = [:]

var gameLang: Lang = Lang.jp

// TODO: fix Lang.jp to Lang.ja
enum Lang: Int, Codable {
    case jp, en, unset, zh

    var key: String {
        if self == .jp { return "" }
        if self == .en { return "en" }
        if self == .zh { return "zh" }
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
        case .zh, .unset:
            return [:]
        }
    }

    var prefix: String {
        switch self {
        case .jp:
            return "ja"
        case .en:
            return "en"
        case .zh:
            return "zh"
        case .unset:
            return "unset"
        }
    }

    var defaultCode: String {
        switch self {
        case .jp:
            return "ja-JP"
        case .en:
            if AVSpeechSynthesisVoice.currentLanguageCode().contains("en-") {
                return AVSpeechSynthesisVoice.currentLanguageCode()
            }
            return "en-US"
        case .zh:
            if i18n.isHK {
                return "zh-HK"
            } else if i18n.isCN {
                return "zh-CN"
            } else {
                return "zh-TW"
            }
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
