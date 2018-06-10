//
//  Character.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/06/01.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

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
    var skillPoint: Int
    var level: Int
    var exp: Int
    var gold: Int
    var items: [Item]
    var armed: [Item]
    var abilities: [Ability]

    // max level 20, the experience needed from n to n+1 is (1.3^n) * 150
    // to level 2: 1.3 * 150 = 195 exp
    // to level 3: 1.69 * 150 = 253 exp
    private let experienceLevels: [Int] = [
        195,
        448,
        778,
        1206,
        1763,
        2487,
        3428,
        4652,
        6242,
        8310,
        10999,
        14493,
        19036,
        24942,
        32620,
        42602,
        55577,
        72446,
        94374
    ]

    mutating func levelUp() -> Bool {
        guard level < 20 else { return false }

        if experienceLevels[level] < exp {
            level += 1
            maxHP += getLevelUpHP()
            remainingHP = maxHP
            skillPoint += getLevelUpSp()
            return true
        }
        
        return false
    }

    func getLevelUpHP() -> Int {
        return Int(arc4random_uniform(20)) + 10
    }

    func getLevelUpSp() -> Int {
        return Int(arc4random_uniform(2)) + 1
    }
}

extension GameCharacter {
    init() {
        self.init(
            name: "未命名",
            maxHP: 26,
            remainingHP: 26,
            skillPoint: 2,
            level: 1,
            exp: 0,
            gold: 100,
            items: [.weakShield, .weakHealer, .weakHealer, .weakHealer],
            armed: [.weakShield],
            abilities: []
        )
    }
}
