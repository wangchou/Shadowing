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

    var gameSpeed: Float = AVSpeechUtteranceDefaultSpeechRate * 0.70
    var practiceSpeed: Float = AVSpeechUtteranceDefaultSpeechRate * 0.60
    var isShowTranslationInPractice: Bool = false

    var learningMode: LearningMode = .speakingOnly

    var isShowTranslation: Bool {
        get { learningMode != .interpretation && isShowTranslationRaw }
        set { isShowTranslationRaw = newValue }
    }
    private var isShowTranslationRaw: Bool = false
    var isShowOriginal: Bool { !isShowTranslationRaw }

    var isSpeakTranslation: Bool {
        get { learningMode == .interpretation || isSpeakTranslationRaw }
        set { isSpeakTranslationRaw = newValue }
    }
    private var isSpeakTranslationRaw: Bool = false
    var isSpeakOriginal: Bool = true

    var isEchoMethod: Bool {
        get { learningMode != .interpretation && isEchoMethodRaw }
        set { isEchoMethodRaw = newValue }
    }
    private var isEchoMethodRaw: Bool = false

    var translationLang: Lang = i18n.isZh ? .zh : (gameLang == .ja ? .en : .ja)

    var isSpeakInitialDescription: Bool = true
    var isMointoring: Bool = true
    var dailySentenceGoal: Int = 50
    var icTopViewMode: ICTopViewMode = .dailyGoal
    var isRepeatOne: Bool = false
    var monitoringVolume: Int = 0

    // voice id started
    var teacher: String = getDefaultVoiceId(language: gameLang.defaultCode, isPreferMale: gameLang == .ja)
    var assistant: String = getDefaultVoiceId(language: gameLang.defaultCode, isPreferMale: gameLang != .ja)
    var translatorJp: String = getDefaultVoiceId(language: Lang.ja.defaultCode)
    var translatorEn: String = getDefaultVoiceId(language: Lang.en.defaultCode)
    var translatorZh: String = getDefaultVoiceId(language: Lang.zh.defaultCode, isPreferEnhanced: false)

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

    var narrator: String {
        var speaker: String
        if i18n.isJa {
            speaker = gameLang == .ja ? context.gameSetting.assistant : context.gameSetting.translatorJp
        } else if i18n.isZh {
            speaker = context.gameSetting.translatorZh
        } else {
            speaker = gameLang == .en ? context.gameSetting.assistant : context.gameSetting.translatorEn
        }
        return speaker
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

        isEchoMethodRaw = try container.decodeIfPresent(Bool.self, forKey: .isEchoMethodRaw) ?? isEchoMethodRaw

        isShowTranslationRaw = try container.decodeIfPresent(Bool.self, forKey: .isShowTranslationRaw) ?? isShowTranslationRaw
        isSpeakTranslationRaw = try container.decodeIfPresent(Bool.self, forKey: .isSpeakTranslationRaw) ?? isSpeakTranslationRaw

        isSpeakOriginal = try container.decodeIfPresent(Bool.self, forKey: .isSpeakOriginal) ?? isSpeakOriginal

        translationLang = try container.decodeIfPresent(Lang.self, forKey: .translationLang) ?? translationLang

        isSpeakInitialDescription = try container.decodeIfPresent(Bool.self, forKey: .isSpeakInitialDescription) ?? isSpeakInitialDescription
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
    case interpretation = 2
}

// MARK: - save and load

private let gameSettingKey = "GameSettingKey 1.4.0"
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

        if gameLang == .ja {
            context.gameSetting.teacher = getDefaultVoiceId(language: langCode)
            context.gameSetting.assistant = getDefaultVoiceId(language: langCode, isPreferMale: false)
        } else {
            context.gameSetting.teacher = getDefaultVoiceId(language: langCode, isPreferMale: false)
            context.gameSetting.assistant = getDefaultVoiceId(language: langCode)
        }

        context.gameSetting.translatorJp = getDefaultVoiceId(language: Lang.ja.defaultCode)
        context.gameSetting.translatorEn = getDefaultVoiceId(language: Lang.en.defaultCode)
        context.gameSetting.translatorZh = getDefaultVoiceId(language: Lang.zh.defaultCode, isPreferEnhanced: false)

        print(context.gameSetting.teacher, context.gameSetting.assistant)
    }
}

private func getVoiceSortScore(v: AVSpeechSynthesisVoice,
                               isPreferMale: Bool,
                               isPreferEnhanced: Bool
                               ) -> Int {

    // priority for non en: gender(3) > siri(2) > enhanced(1)
    //                  en: enhanced(100) > gender(3) > siri(2) iOS 14 en tts bug...
    var score = 0
    score += v.identifier.contains("siri") ? 2 : 0
    if #available(iOS 13.0, *) {
        score += v.gender == .male && isPreferMale ? 3 : 0
        score += v.gender == .female && !isPreferMale ? 3 : 0
    } else {
        score += v.identifier.contains("male") && isPreferMale ? 3 : 0
        score += v.identifier.contains("female") && !isPreferMale ? 3 : 0
    }
    if v.language.contains("en") { // avoid iOS 14 en compact tts speaking error
        score += v.quality == .enhanced && isPreferEnhanced ? 100 : 0
        score += v.quality == .default && !isPreferEnhanced ? 100 : 0
    } else {
        score += v.quality == .enhanced && isPreferEnhanced ? 1 : 0
        score += v.quality == .default && !isPreferEnhanced ? 1 : 0
    }
    return score
}

func getDefaultVoice(language: String,
                     isPreferMale: Bool = true,
                     isPreferEnhanced: Bool = true) -> AVSpeechSynthesisVoice? {
    let voices = getAvailableVoice(language: language).sorted { v1, v2 in
        let score1 =  getVoiceSortScore(v: v1, isPreferMale: isPreferMale, isPreferEnhanced: isPreferEnhanced)
        let score2 =  getVoiceSortScore(v: v2, isPreferMale: isPreferMale, isPreferEnhanced: isPreferEnhanced)
        return score1 > score2
    }
    //print(language, isPreferMaleSiri, isPreferEnhanced)
//    voices.forEach {v in
//        print(getVoiceSortScore(v: v, isPreferMale: isPreferMale, isPreferEnhanced: isPreferEnhanced), v)
//    }

    guard let voice = voices.first else {
        if let voice = AVSpeechSynthesisVoice(language: language) {
            return voice
        } else {
            return nil
        }
    }

    return voice
}

func getDefaultVoiceId(language: String,
                       isPreferMale: Bool = true,
                       isPreferEnhanced: Bool = true) -> String {
    guard let voice = getDefaultVoice(language: language, isPreferMale: isPreferMale, isPreferEnhanced: isPreferEnhanced) else {
        showMessage(i18n.defaultVoiceIsNotAvailable, isNeedConfirm: true)
        print("getDefaultVoiceId(\(language), \(isPreferMale), \(isPreferEnhanced) Failed. return unknown")
        return "unknown"
    }
    return voice.identifier
}
