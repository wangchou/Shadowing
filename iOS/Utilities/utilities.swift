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

    func configureAudioSession(isAskingPermission: Bool = true) {
        let session = AVAudioSession.sharedInstance()

        do {
            try session.setCategory(
                AVAudioSession.Category.playAndRecord,
                mode: AVAudioSession.Mode.default,
                // if set both allowBluetooth and allowBluetoothA2DP here will
                // cause installTap callback not be calling. Not sure why
                options: [
                    .mixWithOthers, .allowBluetoothA2DP, .allowAirPlay, .defaultToSpeaker, .allowBluetooth,
                ]
            )

            // turn the measure mode will crash bluetooh, duckOthers and mixWithOthers
            // try session.setMode(AVAudioSessionModeMeasurement)

            // per ioBufferDuration delay, for live monitoring
            // default  23ms | 1024 frames | <1% CPU (iphone SE)
            // 0.001   0.7ms |   32 frames |  8% CPU
            // 0.008   5.6ms |  256 frames |  1% CPU

            // Important Warning
            // if bufferDuration is too low (0.004) => dyanmic installTap failure on default mic (iPhone 8 and later)
            // if bufferDuration is too high (0.04) => tts be muted through bluetooth

            try session.setPreferredIOBufferDuration(0.008)
        } catch {
            print("configuare audio session with \(error)")
        }

        guard isAskingPermission else { return }

        session.requestRecordPermission { success in
            if success {
                print("Record Permission Granted")
            } else {
                print("Record Permission fail")
                showGoToPermissionSettingAlert()
            }
        }
    }

    // MARK: - Misc

    func getNow() -> Double {
        return NSDate().timeIntervalSince1970
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
            .filter { $0.language == language}
    }

    func getAvailableVoice(prefix: String) -> [AVSpeechSynthesisVoice] {
        return AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language.hasPrefix(prefix) }
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

            print("\(key) saved")
//            if let jsonStr = String(data: encoded, encoding: .utf8) {
//                print(jsonStr)
//            }

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

func encode<T: Codable>(_ object: T) -> String? {
    if let jsonData = try? JSONEncoder().encode(object) {
        return String(data: jsonData, encoding: .utf8)
    }
    return nil
}

func decode<T: Codable>(type _: T.Type, jsonString: String) -> T? {
    if let jsonData = jsonString.data(using: .utf8) {
        let decoder = JSONDecoder()
        return try? decoder.decode(T.self, from: jsonData)
    }
    return nil
}

func tokenInfosToString(tokenInfos: [[String]]) -> String {
    return encode(tokenInfos) ?? ""
}

func stringToTokenInfos(jsonString: String) -> [[String]]? {
    return decode(type: [[String]].self, jsonString: jsonString)
}

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
        var date = Date()
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

    func isUnderDailySentenceLimit(isShowPurchaseViewed: Bool = true) -> Bool {
        guard isFreeVersion() else { return true }
        let (said, _) = getAllLanguageTodaySentenceCount()
        if said < dailyFreeLimit { return true }
        if isShowPurchaseViewed {
            IAPHelper.shared.showPurchaseView()
        }
        return false
    }
#endif

func arrayToPair(_ arr: [String]) -> [(String, String)] {
    var key = ""
    var output: [(String, String)] = []
    for (i, element) in arr.enumerated() {
        if i % 2 == 0 {
            key = element
        } else {
            output.append((key, element))
        }
    }
    return output
}

// rate can be approximate by reverse linear proprotional to spend time
// speed = distance / time
// speed is linear prorptional to 1 / (1 - rate)
// rate 0.2  => 4.4 s => 0.5x
// rate 0.5  => 2.2 s => 1.0x
// rate 0.7  => 1.1 s => 2.0x
//
// speed 1.0x == AVSpeechUtteranceDefaultSpeechRate (0.5) = 175bpm
func ttsRateToSpeed(rate: Float) -> Float {
    return 1.0 + (rate - 0.5) * 1.5
}

func speedToTTSRate(speed: Float) -> Float {
    return 0.5 + (speed - 1.0) * 2 / 3
}

func findCandidate(segs: [[String]], originalStr: String) -> String {
    // print("segs:", segs, ", originalStr:", originalStr)
    var newSegs = segs

    // if candidates are too many => use naive filter first
    if segs.count > 3 {
        newSegs = segs.map { strings in
            return strings.filter {
                originalStr.contains($0) || $0 == strings.first
            }
        }
    }

    // print("newSegs", newSegs)

    func calcScore(s1: String, s2: String) -> Int {
        let ns1 = gameLang == .ja ? s1 : normalizeEnglishText(s1)
        let ns2 = gameLang == .ja ? s2 : normalizeEnglishText(s2)
        let len = max(ns1.count, ns2.count)
        guard len > 0 else { return 0 }
        let score = (len - distanceBetween(ns1, ns2)) * 100 / len
        return score
    }

    var bestCandidate = ""
    var highestScore = 0

    var candidates = [""]
    let space = gameLang != .ja ? " " : ""
    newSegs.forEach { strs in
        candidates = strs.map { str in candidates.map { $0 + space + str } }
                         .flatMap { $0 }
    }
    // print("candidates:", candidates)
    candidates.forEach { str in
        let len = max(str.count, originalStr.count)
        let score = (len - distanceBetween(str, originalStr)) * 100 / len
        // print(score, str)

        if score > highestScore {
            highestScore = score
            bestCandidate = str
        }
    }
    // print("best candidate:", bestCandidate)
    return bestCandidate
}

// swiftlint:enable file_length
