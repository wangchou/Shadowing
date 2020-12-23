//
//  Dummy.swift
//  voicePrototype
//
//  Created by Wangchou Lu on R 2/12/21.
//

import Foundation
import AVFoundation
import Promises
import UIKit

let isSimulator = false

enum Lang: Int, Codable {
    case ja, en, unset, zh, fr, es, de

    var key: String {
        switch self {
        case .ja:
            return ""
        case .en:
            return "en"
        case .zh:
            return "zh"
        case .fr:
            return "fr"
        case .es:
            return "es"
        case .de:
            return "de"
        case .unset:
            return "unset"
        }
    }

    var isSupportTopicMode: Bool {
        if self == .ja { return true }
        return false
    }

    var prefix: String {
        return self == .ja ? "ja" : key
    }

    var defaultCode: String {
        switch self {
        case .ja:
            return "ja-JP"
        case .en:
            #if !targetEnvironment(macCatalyst)
                if AVSpeechSynthesisVoice.currentLanguageCode().contains("en-") {
                    return AVSpeechSynthesisVoice.currentLanguageCode()
                }
            #endif
            return "en-US"
        case .zh:
            if i18n.isHK {
                return "zh-HK"
            } else if i18n.isCN {
                return "zh-CN"
            } else {
                return "zh-TW"
            }
        case .fr:
            return "fr-FR"
        case .es:
            return "es-ES"
        case .de:
            return "de-DE"
        case .unset:
            return "unset"
        }
    }
}

let i18n = I18n.shared

class I18n {
    static let shared = I18n()

    private init() {}

    var lang: Lang {
        if isZh { return .zh }
        if isJa { return .ja }
        return .en
    }

    var langCode: String? {
        return Locale.current.languageCode
    }

    var regionCode: String? {
        return Locale.current.regionCode
    }

    var isJa: Bool {
        return langCode == "ja"
    }

    var isZh: Bool {
        return langCode == "zh"
    }

    var isHK: Bool {
        return regionCode == "HK"
    }

    var isCN: Bool {
        return regionCode == "CN"
    }

    var pts: String {
        if isZh { return "分" }
        if isJa { return "点" }
        return "%"
    }

    var cannotReachServer: String {
        return isJa ? "サーバーに接続できません" : "連不到主機"
    }
}

func fulfilledVoidPromise() -> Promise<Void> {
    let promise = Promise<Void>.pending()
    promise.fulfill(())
    return promise
}

func calculateMicLevel(buffer: AVAudioPCMBuffer) {
    return
}

func showGoToPermissionSettingAlert() {
    print(#function)
    return
}

func getNow() -> Double {
    return NSDate().timeIntervalSince1970
}

func showNoVoicePrompt(language: String) {
    print(#function)
}

// rate can be approximate by reverse linear proprotional to spend time
// test data of tts
//
// rate 0.2  => 4.4 s => 0.5x
// rate 0.5  => 2.2 s => 1.0x
// rate 0.7  => 1.1 s => 2.0x
//
// speed 1.0x == AVSpeechUtteranceDefaultSpeechRate (0.5) = 175bpm
func ttsRateToSpeed(rate: Float) -> Float {
    return pow(2, 3.33 * (rate - 0.5))
}

func speedToTTSRate(speed: Float) -> Float {
    return 0.5 + log2(speed) * 0.3
}

func findCandidate(segs: [[String]], originalStr: String) -> String {
    return originalStr
}

func getDefaultVoiceId(language: String,
                       isPreferMale: Bool = true,
                       isPreferEnhanced: Bool = true) -> String {
    guard let voice = getDefaultVoice(language: language, isPreferMale: isPreferMale, isPreferEnhanced: isPreferEnhanced) else {
        print("getDefaultVoiceId(\(language), \(isPreferMale), \(isPreferEnhanced) Failed. return unknown")
        return "unknown"
    }
    return voice.identifier
}

private func getVoiceSortScore(v: AVSpeechSynthesisVoice,
                               isPreferMale: Bool,
                               isPreferEnhanced: Bool
                               ) -> Int {

    // priority for non en: gender(3) > siri(2) > enhanced(1)
    //                  en: enhanced(100) > gender(3) > siri(2) iOS 14 en tts bug...
    var score = 0
    score += v.identifier.contains("siri") ? 2 : 0
    if #available(iOS 13.0, *) {
        score += v.gender == .male && isPreferMale ? 3 : 0
        score += v.gender == .female && !isPreferMale ? 3 : 0
    } else {
        score += v.identifier.contains("male") && isPreferMale ? 3 : 0
        score += v.identifier.contains("female") && !isPreferMale ? 3 : 0
    }
    if v.language.contains("en") { // avoid iOS 14 en compact tts speaking error
        score += v.quality == .enhanced && isPreferEnhanced ? 100 : 0
        score += v.quality == .default && !isPreferEnhanced ? 100 : 0
    } else {
        score += v.quality == .enhanced && isPreferEnhanced ? 1 : 0
        score += v.quality == .default && !isPreferEnhanced ? 1 : 0
    }
    return score
}

func getDefaultVoice(language: String,
                     isPreferMale: Bool = true,
                     isPreferEnhanced: Bool = true) -> AVSpeechSynthesisVoice? {
    var voices = getAvailableVoice(language: language)
    if voices.isEmpty {
        let prefix = language.components(separatedBy: "-")[0]
        voices = getAvailableVoice(prefix: prefix)
    }

    voices = voices.sorted { v1, v2 in
        let score1 =  getVoiceSortScore(v: v1, isPreferMale: isPreferMale, isPreferEnhanced: isPreferEnhanced)
        let score2 =  getVoiceSortScore(v: v2, isPreferMale: isPreferMale, isPreferEnhanced: isPreferEnhanced)
        return score1 > score2
    }

    if !voices.isEmpty {
        return voices.first
    }

    return nil
}

func getAvailableVoice(language: String) -> [AVSpeechSynthesisVoice] {
    return AVSpeechSynthesisVoice.speechVoices()
        .filter { $0.language == language}
}

func getAvailableVoice(prefix: String) -> [AVSpeechSynthesisVoice] {
    return AVSpeechSynthesisVoice.speechVoices()
        .filter { $0.language.hasPrefix(prefix) }
}

var gameLang = Lang.ja

func rgb(_ red: Float, _ green: Float, _ blue: Float, _ alpha: Float = 1.0) -> UIColor {
    return UIColor(red: CGFloat(red / 255.0),
                   green: CGFloat(green / 255.0),
                   blue: CGFloat(blue / 255.0),
                   alpha: CGFloat(alpha))
}
let myRed = rgb(254, 67, 134)
let myOrange = rgb(255, 195, 0)
let myGreen = rgb(150, 207, 42)
let myBlue = rgb(20, 168, 237)

var kanaTokenInfosCacheDictionary: [String: [[String]]] = [:]

func loadTokenInfos(ja: String) {}

func showMessage(_ message: String, seconds: Float = 2, isNeedConfirm: Bool = false) {
}

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

enum EventType {
    case sayStarted
    case willSpeakRange
    case speakEnded
    case listenStarted
    case listenStopped
    case scoreCalculated
    case gameStateChanged
    case playTimeUpdate
    case levelMeterUpdate
    case gamePaused
    case gameResume

    // for medal correction page
    case practiceSentenceCalculated
}

struct Event {
    let type: EventType

    // only accept four types of data for type safety
    let string: String?
    let int: Int?
    //let gameState: GameState?
    let score: Score?
    let range: NSRange?
}

extension Notification.Name {
    static let eventHappened = Notification.Name("eventHappended")
}

func postEvent(
    _ type: EventType,
    string: String? = nil,
    int: Int? = nil,
    //gameState: GameState? = nil,
    score: Score? = nil,
    range: NSRange? = nil
) {
    NotificationCenter.default.post(
        name: .eventHappened,
        object: Event(type: type, string: string, int: int, score: score, range: range)
    )
}

// for Game UI watching events from lower layers
@objc protocol GameEventDelegate {
    @objc func onEventHappened(_ notification: Notification)
}

func startEventObserving(_ delegate: GameEventDelegate) {
    NotificationCenter.default.addObserver(
        delegate,
        selector: #selector(delegate.onEventHappened(_:)),
        name: .eventHappened,
        object: nil
    )
}

func stopEventObserving(_ delegate: GameEventDelegate) {
    NotificationCenter.default.removeObserver(delegate)
}

var userSaidSentences: [String: String] = [:]

func getFuriganaString(tokenInfos: [[String]]) -> NSMutableAttributedString {
    return NSMutableAttributedString()
}
