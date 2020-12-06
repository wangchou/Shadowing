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

var gameLang = i18n.isJa ? Lang.en :Lang.ja

// TODO: fix Lang.ja to Lang.ja
enum Lang: Int, Codable {
    case ja, en, unset, zh, fr, es, de

    var key: String {
        switch self {
        case .ja:
            return ""
        case .en:
            return "en"
        case .zh:
            return "zh"
        case .fr:
            return "fr"
        case .es:
            return "es"
        case .de:
            return "de"
        case .unset:
            return "unset"
        }
    }

    var isSupportTopicMode: Bool {
        if self == .ja { return true }
        return false
    }

    var difficultyInfos: [Int: DifficultyInfo] {
        switch self {
        case .ja:
            return jaDifficultyInfos
        case .en:
            return enDifficultyInfos
        default:
            return [:]
        }
    }

    var prefix: String {
        return self == .ja ? "ja" : key
    }

    var defaultCode: String {
        switch self {
        case .ja:
            return "ja-JP"
        case .en:
            #if !targetEnvironment(macCatalyst)
                if AVSpeechSynthesisVoice.currentLanguageCode().contains("en-") {
                    return AVSpeechSynthesisVoice.currentLanguageCode()
                }
            #endif
            return "en-US"
        case .zh:
            if i18n.isHK {
                return "zh-HK"
            } else if i18n.isCN {
                return "zh-CN"
            } else {
                return "zh-TW"
            }
        case .fr:
            return "fr-FR"
        case .es:
            return "es-ES"
        case .de:
            return "de-DE"
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
    let lang = LangForEncode(lang: gameLang)
    saveToUserDefault(object: lang, key: gameLangKey)
}

func loadGameLang() {
    if let loadedGameLang = loadFromUserDefault(type: LangForEncode.self, key: gameLangKey) {
        gameLang = loadedGameLang.lang
        if gameLang != .ja {
            GameContext.shared.bottomTab = .infiniteChallenge
        }
    }
}

func changeGameLangTo(lang: Lang, fromSettingPage: Bool) {
    gameLang = lang
    saveGameLang()
    loadGameSetting()
    loadGameMiscData(isLoadKana: false)
    DispatchQueue.main.async {
        if gameLang == .en {
            GameContext.shared.bottomTab = .infiniteChallenge
            rootViewController.showInfiniteChallengePage(idx: fromSettingPage ? 0 : 1)
            if fromSettingPage {
                rootViewController.infiniteChallengeSwipablePage.settingPage?.render()
            } else {
                rootViewController.infiniteChallengeSwipablePage.medalPage?.medalPageView?.render()
            }
        } else {
            GameContext.shared.bottomTab = .topics
            rootViewController.showTopicPage(idx: fromSettingPage ? 0 : 1)
            if fromSettingPage {
                rootViewController.topicSwipablePage.settingPage?.render()
            } else {
                rootViewController.topicSwipablePage.medalPage?.medalPageView?.render()
            }
        }
        rootViewController.reloadTableData()
        rootViewController.rerenderTopView(updateByRecords: true)
    }
}
