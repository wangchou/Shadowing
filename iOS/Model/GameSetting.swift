//
//  GameSetting.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 9/9/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation
import AVFoundation

private let gameSettingKey = "GameSettingKey"
private let context = GameContext.shared

func saveGameSetting() {
   saveToUserDefault(object: context.gameSetting, key: gameSettingKey + gameLang.key)
}

func loadGameSetting() {
    if let gameSetting = loadFromUserDefault(type: GameSetting.self, key: gameSettingKey + gameLang.key) {
        context.gameSetting = gameSetting
    } else {
        print("[\(gameLang)] create new gameSetting")
        context.gameSetting = GameSetting()
        let langCode = gameLang == .jp ? "ja-JP" : "en-US"

        context.gameSetting.teacher = getDefaultVoiceId(language: langCode)
        context.gameSetting.assisant = context.gameSetting.teacher
    }
}

func getDefaultVoiceId(language: String) -> String {
    var bestVoiceId = ""
    if language == "ja-JP" {
        let voices = getAvailableVoice(prefix: "ja").sorted { v1, v2 in
            if v2.identifier.range(of: "siri_male") != nil { return true}
            if v1.identifier.range(of: "siri_male") != nil { return false}
            if v2.identifier.range(of: "siri") != nil { return true}
            if v1.identifier.range(of: "siri") != nil { return false}
            if v2.quality == .enhanced { return true}
            if v2.quality == .enhanced { return false}
            return v1.identifier < v2.identifier
        }

        bestVoiceId = voices.last!.identifier
    } else {
        let voices = getAvailableVoice(language: language).sorted { v1, v2 in
            if v2.identifier.range(of: "siri_female") != nil { return true}
            if v1.identifier.range(of: "siri_female") != nil { return false}
            if v2.identifier.range(of: "siri") != nil { return true}
            if v1.identifier.range(of: "siri") != nil { return false}
            if v2.quality == .enhanced { return true}
            if v2.quality == .enhanced { return false}
            return v1.identifier < v2.identifier
        }
        guard !voices.isEmpty else { return AVSpeechSynthesisVoice(language: "en-US")!.identifier }
        bestVoiceId = voices.last!.identifier
    }
    return bestVoiceId
}

struct GameSetting: Codable {
    var isAutoSpeed: Bool = true
    var preferredSpeed: Float = AVSpeechUtteranceDefaultSpeechRate
    var practiceSpeed: Float = AVSpeechUtteranceDefaultSpeechRate * 0.75
    var isUsingTranslation: Bool = true
    var isUsingGuideVoice: Bool = true
    var isUsingNarrator: Bool = true
    var isMointoring: Bool = false
    var teacher: String = "unknown"
    var assisant: String = "unknown"
    var dailySentenceGoal: Int = 50
    var icTopViewMode: ICTopViewMode = .dailyGoal
}

enum ICTopViewMode: Int, Codable {
    case dailyGoal
    case timeline
    case longTermGoal
}
