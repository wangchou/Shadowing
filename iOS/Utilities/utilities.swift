//
//  utilities.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/04/16.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
// swiftlint:disable file_length

import AVFoundation
import Foundation
import Promises

#if os(iOS)
    import UIKit

    // MARK: - Audio Session

    func configureAudioSession() {
        do {
            let session: AVAudioSession = AVAudioSession.sharedInstance()
            try session.setCategory(
                AVAudioSession.Category.playAndRecord,
                mode: AVAudioSession.Mode.voiceChat,
                // if set both allowBluetooth and allowBluetoothA2DP here will
                // cause installTap callback not be calling. Not sure why
                options: [
                    .mixWithOthers, .allowBluetoothA2DP, .allowAirPlay, .defaultToSpeaker, .allowBluetooth,
                ]
            )

            // turn the measure mode will crash bluetooh, duckOthers and mixWithOthers
            //try session.setMode(AVAudioSessionModeMeasurement)

            // per ioBufferDuration delay, for live monitoring
            // default  23ms | 1024 frames | <1% CPU (iphone SE)
            // 0.001   0.7ms |   32 frames |  8% CPU
            // 0.008   5.6ms |  256 frames |  1% CPU
            try session.setPreferredIOBufferDuration(0.008)
            // print(session.ioBufferDuration)

            session.requestRecordPermission { success in
                if success { print("Record Permission Granted") } else {
                    print("Record Permission fail")
                    showGoToPermissionSettingAlert()
                }
            }
        } catch {
            print("configuare audio session with \(error)")
        }
    }

    // MARK: - Misc

    func getNow() -> Double {
        return NSDate().timeIntervalSince1970
    }

    extension Sequence {
        /// Returns an array with the contents of this sequence, shuffled.
        func shuffled() -> [Element] {
            var result = Array(self)
            result.shuffle()
            return result
        }
    }

    // MARK: - Misc For Dev Only

    func dumpAvaliableVoices() {
        print("current locale:", AVSpeechSynthesisVoice.currentLanguageCode())
        for voice in AVSpeechSynthesisVoice.speechVoices() {
            // if ((availableVoice.language == AVSpeechSynthesisVoice.currentLanguageCode()) &&
            //    (availableVoice.quality == AVSpeechSynthesisVoiceQuality.enhanced)) {
            if voice.language == "ja-JP" || voice.language == "zh-TW" || voice.language == "en-US" {
                print("\(voice.name) on \(voice.language) with Quality: \(voice.quality.rawValue) \(voice.identifier)")
            }
            // }
        }
    }

    func getAvailableVoice(language: String) -> [AVSpeechSynthesisVoice] {
        return AVSpeechSynthesisVoice.speechVoices()
            .filter { voice in
                if voice.language == language {
                    return true
                }
                return false
            }
    }

    func getAvailableVoice(prefix: String) -> [AVSpeechSynthesisVoice] {
        return AVSpeechSynthesisVoice.speechVoices()
            .filter { voice in
                if voice.language.hasPrefix(prefix) {
                    return true
                }
                return false
            }
    }

    // measure performance
    var startTime: Double = 0
    func setStartTime(_ tag: String = "") {
        startTime = NSDate().timeIntervalSince1970
        print(tag)
    }

    func printDuration(_ tag: String = "") {
        print(tag, (NSDate().timeIntervalSince1970 - startTime) * 1000, "ms")
    }

    // Promise Utilities
    func fulfilledVoidPromise() -> Promise<Void> {
        let promise = Promise<Void>.pending()
        promise.fulfill(())
        return promise
    }

    func rejectedVoidPromise() -> Promise<Void> {
        let promise = Promise<Void>.pending()
        promise.reject(GameError.forceStop)
        return promise
    }

    func pausePromise(_ seconds: Double) -> Promise<Void> {
        let p = Promise<Void>.pending()
        Timer.scheduledTimer(withTimeInterval: seconds, repeats: false) { _ in
            p.fulfill(())
        }
        return p
    }

    // Local Persist
    func saveToUserDefault<T: Codable>(object: T, key: String) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(object) {
            UserDefaults.standard.set(encoded, forKey: key)
        } else {
            print("save \(key) Failed")
        }
    }

    func loadFromUserDefault<T: Codable>(type _: T.Type, key: String) -> T? {
        let decoder = JSONDecoder()
        if let data = UserDefaults.standard.data(forKey: key),
            let obj = try? decoder.decode(T.self, from: data) {
            return obj as T
        }
        print("load \(key) Failed")
        return nil
    }

#endif

// MARK: - NLP

// separate long text by punctuations
func getSentences(_ text: String) -> [String] {
    let tagger = NSLinguisticTagger(
        tagSchemes: NSLinguisticTagger.availableTagSchemes(forLanguage: "ja"),
        options: 0
    )

    var sentences: [String] = []
    var curSentences = ""

    tagger.string = text
    let range = NSRange(location: 0, length: text.count)

    tagger.enumerateTags(in: range, scheme: .tokenType, options: []) { tag, tokenRange, _, _ in
        let token = (text as NSString).substring(with: tokenRange)
        if tag?.rawValue == "Punctuation" {
            // curSentences += token
            sentences.append(curSentences)
            curSentences = ""
        } else {
            curSentences += token
        }
    }
    sentences.append(curSentences)
    return sentences
}

// MARK: - Edit Distance

// EditDistance from https://en.wikibooks.org/wiki/Algorithm_Implementation/Strings/Levenshtein_distance#Swift
private func min3(_ a: Int, _ b: Int, _ c: Int) -> Int {
    return min(min(a, c), min(b, c))
}

private class Array2D {
    var cols: Int, rows: Int
    var matrix: [Int]

    init(cols: Int, rows: Int) {
        self.cols = cols
        self.rows = rows
        matrix = Array(repeating: 0, count: cols * rows)
    }

    subscript(col: Int, row: Int) -> Int {
        get {
            return matrix[cols * row + col]
        }
        set {
            matrix[cols * row + col] = newValue
        }
    }

    func colCount() -> Int {
        return cols
    }

    func rowCount() -> Int {
        return rows
    }
}

func distanceBetween(_ aStr: String, _ bStr: String) -> Int {
    let a = Array(aStr.utf16)
    let b = Array(bStr.utf16)

    if a.isEmpty || b.isEmpty {
        return a.count + b.count
    }

    let dist = Array2D(cols: a.count + 1, rows: b.count + 1)

    for i in 1 ... a.count {
        dist[i, 0] = i
    }

    for j in 1 ... b.count {
        dist[0, j] = j
    }

    for i in 1 ... a.count {
        for j in 1 ... b.count {
            if a[i - 1] == b[j - 1] {
                dist[i, j] = dist[i - 1, j - 1] // noop
            } else {
                dist[i, j] = min3(
                    dist[i - 1, j] + 1, // deletion
                    dist[i, j - 1] + 1, // insertion
                    dist[i - 1, j - 1] + 1 // substitution
                )
            }
        }
    }

    return dist[a.count, b.count]
}

// MARK: - Array Shuffle for calculate edit distance

// https://stackoverflow.com/questions/24026510/how-do-i-shuffle-an-array-in-swift?noredirect=1&lq=1
extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }

        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            // Change `Int` in the next line to `IndexDistance` in < Swift 4.1
            let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

func tokenInfosToString(tokenInfos: [[String]]) -> String {
    let jsonEncoder = JSONEncoder()
    do {
        let jsonData = try jsonEncoder.encode(tokenInfos)
        return String(data: jsonData, encoding: .utf8) ?? ""
    } catch {
        print(error)
        return ""
    }
}

func stringToTokenInfos(jsonString: String) -> [[String]]? {
    do {
        // Decode data to object
        let jsonDecoder = JSONDecoder()
        guard let jsonData = jsonString.data(using: .utf8) else { return nil }
        return try jsonDecoder.decode([[String]].self, from: jsonData)
    } catch {
        print(error)
        return nil
    }
}

// daily Records
func getDateKey(date: Date) -> String {
    return Calendar.current.dateComponents([.year, .month, .day], from: date).description
}

#if os(iOS)

    func getRecordsByDate() -> [String: [GameRecord]] {
        var recordsByDate: [String: [GameRecord]] = [:]
        GameContext.shared.gameHistory.forEach {
            let key = $0.dateKey
            if recordsByDate[key] != nil {
                recordsByDate[key]?.append($0)
            } else {
                recordsByDate[key] = [$0]
            }
        }
        return recordsByDate
    }

    func getAllSentencesCount() -> Int {
        guard !GameContext.shared.gameHistory.isEmpty || isSimulator else { return 0 }
        var sentenceCount = 0
        GameContext.shared.gameHistory.forEach { r in
            sentenceCount += r.correctCount
        }
        return sentenceCount
    }

    // [Today's correct sentence count, Yesterday's, ...]
    func getSentenceCountsByDays() -> [Int] {
        let calendar = Calendar.current
        let recordsByDate = getRecordsByDate()

        guard !GameContext.shared.gameHistory.isEmpty || isSimulator else { return [0] }
        var firstRecordDate = Date()
        GameContext.shared.gameHistory.forEach { r in
            let date = r.startedTime
            if date < firstRecordDate {
                firstRecordDate = date
            }
        }

        var minusOneDay = DateComponents()
        minusOneDay.day = -1
        let dateBound = calendar.date(byAdding: minusOneDay, to: firstRecordDate) ?? firstRecordDate
        var date = Date()
        var sentenceCounts: [Int] = []
        while date > dateBound {
            let key = getDateKey(date: date)
            if let records = recordsByDate[key],
                !records.isEmpty {
                var continueSentenceCount = 0
                for r in records {
                    continueSentenceCount += r.correctCount
                }
                sentenceCounts.append(continueSentenceCount)
            } else {
                sentenceCounts.append(0)
            }
            date = calendar.date(byAdding: minusOneDay, to: date) ?? date
        }

        if isSimulator {
            for _ in 1 ... 30 {
                sentenceCounts.append(0)
            }
            for i in 0 ..< sentenceCounts.count {
                sentenceCounts[i] += Int.random(in: 0 ..< 60)
            }
        }
        // print(sentenceCounts)
        return sentenceCounts
    }

    struct Summary {
        var date: Date = Date()
        var medalCount: Int = 0
        var sentenceCount: Int = 0
        var duration: Int = 0
        var perfectCount: Int = 0
        var greatCount: Int = 0
        var goodCount: Int = 0
        var missedCount: Int = 0
    }

    // [Today's correct sentence count, Yesterday's, ...]
    func getSummaryByDays() -> [Summary] {
        let calendar = Calendar.current
        let recordsByDate = getRecordsByDate()

        guard !GameContext.shared.gameHistory.isEmpty || isSimulator else { return [] }
        var firstRecordDate = Date()
        GameContext.shared.gameHistory.forEach { r in
            let date = r.startedTime
            if date < firstRecordDate {
                firstRecordDate = date
            }
        }

        var minusOneDay = DateComponents()
        minusOneDay.day = -1
        let dateBound = calendar.date(byAdding: minusOneDay, to: firstRecordDate) ?? firstRecordDate
        var date = Date()
        var summarys: [Summary] = []
        while date > dateBound {
            let key = getDateKey(date: date)
            var summary = Summary()
            summary.date = date
            if let records = recordsByDate[key],
                !records.isEmpty {
                for r in records {
                    summary.medalCount += r.medalReward ?? 0
                    summary.sentenceCount += r.correctCount
                    summary.duration += r.playDuration
                    summary.perfectCount += r.perfectCount
                    summary.greatCount += r.greatCount
                    summary.goodCount += r.goodCount
                    summary.missedCount += r.missedCount
                }
            }
            summarys.append(summary)

            date = calendar.date(byAdding: minusOneDay, to: date) ?? date
        }

        // print(sentenceCounts)
        return summarys
    }

    func getTodaySeconds() -> Int {
        guard !GameContext.shared.gameHistory.isEmpty else { return 0 }

        let todayKey = getDateKey(date: Date())
        var secs: Int = 0
        for r in GameContext.shared.gameHistory {
            if todayKey == getDateKey(date: r.startedTime) {
                secs += r.playDuration
            }
        }
        return secs
    }

    func getTodayMedalCount() -> Int {
        guard !GameContext.shared.gameHistory.isEmpty else { return 0 }

        let todayKey = getDateKey(date: Date())
        var medalCount: Int = 0
        for r in GameContext.shared.gameHistory {
            if todayKey == getDateKey(date: r.startedTime) {
                medalCount += r.medalReward ?? 0
            }
        }
        return medalCount
    }

    func getTodaySentenceCount() -> Int {
        guard !GameContext.shared.gameHistory.isEmpty else { return 0 }

        let todayKey = getDateKey(date: Date())
        var sentenceCount: Int = 0
        for r in GameContext.shared.gameHistory {
            if todayKey == getDateKey(date: r.startedTime) {
                sentenceCount += r.correctCount
            }
        }
        return sentenceCount
    }

    func getAllLanguageTodaySentenceCount() -> (said: Int, correct: Int) {
        let todayKey = getDateKey(date: Date())
        var saidSentenceCount: Int = 0
        var correctSentenceCount: Int = 0
        for r in getAllGameHistory() {
            if todayKey == getDateKey(date: r.startedTime) {
                saidSentenceCount += r.sentencesCount
                correctSentenceCount += r.correctCount
            }
        }
        return (saidSentenceCount, correctSentenceCount)
    }

    func isFreeVersion() -> Bool {
        return Date() > gameExpirationDate
    }

    func isUnderDailySentenceLimit() -> Bool {
        guard isFreeVersion() else { return true }
        let (said, _) = getAllLanguageTodaySentenceCount()
        if said < dailyFreeLimit { return true }

        IAPHelper.shared.showPurchaseView()
        return false
    }
#endif

// swiftlint:enable file_length
