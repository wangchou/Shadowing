//
import Cocoa
import Promises
//  ViewController.swift
//  sentencesVerifier
//
//  Created by Wangchou Lu on 10/14/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//
import SwiftSyllablesMac

var sentencesIdx = 0
var sentenceIds: [Int] = []
var sentences: [String] = []

// speed up
var bothPerfectCounts: [Int: Int] = [:] // every kanaCount/SyllablesCount 1000
var currentVoicePerfectCounts: [Int: Int] = [:] // every kanaCount/SyllablesCount 2000
var pairedVoicePerfectCounts: [Int: Int] = [:] // every kanaCount/SyllablesCount 2000
var bothPerfectCountLimit = 1000
var voicePerfectCountLimit = 2000
var syllablesLenLimit = 30
func now() -> TimeInterval { return NSDate().timeIntervalSince1970 }
var startTime = now()

var vc: ViewController!
var verifyNextSentence: () -> Void = verifyNextChallengeSentence

// 1. set sunflower 2ch as input and output
// 2. in accessibility make sure the setting of "STT do not mute other audio"
// 3. let programe say some sentence with offline enhanced dictation then turn it off.
//    then use online STT like iOS
// run this whole day

// infinite challenge dataset
var isProcessingICDataset = true
var isUpdateDB = true
var speaker: Speaker = .otoya
var sortedIds: [Int] = []
var count = 0
var totalCount = 0

var speakerList: [Speaker] = [.otoya, .kyoko, .samantha, .alex]

class ViewController: NSViewController {
    @IBOutlet var scrollView: NSScrollView!
    @IBOutlet var label: NSTextField!
    @IBOutlet var textView: NSTextView!
    @IBOutlet var speakerSegmentControl: NSSegmentedControl!
    @IBOutlet var rightTextView: NSTextView!
    @IBOutlet var wrongTextView: NSTextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        vc = self
        speakerSegmentControl.segmentCount = speakerList.count
        for (i, speaker) in speakerList.enumerated() {
            speakerSegmentControl.setWidth(70, forSegment: i)
            speakerSegmentControl.setLabel(speaker.rawValue, forSegment: i)
        }
        speakerSegmentControl.frame.size.width = (speakerList.count * 70).c
        speakerSegmentControl.setSelected(true, forSegment: 0)
    }

    @IBAction func onSpeakerSwitched(_: Any) {
        speaker = speakerList[speakerSegmentControl.selectedSegment]
    }

    @IBAction func sayButtonClicked(_: Any) {
        isProcessingICDataset = true
        loadICSentences()
        setupSpeechChannelAndDoneCallback()
        verifyNextSentence()
    }

    // This is freaking slow, only 30 updates/sec
    // Not sure why swift sqlite3 library could be so slow
    // Oh damn, this library even not support connectionPool...
    // Nodejs runs on 500 updates/sec
    @IBAction func calculateScoreButtonClicked(_: Any) {
        startTime = now()
        loadICSentences()
        count = 0
        totalCount = 0
        sentencesIdx = 0
        sortedIds = idToSiriSaid.keys.sorted()
        calculateNextScores()
    }

    @IBAction func syllablesCountButtonClicked(_: Any) {
        startTime = now()
        speaker = .alex
        loadICSentences()
        for id in idToSentences.keys.sorted() {
            guard let en = idToSentences[id] else { continue }
            let syllablesCount = SwiftSyllables.getSyllables(en.spellOutNumbers())
            updateSyllablesCount(id: id, syllablesCount: syllablesCount)
        }
        print("Syllables count updated \(round(now() - startTime))s")
    }

    @IBAction func enDifficutyButtonClicked(_: Any) {
        updateEnSentencesDifficulty()
    }

    @IBAction func topicSentenceButtonClicked(_: Any) {
        verifyAllTopicSentences()
    }

    func calculateNextScores() {
        var promiseArr: [Promise<Void>] = []
        let batchSize = 30
        let endIndex = min(sentencesIdx + batchSize - 1, sortedIds.count - 1)
        // print(sortedIds[sentencesIdx...endIndex])

        for id in sortedIds[sentencesIdx ... endIndex] {
            let promise = Promise<Void>.pending()
            guard idToScore[id] == nil || idToScore[id] == 0 else { continue }
            guard let siriSaid = idToSiriSaid[id],
                siriSaid != "" else { continue }
            guard let originalText = idToSentences[id] else { continue }
            promiseArr.append(promise)
            var calcScoreFn: (String, String) -> Promise<Score>
            switch speaker {
            case .alex, .samantha:
                calcScoreFn = calculateScoreEn
            case .otoya, .kyoko:
                calcScoreFn = calculateScore
            }
            calcScoreFn(originalText, siriSaid).then { score in
                updateScore(id: id, score: score)
                totalCount += 1
                if score.value != 100 { count += 1 }
                if totalCount % 100 == 0 {
                    print("\(count) | \(id) | \(sortedIds.count) \(round(now() - startTime))s")
                }
                promise.fulfill(())
            }
        }
        sentencesIdx += batchSize
        all(promiseArr).always {
            if sentencesIdx < sortedIds.count {
                DispatchQueue.main.async {
                    self.calculateNextScores()
                }
            } else {
                print("\(count) / \(totalCount) \(round(now() - startTime))s")
            }
        }
    }
}

func loadICSentences() {
    guard isProcessingICDataset else { print("call loadICSentences in non IC mode"); return }

    sentenceIds = []

    switch speaker {
    case .otoya, .kyoko:
        bothPerfectCountLimit = 1000
        voicePerfectCountLimit = 2000
        syllablesLenLimit = 40
    case .alex, .samantha:
        bothPerfectCountLimit = 1500
        voicePerfectCountLimit = 2000
        syllablesLenLimit = 30
    }
    loadWritableDb()
    startTime = now()
    for id in idToSentences.keys.sorted() {
        // perfect count filtering
        guard let syllablesLen = idToSyllablesLen[id] else { continue }
        guard syllablesLen <= syllablesLenLimit else { continue }
        let bothPerfectCount = bothPerfectCounts[syllablesLen] ?? 0
        let pairedVoicePerfectCount = pairedVoicePerfectCounts[syllablesLen] ?? 0
        let currentVoicePerfectCount = currentVoicePerfectCounts[syllablesLen] ?? 0
        if pairedVoicePerfectCount >= voicePerfectCountLimit { continue }
        if bothPerfectCount >= bothPerfectCountLimit { continue }
        if currentVoicePerfectCount >= voicePerfectCountLimit { continue }

        if idToScore[id] == 100 {
            currentVoicePerfectCounts[syllablesLen] = currentVoicePerfectCount + 1
        }
        if idToPairedScore[id] == 100 {
            pairedVoicePerfectCounts[syllablesLen] = pairedVoicePerfectCount + 1
            if idToScore[id] == 100 {
                bothPerfectCounts[syllablesLen] = bothPerfectCount + 1
            }
        }

        // guard id % 30 == 0 else { continue }

        guard idToSiriSaid[id] == "" || idToSiriSaid[id] == nil else { continue }
        let pairedScore = idToPairedScore[id]
        if pairedScore == nil || pairedScore == 100 {
            sentenceIds.append(id)
        }
    }
    sentences = getSentencesByIds(ids: sentenceIds)

    print(sentenceIds.count)
    print(bothPerfectCounts)
    print(currentVoicePerfectCounts)
}

func verifyNextChallengeSentence() {
    let duration = "\(round(now() - startTime))s"
    let percentage = "\(round(100.0 * Double(sentencesIdx) / Double(sentences.count)))%"
    vc.label.stringValue = "\(percentage) | \(duration) | \(sentencesIdx)/\(sentences.count)"

    vc.scrollView.becomeFirstResponder()

    while true {
        guard sentencesIdx < sentences.count else { return }
        guard isProcessingICDataset else { break }
        if isPerfectCountOverLimit(id: sentenceIds[sentencesIdx]) {
            sentencesIdx = sentencesIdx + 1
        } else {
            break
        }
    }

    let s = sentences[sentencesIdx]
    vc.textView.string = ""
    toggleSpeechToText()
    Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
        say(s)
    }
    sentencesIdx += 1
}

private func isPerfectCountOverLimit(id: Int) -> Bool {
    // let id = sentenceIds[sentencesIdx]
    let syllablesLen = idToSyllablesLen[id]!
    let bothPerfectCount = bothPerfectCounts[syllablesLen] ?? 0
    let currentVoicePerfectCount = currentVoicePerfectCounts[syllablesLen] ?? 0
    if bothPerfectCount >= bothPerfectCountLimit ||
        currentVoicePerfectCount >= voicePerfectCountLimit {
        return true
    }
    return false
}

func updatePerfectCount(id: Int, score: Score) {
    if score.value == 100 {
        let syllablesLen = idToSyllablesLen[id]!
        let bothPerfectCount = bothPerfectCounts[syllablesLen] ?? 0
        let currentVoicePerfectCount = currentVoicePerfectCounts[syllablesLen] ?? 0
        currentVoicePerfectCounts[syllablesLen] = currentVoicePerfectCount + 1
        if idToPairedScore[id] == 100 {
            bothPerfectCounts[syllablesLen] = bothPerfectCount + 1
        }
    }
}
