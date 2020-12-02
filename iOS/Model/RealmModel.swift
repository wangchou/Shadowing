//
//  RealmModel.swift
//  hanashitai
//
//  Created by Wangchou Lu on R 2/11/30.
//  Copyright © Reiwa 2 Lu, WangChou. All rights reserved.
//

import Foundation
import RealmSwift

class RMSentence: Object {
    @objc dynamic var id = 0
    @objc dynamic var ja = ""
    @objc dynamic var en = ""
    @objc dynamic var cmn = ""
    @objc dynamic var jaTTSFixes = ""

    override static func primaryKey() -> String? {
        return "id"
    }
}

class RMStringToId: Object {
    @objc dynamic var origin = ""
    @objc dynamic var id = 0

    override static func primaryKey() -> String? {
        return "origin"
    }
}

class RMJaInfo: Object {
    @objc dynamic var difficulty = 0
    @objc dynamic var ids = ""

    override static func primaryKey() -> String? {
        return "difficulty"
    }
}

class RMEnInfo: Object {
    @objc dynamic var difficulty = 0
    @objc dynamic var ids = ""

    override static func primaryKey() -> String? {
        return "difficulty"
    }
}

class RMTokenInfos: Object {
    @objc dynamic var ja = ""
    @objc dynamic var kanaCount = 0
    @objc dynamic var tokenInfos = ""

    override static func primaryKey() -> String? {
        return "ja"
    }
}
