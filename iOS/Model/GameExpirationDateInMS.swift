//
//  GameExpirationDateInMS.swift
//  今話したい
//
//  Created by Wangchou Lu on 11/29/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//
import Foundation
private let gameExpirationDateKey = "gameExpirationDateKey"

private struct DateForEncode: Codable {
    var date: Date
}

var gameExpirationDate: Date = Date()
func saveGameExpirationDate() {
    let date: DateForEncode = DateForEncode(date: gameExpirationDate)
    saveToUserDefault(object: date, key: gameExpirationDateKey)
}

func loadGameExpirationDate() {
    if let loadedDate = loadFromUserDefault(type: DateForEncode.self, key: gameExpirationDateKey) {
        gameExpirationDate = loadedDate.date
    } else {
        print("[\(gameLang)] create new gameExpirationDate")
        gameExpirationDate = Date()
    }
}

// MARK: - Update Expiration Date
private let oneHundredYearsInMS: Int64 = 100 * 12 * 31 * 86400 * 1000
private let oneMonthInMS: Int64 = 31 * 86400 * 1000
private let threeMonthsInMS: Int64 = 3 * 31 * 86400 * 1000

// previous paided version
private let unlimitedVersions = ["1.0", "1.0.0", "1.0.1", "1.0.2", "1.0.3", "1.0.4", "1.1", "1.1.0"]

func updateExpirationDateByProduct(productId: String, purchaseDateInMS: Int64) {
    var newExpirationDateInMS: Int64 = purchaseDateInMS
    switch productId {
    case IAPProduct.unlimitedForever.rawValue:
        newExpirationDateInMS += oneHundredYearsInMS // 100 years
    case IAPProduct.unlimitedOneMonth.rawValue:
        newExpirationDateInMS += oneMonthInMS // one month
    case IAPProduct.unlimitedThreeMonths.rawValue:
        newExpirationDateInMS += threeMonthsInMS // three months
    default:
        ()
    }
    let newExpirationDate = Date(milliseconds: newExpirationDateInMS)

    if newExpirationDate > gameExpirationDate {
        print("old:", gameExpirationDate, ",\n new:", newExpirationDate)
        gameExpirationDate = newExpirationDate
        saveGameExpirationDate()
    } else {
        print("(x no update): ", gameExpirationDate)
    }
}

func updateExpirationDateByOriginalAppVersion(appVersion: String) {
    var newExpirationDate = Date()

    if unlimitedVersions.contains(appVersion) {
        newExpirationDate = Date(milliseconds: newExpirationDate.millisecondsSince1970 + oneHundredYearsInMS)
    }

    if newExpirationDate > gameExpirationDate {
        print("old:", gameExpirationDate, ",\nnew:", newExpirationDate, "\n")
        gameExpirationDate = newExpirationDate
        saveGameExpirationDate()
    } else {
        print("(x no update): ", gameExpirationDate)
    }
}
