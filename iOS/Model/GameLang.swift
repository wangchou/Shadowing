//
//  GameLang.swift
//  今話したい
//
//  Created by Wangchou Lu on 11/2/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

private let gameLangKey = "GameLangKey"

func saveGameLang() {
    saveToUserDefault(object: gameLang, key: gameLangKey)
}

func loadGameLang() {
    if let loadedGameLang = loadFromUserDefault(type: Lang.self, key: gameLangKey) {
        gameLang = loadedGameLang
    }
}

enum Lang: String, Codable {
    case jp = ""
    case en = "en"

    var isSupportTopicMode: Bool {
        return self == Lang.jp ? true : false
    }
}

var gameLang: Lang = Lang.jp
