//
//  GameSetting.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 9/9/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import AVFoundation
import Foundation

private let context = GameContext.shared

struct GameSetting: Codable {
    // MARK: - GameSetting Data fields
    var gameSpeed: Float = AVSpeechUtteranceDefaultSpeechRate * 0.85
    var practiceSpeed: Float = AVSpeechUtteranceDefaultSpeechRate * 0.7
    var isShowTranslationInPractice: Bool = false

    // learning mode started
    var learningMode: LearningMode = .speakingOnly
    var isShowTranslation: Bool = false
    var isSpeakTranslation: Bool = false
    var isUsingGuideVoice: Bool = true
    var translationLang: Lang = i18n.isZh ? .zh : (gameLang == .jp ? .en : .jp)
    // learning mode ended

    var isUsingNarrator: Bool = true
    var isMointoring: Bool = true
    var dailySentenceGoal: Int = 50
    var icTopViewMode: ICTopViewMode = .dailyGoal
    var isRepeatOne: Bool = false
    var monitoringVolume: Int = 0

    // voice id started
    var teacher: String = getDefaultVoiceId(language: gameLang.defaultCode, isPreferMaleSiri: gameLang == .jp)
    var assistant: String = getDefaultVoiceId(language: gameLang.defaultCode, isPreferMaleSiri: gameLang != .jp)
    var translatorJp: String = getDefaultVoiceId(language: Lang.jp.defaultCode)
    var translatorEn: String = getDefaultVoiceId(language: Lang.en.defaultCode)
    var translatorZh: String = getDefaultVoiceId(language: Lang.zh.defaultCode)

    // MARK: - Computed Fields
    var translator: String {
        get {
            if translationLang == .zh {
                return translatorZh
            } else if translationLang == .en {
                return translatorEn
            } else {
                return translatorJp
            }
        }
        set {
            if translationLang == .zh {
                translatorZh = newValue
            } else if translationLang == .en {
                translatorEn = newValue
            } else {
                translatorJp = newValue
            }
        }
    }
    // voice id ended

    init() {}

    // I know this is awful
    // But I found there is no better way to handle "Adding new fields" to a codable setting after googling for 8 hours
    // see discussions:
    // https://forums.swift.org/t/revisit-synthesized-init-from-decoder-for-structs-with-default-property-values/12296/4
    // https://www.hackingwithswift.com/forums/swift/codable-and-missing-keys/344
    // https://stackoverflow.com/questions/44575293/with-jsondecoder-in-swift-4-can-missing-keys-use-a-default-value-instead-of-hav
    // I guess this issue will never be solved until we can iterate over keypath (swift 6? like Tensorflow ABI did )
    // --- KeyPathIterable thread ---
    // https://forums.swift.org/t/storedpropertyiterable/19218
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        gameSpeed = try container.decodeIfPresent(Float.self, forKey: .gameSpeed) ?? gameSpeed
        practiceSpeed = try container.decodeIfPresent(Float.self, forKey: .practiceSpeed) ?? practiceSpeed
        isShowTranslationInPractice = try container.decodeIfPresent(Bool.self, forKey: .isShowTranslationInPractice) ?? isShowTranslationInPractice

        learningMode = try container.decodeIfPresent(LearningMode.self, forKey: .learningMode) ?? learningMode
        isShowTranslation = try container.decodeIfPresent(Bool.self, forKey: .isShowTranslation) ?? isShowTranslation
        isSpeakTranslation = try container.decodeIfPresent(Bool.self, forKey: .isSpeakTranslation) ?? isSpeakTranslation
        isUsingGuideVoice = try container.decodeIfPresent(Bool.self, forKey: .isUsingGuideVoice) ?? isUsingGuideVoice
        translationLang = try container.decodeIfPresent(Lang.self, forKey: .translationLang) ?? translationLang

        isUsingNarrator = try container.decodeIfPresent(Bool.self, forKey: .isUsingNarrator) ?? isUsingNarrator
        isMointoring = try container.decodeIfPresent(Bool.self, forKey: .isMointoring) ?? isMointoring
        dailySentenceGoal = try container.decodeIfPresent(Int.self, forKey: .dailySentenceGoal) ?? dailySentenceGoal
        icTopViewMode = try container.decodeIfPresent(ICTopViewMode.self, forKey: .icTopViewMode) ?? icTopViewMode
        isRepeatOne = try container.decodeIfPresent(Bool.self, forKey: .isRepeatOne) ?? isRepeatOne
        monitoringVolume = try container.decodeIfPresent(Int.self, forKey: .monitoringVolume) ?? monitoringVolume

        teacher = try container.decodeIfPresent(String.self, forKey: .teacher) ?? teacher
        assistant = try container.decodeIfPresent(String.self, forKey: .assistant) ?? assistant
        translatorJp = try container.decodeIfPresent(String.self, forKey: .translatorJp) ?? translatorJp
        translatorEn = try container.decodeIfPresent(String.self, forKey: .translatorEn) ?? assistant
        translatorZh = try container.decodeIfPresent(String.self, forKey: .translatorZh) ?? translatorZh
    }
}

enum ICTopViewMode: Int, Codable {
    case dailyGoal
    case timeline
    case longTermGoal
}

enum LearningMode: Int, Codable {
    case meaningAndSpeaking = 0
    case speakingOnly = 1
    case echoMethod = 2
    case interpretation = 3
}

// MARK: - save and load

private let gameSettingKey = "GameSettingKey"
func saveGameSetting() {
    saveToUserDefault(object: context.gameSetting, key: gameSettingKey + gameLang.key)
}

func loadGameSetting() {
    if let gameSetting = loadFromUserDefault(type: GameSetting.self, key: gameSettingKey + gameLang.key) {
        context.gameSetting = gameSetting
    } else {
        print("[\(gameLang)] create new gameSetting")
        context.gameSetting = GameSetting()
        let langCode = gameLang.defaultCode

        if gameLang == .jp {
            context.gameSetting.teacher = getDefaultVoiceId(language: langCode)
            context.gameSetting.assistant = getDefaultVoiceId(language: langCode, isPreferMaleSiri: false)
        } else {
            context.gameSetting.teacher = getDefaultVoiceId(language: langCode, isPreferMaleSiri: false)
            context.gameSetting.assistant = getDefaultVoiceId(language: langCode)
        }

        context.gameSetting.translatorJp = getDefaultVoiceId(language: Lang.jp.defaultCode)
        context.gameSetting.translatorEn = getDefaultVoiceId(language: Lang.en.defaultCode)
        context.gameSetting.translatorZh = getDefaultVoiceId(language: Lang.zh.defaultCode)

        print(context.gameSetting.teacher, context.gameSetting.assistant)
    }
}

func getDefaultVoice(language: String,
                     isPreferMaleSiri: Bool = true,
                     isPreferEnhanced: Bool = true) -> AVSpeechSynthesisVoice? {
    let voices = getAvailableVoice(language: language).sorted { v1, v2 in
        if v2.identifier.range(of: isPreferMaleSiri ? "siri_male" : "siri_female") != nil { return true }
        if v1.identifier.range(of: isPreferMaleSiri ? "siri_male" : "siri_female") != nil { return false }
        if v2.identifier.range(of: "siri") != nil { return true }
        if v1.identifier.range(of: "siri") != nil { return false }
        if v2.quality == .enhanced { return isPreferEnhanced ? true : false }
        if v1.quality == .enhanced { return isPreferEnhanced ? false : true }
        return v1.identifier < v2.identifier
    }

    guard let voice = voices.last else {
        if let voice = AVSpeechSynthesisVoice(language: language) {
            return voice
        } else {
            return nil
        }
    }
    return voice
}

func getDefaultVoiceId(language: String,
                       isPreferMaleSiri: Bool = true,
                       isPreferEnhanced: Bool = true) -> String {

    guard let voice = getDefaultVoice(language: language, isPreferMaleSiri: isPreferMaleSiri, isPreferEnhanced: isPreferEnhanced) else {
        showMessage(i18n.defaultVoiceIsNotAvailable, isNeedConfirm: true)
        print("getDefaultVoiceId(\(language), \(isPreferMaleSiri), \(isPreferEnhanced) Failed. return unknown")
        return "unknown"
    }
    return voice.identifier
}
