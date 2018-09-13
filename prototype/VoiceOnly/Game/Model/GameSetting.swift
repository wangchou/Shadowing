//
//  GameSetting.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 9/9/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation
import AVFoundation

let gameSettingKey = "GameSettingKey"
private let context = GameContext.shared

func saveGameSetting() {
    let encoder = JSONEncoder()

    if let encoded = try? encoder.encode(context.gameSetting) {
        UserDefaults.standard.set(encoded, forKey: gameSettingKey)
    } else {
        print("saveGameCharacter Failed")
    }

}

func loadGameSetting() {
    let decoder = JSONDecoder()
    if let gameSettingData = UserDefaults.standard.data(forKey: gameSettingKey),
        let gameSetting = try? decoder.decode(GameSetting.self, from: gameSettingData) {
        context.gameSetting = gameSetting
    } else {
        print("loadGameSetting Failed")
    }
}

struct GameSetting: Codable {
    var isAutoSpeed: Bool = true
    var preferredSpeed: Float = AVSpeechUtteranceDefaultSpeechRate
    var isUsingTranslationInShadowingMode: Bool = true
}
