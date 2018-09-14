//
//  utilities.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/04/16.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import Promises

// MARK: - Utilities
// https://stackovercmd.com/questions/24231680/loading-downloading-image-from-url-on-swift
func getDataFromUrl(url: String, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
    guard let url = URL(string: url) else { print("invalid url"); return }
    URLSession.shared.dataTask(with: url) { data, response, error in
        completion(data, response, error)
    }.resume()
}

func loadCharacterProfile() {
    getDataFromUrl(url: yuiUrl) { data, _, error in
        guard let data = data, error == nil else { return }
        DispatchQueue.main.async {
            GameContext.shared.characterImage = UIImage(data: data)
        }
    }
}

// MARK: - Audio Session
func configureAudioSession() {
    do {
        let session: AVAudioSession = AVAudioSession.sharedInstance()
        try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: [.duckOthers, .allowBluetoothA2DP, .allowBluetooth, .allowAirPlay, .defaultToSpeaker])

        // turn the measure mode will crash bluetooh, duckOthers and mixWithOthers
        //try session.setMode(AVAudioSessionModeMeasurement)

        // per ioBufferDuration delay
        // default  23ms | 1024 frames | <1% CPU (iphone SE)
        // 0.001   0.7ms |   32 frames |  8% CPU
        try session.setPreferredIOBufferDuration(0.002)
        // print(session.ioBufferDuration)

        session.requestRecordPermission({ (success) in
            if success { print("Record Permission Granted") } else {
                print("Record Permission fail")
            }
        })
    } catch {
        print("configuare audio session with \(error)")
    }
}

// MARK: - Misc
func getNow() -> Double {
    return NSDate().timeIntervalSince1970
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

    tagger.enumerateTags(in: range, scheme: .tokenType, options: []) { (tag, tokenRange, _, _) in
        let token = (text as NSString).substring(with: tokenRange)
        if tag?.rawValue == "Punctuation" {
            curSentences += token
            sentences.append(curSentences)
            curSentences = ""
        } else {
            curSentences += token
        }
    }
    return sentences
}

// MARK: - Edit Distance
// EditDistance from https://en.wikibooks.org/wiki/Algorithm_Implementation/Strings/Levenshtein_distance#Swift
private func min3(_ a: Int, _ b: Int, _ c: Int) -> Int {
    return min( min(a, c), min(b, c))
}

private class Array2D {
    var cols: Int, rows: Int
    var matrix: [Int]

    init(cols: Int, rows: Int) {
        self.cols = cols
        self.rows = rows
        matrix = Array(repeating: 0, count: cols*rows)
    }

    subscript(col: Int, row: Int) -> Int {
        get {
            return matrix[cols * row + col]
        }
        set {
            matrix[cols*row+col] = newValue
        }
    }

    func colCount() -> Int {
        return self.cols
    }

    func rowCount() -> Int {
        return self.rows
    }
}

func distanceBetween(_ aStr: String, _ bStr: String) -> Int {
    let a = Array(aStr.utf16)
    let b = Array(bStr.utf16)

    if a.isEmpty || b.isEmpty {
        return a.count + b.count
    }

    let dist = Array2D(cols: a.count + 1, rows: b.count + 1)

    for i in 1...a.count {
        dist[i, 0] = i
    }

    for j in 1...b.count {
        dist[0, j] = j
    }

    for i in 1...a.count {
        for j in 1...b.count {
            if a[i-1] == b[j-1] {
                dist[i, j] = dist[i-1, j-1]  // noop
            } else {
                dist[i, j] = min3(
                    dist[i-1, j] + 1,  // deletion
                    dist[i, j-1] + 1,  // insertion
                    dist[i-1, j-1] + 1  // substitution
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

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}

extension Int {
    var f: Float { return Float(self) }
    var c: CGFloat { return CGFloat(self) }
    var s: String { return String(self) }
}

extension Float {
    var i: Int { return Int(self) }
    var c: CGFloat { return CGFloat(self) }
}

extension CGFloat {
    var f: Float { return Float(self) }
}

// MARK: - launch storyboard
func launchStoryboard(
    _ originVC: UIViewController,
    _ storyboardId: String,
    isOverCurrent: Bool = false,
    animated: Bool = false
    ) {
    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: storyboardId)
    if isOverCurrent {
        vc.modalPresentationStyle = .overCurrentContext
    }
    originVC.present(vc, animated: animated, completion: nil)
}

// MARK: - Misc For Dev Only
func dumpAvaliableVoices() {
    for voice in AVSpeechSynthesisVoice.speechVoices() {
        //if ((availableVoice.language == AVSpeechSynthesisVoice.currentLanguageCode()) &&
        //    (availableVoice.quality == AVSpeechSynthesisVoiceQuality.enhanced)) {
        if voice.language == "ja-JP" || voice.language == "zh-TW" {
            print("\(voice.name) on \(voice.language) with Quality: \(voice.quality.rawValue) \(voice.identifier)")
        }
        //}
    }
}

// measure performance
var startTime: Double = 0
func setStartTime(_ tag: String = "") {
    startTime = NSDate().timeIntervalSince1970
    print(tag)
}
func printDuration(_ tag: String = "") {
    print(tag, (NSDate().timeIntervalSince1970 - startTime)*1000, "ms")
}

// Promise Utilities
func fulfilledVoidPromise() -> Promise<Void> {
    let promise = Promise<Void>.pending()
    promise.fulfill(())
    return promise
}

func pausePromise(_ seconds: Double) -> Promise<Void> {
    let p = Promise<Void>.pending()
    Timer.scheduledTimer(withTimeInterval: seconds, repeats: false) { _ in
        p.fulfill(())
    }
    return p
}

extension String {
    func padWidthTo(_ width: Int, isBothSide: Bool = false) -> String {
        let padCount = max(width - self.count, 0)

        func getEmptySpaces(_ padCount: Int) -> String {
            guard padCount > 0 else { return "" }
            var spaces = ""
            for _ in 1...padCount { spaces += " " }
            return spaces
        }

        if isBothSide {
            let leftPadCount =  padCount / 2
            let rightPadCount = padCount - leftPadCount
            return getEmptySpaces(leftPadCount) + self + getEmptySpaces(rightPadCount)
        }

        return getEmptySpaces(padCount) + self
    }
}

func saveToUserDefault<T: Codable>(object: T, key: String) {
    let encoder = JSONEncoder()
    if let encoded = try? encoder.encode(object) {
        UserDefaults.standard.set(encoded, forKey: key)
    } else {
        print("save \(key) Failed")
    }
}

func loadFromUserDefault<T: Codable>(type: T.Type, key: String) -> T? {
    let decoder = JSONDecoder()
    if let data = UserDefaults.standard.data(forKey: key),
        let obj = try? decoder.decode(T.self, from: data) {
        return obj as T
    }
    print("load \(key) Failed")
    return nil
}
