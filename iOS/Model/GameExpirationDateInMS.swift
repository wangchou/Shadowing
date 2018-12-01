//
//  GameExpirationDateInMS.swift
//  今話したい
//
//  Created by Wangchou Lu on 11/29/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//
import Foundation
private let gameExpirationDateKey = "gameExpirationDateKey"

private struct ExpirationDateForEncode: Codable {
    var date: Date
    var isEverReceiptProcessed: Bool
}

var gameExpirationDate: Date = Date()
var isEverReceiptProcessed: Bool = false
func saveGameExpirationDate() {
    let date: ExpirationDateForEncode = ExpirationDateForEncode(date: gameExpirationDate,
                                                                isEverReceiptProcessed: isEverReceiptProcessed)
    saveToUserDefault(object: date, key: gameExpirationDateKey)
}

func loadGameExpirationDate() {
    if let loaded = loadFromUserDefault(type: ExpirationDateForEncode.self, key: gameExpirationDateKey) {
        gameExpirationDate = loaded.date
        isEverReceiptProcessed = loaded.isEverReceiptProcessed
    } else {
        print("create new gameExpirationDate")
        gameExpirationDate = Date()
        isEverReceiptProcessed = false
    }
}

// MARK: - Update Expiration Date
private let oneHundredYearsInMS: Int64 = 100 * 12 * 31 * 86400 * 1000
private let oneMonthInMS: Int64 = 31 * 86400 * 1000
private let threeMonthsInMS: Int64 = 3 * 31 * 86400 * 1000

// previous paided version
private let unlimitedVersions = ["1.0", "1.0.0", "1.0.1", "1.0.2", "1.0.3", "1.0.4", "1.1", "1.1.0"]

func updateExpirationDate(productId: String, purchaseDateInMS: Int64) {
    var newExpirationDateInMS: Int64 = purchaseDateInMS
    switch productId {
    case IAPProduct.unlimitedForever.rawValue:
        newExpirationDateInMS += oneHundredYearsInMS // 100 years
    case IAPProduct.unlimitedOneMonth.rawValue:
        newExpirationDateInMS += oneMonthInMS // one month
    case IAPProduct.unlimitedThreeMonths.rawValue:
        newExpirationDateInMS += threeMonthsInMS // three months
    default:
        print("Unknown product: \(productId)")
        return
    }
    let newExpirationDate = Date(ms: newExpirationDateInMS)

    if newExpirationDate > gameExpirationDate {
        print("old:", gameExpirationDate, ",\n new:", newExpirationDate)
        gameExpirationDate = newExpirationDate
        saveGameExpirationDate()
    } else {
        print("(x no update): ", gameExpirationDate)
    }
}

func updateExpirationDate(appVersion: String) {
    var newExpirationDate = Date()

    if unlimitedVersions.contains(appVersion) {
        newExpirationDate = Date(ms: newExpirationDate.ms + oneHundredYearsInMS)
    }

    if newExpirationDate > gameExpirationDate {
        print("old:", gameExpirationDate, ",\nnew:", newExpirationDate, "\n")
        gameExpirationDate = newExpirationDate
        saveGameExpirationDate()
    } else {
        print("(x no update): ", gameExpirationDate)
    }
}
