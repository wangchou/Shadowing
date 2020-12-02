//
//  GameExpirationDateInMS.swift
//  今話したい
//
//  Created by Wangchou Lu on 11/29/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//
import Foundation

// Global
var gameExpirationDate = Date(ms: 0)
var isEverReceiptProcessed: Bool = false

// MARK: - Save/Load

private let gameExpirationDateKey = "gameExpirationDateKey"

private struct ExpirationDateForEncode: Codable {
    var date: Date
    var isEverReceiptProcessed: Bool
}

func saveGameExpirationDate() {
    let date = ExpirationDateForEncode(date: gameExpirationDate,
                                       isEverReceiptProcessed: isEverReceiptProcessed)
    saveToUserDefault(object: date, key: gameExpirationDateKey)
}

func loadGameExpirationDate() {
    if let loaded = loadFromUserDefault(type: ExpirationDateForEncode.self, key: gameExpirationDateKey) {
        gameExpirationDate = loaded.date
        isEverReceiptProcessed = loaded.isEverReceiptProcessed
    } else {
        print("create new gameExpirationDate")
        gameExpirationDate = Date(ms: 0)
        isEverReceiptProcessed = false
    }
}

// MARK: - Update Expiration Date

private let oneHundredYearsInMS: Int64 = 100 * 12 * 31 * 86400 * 1000
private let oneMonthInMS: Int64 = 31 * 86400 * 1000
private let threeMonthsInMS: Int64 = 3 * 31 * 86400 * 1000

// previous paided version
private let paidToFreeDateMS: Int64 = 1_544_298_312_000

func updateExpirationDate(productId: String, purchaseDateInMS: Int64) {
    var addtionInMS: Int64 = 0
    switch productId {
    case IAPProduct.unlimitedForever.rawValue:
        addtionInMS = oneHundredYearsInMS // 100 years
    case IAPProduct.unlimitedOneMonth.rawValue:
        addtionInMS = oneMonthInMS // one month
    case IAPProduct.unlimitedThreeMonths.rawValue:
        addtionInMS = threeMonthsInMS // three months
    default:
        print("Unknown product: \(productId)")
        return
    }

    let newDate = Date(ms: max(gameExpirationDate.ms, purchaseDateInMS) + addtionInMS)
    print("new: \(newDate), old: \(gameExpirationDate)")

    gameExpirationDate = newDate

    saveGameExpirationDate()
}

func updateExpirationDate(originalPurchaseDateMS: Int64) {
    print(originalPurchaseDateMS, paidToFreeDateMS)
    if originalPurchaseDateMS < paidToFreeDateMS {
        gameExpirationDate = Date(ms: oneHundredYearsInMS)
        print("unlimited from original app version")
        saveGameExpirationDate()
    }
}
