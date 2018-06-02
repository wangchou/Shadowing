//
//  Character.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/06/01.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation

private let context = GameContext.shared

private let defaults = UserDefaults.standard
private let gameCharacterKey = "game character"

enum Item: String, Codable {
    case weakHealer
    case weakShield
    case unknown
}

enum Ability: String, Codable {
    case timeLeap
    case speedController
    case lightShield
    case doubleAttack
    case perfectReplay
    case unknown
}

private let newGameCharacter = GameCharacter()

func saveGameCharacter() {
    let encoder = JSONEncoder()

    if let encoded = try? encoder.encode(context.gameCharacter) {
        UserDefaults.standard.set(encoded, forKey: gameCharacterKey)
    } else {
        print("saveGameCharacter Failed")
    }

}

func loadGameCharacter() {
    let decoder = JSONDecoder()
    if let gameCharacterData = UserDefaults.standard.data(forKey: gameCharacterKey),
       let gameCharacter = try? decoder.decode(GameCharacter.self, from: gameCharacterData) {
        context.gameCharacter = gameCharacter
    } else {
        print("loadGameCharacter Failed")
    }
}

struct GameCharacter: Codable {
    var name: String
    var maxHP: Int
    var remainingHP: Int
    var abilityPoint: Int
    var level: Int
    var exp: Int
    var gold: Int
    var items: [Item]
    var armed: [Item]
    var abilities: [Ability]
}

extension GameCharacter {
    init() {
        self.init(
            name: "未命名",
            maxHP: 26,
            remainingHP: 26,
            abilityPoint: 0,
            level: 1,
            exp: 0,
            gold: 100,
            items: [.weakShield, .weakHealer, .weakHealer, .weakHealer],
            armed: [.weakShield],
            abilities: []
        )
    }
}
