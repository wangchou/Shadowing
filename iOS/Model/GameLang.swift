//
//  GameLang.swift
//  今話したい
//
//  Created by Wangchou Lu on 11/2/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

private let gameLangKey = "GameLangKey"

// https://stackoverflow.com/questions/44580719/how-do-i-make-an-enum-decodable-in-swift-4
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
            GameContext.shared.contentTab = .infiniteChallenge
        }
    }
}

var jaSentenceInfos: [Int: SentenceInfo] = [:]
var enSentenceInfos: [Int: SentenceInfo] = [:]

enum Lang: Int, Codable {
    case jp, en

    var key: String {
        if self == .jp { return "" }
        if self == .en { return "en" }
        return ""
    }
    var isSupportTopicMode: Bool {
        if self == .jp { return true }
        return false
    }

    var sentenceInfos: [Int: SentenceInfo] {
        switch self {
        case .jp:
            return jaSentenceInfos
        case .en:
            return enSentenceInfos
        }
    }

    var prefix: String {
        switch self {
        case .jp:
            return "ja"
        case .en:
            return "en"
        }
    }
}

var gameLang: Lang = Lang.jp
