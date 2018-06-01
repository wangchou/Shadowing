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

enum Item: String {
    case weakHealer
    case weakShield
    case unknown
}

enum Ability: String {
    case timeLeap
    case speedController
    case lightShield
    case doubleAttack
    case perfectReplay
    case unknown
}

private let newGameCharacter = GameCharacter()

func saveGameCharacter() {
    let gameCharacterData = NSKeyedArchiver.archivedData(withRootObject: context.gameCharacter)
    defaults.set(gameCharacterData, forKey: gameCharacterKey)
}

func loadGameCharacter() -> GameCharacter {
    guard let gameCharacterData = defaults.data(forKey: gameCharacterKey) else { return newGameCharacter}
    guard let gameCharacter = NSKeyedUnarchiver.unarchiveObject(with: gameCharacterData) as? GameCharacter else { return newGameCharacter}
    return gameCharacter
}

class GameCharacter: NSObject, NSCoding {
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

    override init() {
        self.name = "未命名"
        self.maxHP = 26
        self.remainingHP = self.maxHP
        self.abilityPoint = 0
        self.level = 0
        self.exp = 0
        self.gold = 100
        self.items = [.weakShield, .weakHealer, .weakHealer, .weakHealer]
        self.armed = [.weakShield]
        self.abilities = []
        super.init()
    }

    required init(coder decoder: NSCoder) {
        if let name = decoder.decodeObject(forKey: "name") as? String {
            self.name = name
        } else {
            self.name = "不知名"
            print("get name from localStorage failed")
        }
        self.maxHP = decoder.decodeInteger(forKey: "maxHP")
        self.remainingHP = decoder.decodeInteger(forKey: "remainingHP")
        self.abilityPoint = decoder.decodeInteger(forKey: "abilityPoint")
        self.level = decoder.decodeInteger(forKey: "level")
        self.exp = decoder.decodeInteger(forKey: "exp")
        self.gold = decoder.decodeInteger(forKey: "gold")

        if let items = decoder.decodeObject(forKey: "items") as? [String] {
            self.items = (items.map { Item(rawValue: $0) ?? Item.unknown }).filter { $0 != Item.unknown }
        } else {
            self.items = []
        }

        if let armed = decoder.decodeObject(forKey: "armed") as? [String] {
            self.armed = (armed.map { Item(rawValue: $0) ?? Item.unknown }).filter { $0 != Item.unknown }
        } else {
            self.armed = []
        }

        if let abilities = decoder.decodeObject(forKey: "abilities") as? [String] {
            self.abilities = (abilities.map { Ability(rawValue: $0) ?? Ability.unknown }).filter { $0 != Ability.unknown }
        } else {
            self.abilities = []
        }

        super.init()
    }

    func encode(with coder: NSCoder) {
        coder.encode(self.name, forKey: "name")
        coder.encodeCInt(Int32(self.maxHP), forKey: "maxHP")
        coder.encodeCInt(Int32(self.remainingHP), forKey: "remainingHP")
        coder.encodeCInt(Int32(self.abilityPoint), forKey: "abilityPoint")
        coder.encodeCInt(Int32(self.level), forKey: "level")
        coder.encodeCInt(Int32(self.exp), forKey: "exp")
        coder.encodeCInt(Int32(self.gold), forKey: "gold")
        coder.encode(self.items.map { $0.rawValue }, forKey: "items")
        coder.encode(self.armed.map { $0.rawValue }, forKey: "armed")
        coder.encode(self.abilities.map { $0.rawValue }, forKey: "abilities")
    }
}
