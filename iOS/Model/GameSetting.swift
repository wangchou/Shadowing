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

// Newly add settings
private var globalIsRepeatOne: Bool = false
private var globalMonitoringVolume: Int = 0

struct GameSetting: Codable {
    var isAutoSpeed: Bool = true
    var preferredSpeed: Float = AVSpeechUtteranceDefaultSpeechRate * 0.9
    var practiceSpeed: Float = AVSpeechUtteranceDefaultSpeechRate * 0.7
    var isShowTranslationInPractice: Bool = false

    // learning mode started
    var learningMode: LearningMode = .speakingOnly
    var isShowTranslation: Bool = false
    var isSpeakTranslation: Bool = false
    var isUsingGuideVoice: Bool = true
    // learning mode ended

    var isUsingNarrator: Bool = true
    var isMointoring: Bool = true
    var teacher: String = "unknown"
    var assisant: String = "unknown"
    var dailySentenceGoal: Int = 50
    var icTopViewMode: ICTopViewMode = .dailyGoal
    var isRepeatOne: Bool {
        get {
            return globalIsRepeatOne
        }
        set {
            globalIsRepeatOne = newValue
        }
    }
    var monitoringVolume: Int {
        get {
            return globalMonitoringVolume
        }
        set {
            globalMonitoringVolume = newValue
        }
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

// MARK: - Save/Load for one Bool

private let isRepeatOneKey = "RepeatOneKey"

// https://stackoverflow.com/questions/44580719/how-do-i-make-an-enum-decodable-in-swift-4
private struct IsRepeatOneForEncode: Codable {
    var isRepeatOne: Bool
}

func saveIsRepeatOne() {
    let tmpObj = IsRepeatOneForEncode(isRepeatOne: globalIsRepeatOne)
    saveToUserDefault(object: tmpObj, key: isRepeatOneKey)
}

func loadIsRepeatOne() {
    if let loadedObj = loadFromUserDefault(type: IsRepeatOneForEncode.self, key: isRepeatOneKey) {
        globalIsRepeatOne = loadedObj.isRepeatOne
    }
}

// MARK: - Save/Load for monitoringVolume

private let monitoringVolumeKey = "monitoringVolumeKey"

private struct MonitoringVolumeForEncode: Codable {
    var monitoringVolume: Int
}

func saveMonitoringVolume() {
    let tmpObj = MonitoringVolumeForEncode(monitoringVolume: globalMonitoringVolume)
    saveToUserDefault(object: tmpObj, key: monitoringVolumeKey + gameLang.key)
}

func loadMonitoringVolume() {
    if let loadedObj = loadFromUserDefault(type: MonitoringVolumeForEncode.self, key: monitoringVolumeKey + gameLang.key) {
        globalMonitoringVolume = loadedObj.monitoringVolume
    }
}

// MARK: - save and load

private let gameSettingKey = "GameSettingKey"
private let unknownVoice = "unknownVoice"
func saveGameSetting() {
    saveToUserDefault(object: context.gameSetting, key: gameSettingKey + gameLang.key)
    saveIsRepeatOne()
    saveMonitoringVolume()
}

func loadGameSetting() {
    if let gameSetting = loadFromUserDefault(type: GameSetting.self, key: gameSettingKey + gameLang.key),
       gameSetting.teacher != unknownVoice,
       gameSetting.assisant != unknownVoice {
        context.gameSetting = gameSetting
    } else {
        print("[\(gameLang)] create new gameSetting")
        context.gameSetting = GameSetting()
        let langCode = gameLang == .jp ? "ja-JP" : "en-US"

        if gameLang == .jp {
            context.gameSetting.teacher = getDefaultVoiceId(language: langCode)
            context.gameSetting.assisant = getDefaultVoiceId(language: langCode, isPreferMaleSiri: false)
        } else {
            context.gameSetting.teacher = getDefaultVoiceId(language: langCode, isPreferMaleSiri: false)
            context.gameSetting.assisant = getDefaultVoiceId(language: langCode)
        }
        print(context.gameSetting.teacher, context.gameSetting.assisant)
    }
    loadIsRepeatOne()
    loadMonitoringVolume()
}

func getDefaultVoiceId(language: String, isPreferMaleSiri: Bool = true, isPreferEnhanced: Bool = true) -> String {
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
            return voice.identifier
        } else {
            showMessage(i18n.defaultVoiceIsNotAvailable, isNeedConfirm: true)
            return AVSpeechSynthesisVoice(language: nil)?.identifier ?? unknownVoice
        }
    }
    return voice.identifier
}
