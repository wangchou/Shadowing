//
//  utilities.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/04/16.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import AVFoundation

// async and await

let myGroup = DispatchGroup()
let myQueue = DispatchQueue(label: "for Sync/Blocking version of async functions")

func waitConcurrentJobs() {
    myGroup.wait()
}
/* async and await usage
// original function (async version)
func download(_ something: String, _ seconds: UInt32 = 1, completionHandler: @escaping ()->Void = {}) {
    print("Downloading \(something)")
    DispatchQueue.global().async {
        sleep(seconds)
        print("\(something) is downloaded")
        completionHandler()
    }
}

// wrapped function (synced version)
// Warning:
// It blocks current thead !!!
// Do not call it on main thread
func downloadSync(
    _ something: String,
    _ seconds: UInt32 = 1,
    isConcurrent: Bool = false
    ){
    myGroup.enter()
    download(something, seconds) { myGroup.leave() }
    if !isConcurrent {
        myGroup.wait()
    }
}

// after wrapping async function to sync version
// now it really looks like ES8 async/await
myQueue.async {
    downloadSync("A")
    downloadSync("B", isConcurrent: true)
    downloadSync("C", 4, isConcurrent: true)
    downloadSync("D", isConcurrent: true)
    waitConcurrentJobs()
    downloadSync("E")
}
*/


func configureAudioSession(_ toSpeaker: Bool = false) {
    do {
        let session: AVAudioSession = AVAudioSession.sharedInstance()
        if toSpeaker {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: [.mixWithOthers, .allowBluetoothA2DP, .allowBluetooth, .allowAirPlay, .defaultToSpeaker])
        } else {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: [.mixWithOthers, .allowBluetoothA2DP, .allowBluetooth, .allowAirPlay])
        }
        
        // turn the measure mode will crash bluetooh and mixWithOthers
        //try session.setMode(AVAudioSessionModeMeasurement)
        
        // per ioBufferDuration
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

func getNow() -> Double {
    return NSDate().timeIntervalSince1970
}

// separate long text by punctuations
func getSentences(_ text: String) -> [String] {
    let tagger = NSLinguisticTagger(
        tagSchemes: NSLinguisticTagger.availableTagSchemes(forLanguage: "ja"),
        options: 0
    )
    
    var sentences: [String] = []
    var curSentences = ""
    
    tagger.string = text
    let range = NSMakeRange(0, text.count)
    
    tagger.enumerateTags(in: range, scheme: .tokenType, options: []) { (tag, tokenRange, sentenceRange, stop) in
        let token = (text as NSString).substring(with: tokenRange)
        if(tag?.rawValue == "Punctuation") {
            curSentences += token
            sentences.append(curSentences)
            curSentences = ""
        } else {
            curSentences += token
        }
    }
    return sentences
}


// EditDistance from https://en.wikibooks.org/wiki/Algorithm_Implementation/Strings/Levenshtein_distance#Swift

func min3(_ a: Int, _ b: Int, _ c: Int) -> Int {
    return min( min(a, c), min(b, c))
}

class Array2D {
    var cols:Int, rows:Int
    var matrix: [Int]
    
    init(cols:Int, rows:Int) {
        self.cols = cols
        self.rows = rows
        matrix = Array(repeating:0, count:cols*rows)
    }
    
    subscript(col:Int, row:Int) -> Int {
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
    
    if(a.count == 0 || b.count == 0) {
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

//////////////////////////////////
// misc section: only used in DEV

func dumpVoices() {
    for voice in AVSpeechSynthesisVoice.speechVoices() {
        //if ((availableVoice.language == AVSpeechSynthesisVoice.currentLanguageCode()) &&
        //    (availableVoice.quality == AVSpeechSynthesisVoiceQuality.enhanced)) {
        if(voice.language == "ja-JP" || voice.language == "zh-TW") {
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

// Latency tested result
// AVAudioEngine ~= 5.41ms
// AudioKit ~= 16.25ms
// Decision: use AVAudioEngine

// Tested setup
// channel one: sound -> iphone mic -> this play through app -> usb mixer -> garageband
// channel two: sound -> macbook mic -> garageband
// latency ~= the time interval between signal appear of channel one and channel two

/*
 test: AudioKit code with (mic -> speaker) latency ~= 16.25ms
 
 AKSettings.bufferLength = .Shortest
 let mic = AKMicrophone()
 AudioKit.output = mic
 AudioKit.start()
 */


