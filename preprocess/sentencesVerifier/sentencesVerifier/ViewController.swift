//
//  ViewController.swift
//  sentencesVerifier
//
//  Created by Wangchou Lu on 10/14/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//
import SwiftSyllablesMac
import Cocoa
import Promises

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

var vc:ViewController!
var verifyNextSentence: () -> () = verifyNextChallengeSentence

// 1. set sunflower 2ch as input and output
// 2. in accessibility make sure the setting of "STT do not mute other audio"
// 3. let programe say some sentence with offline enhanced dictation then turn it off.
//    then use online STTlike iOS
// run this whole day

var isInfiniteChallengePreprocessingMode = true
var isUpdateDB = true
var speaker: Speaker = .otoya
var sortedIds: [Int] = []
var count = 0
var totalCount = 0

var speakerList: [Speaker] = [.otoya, .kyoko, .samantha, .alex]

class ViewController: NSViewController {
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var label: NSTextField!
    @IBOutlet var textView: NSTextView!
    @IBOutlet weak var speakerSegmentControl: NSSegmentedControl!

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

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    @IBAction func onSpeakerSwitched(_ sender: Any) {
        speaker = speakerList[speakerSegmentControl.selectedSegment]
    }

    @IBAction func sayButtonClicked(_ sender: Any) {
        infiniteChallengeButtonClicked(speaker)
    }


    func infiniteChallengeButtonClicked(_ inSpeaker: Speaker) {
        isInfiniteChallengePreprocessingMode = true
        speaker = inSpeaker
        prepareSentences()
        prepareSpeak()
        scrollView.becomeFirstResponder()
        verifyNextSentence()
    }


    // This is freaking slow, only 30 updates/sec
    // Not sure why swift sqlite3 library could be so slow
    // Oh damn, this library even not support connectionPool...
    // Nodejs runs on 500 updates/sec
    @IBAction func calculateScoreButtonClicked(_ sender: Any) {
        calculateScoreButtonClicked(speaker)
    }


    func calculateScoreButtonClicked(_ inSpeaker: Speaker) {
        startTime = now()
        speaker = inSpeaker
        prepareSentences()
        count = 0
        totalCount = 0
        sentencesIdx = 0
        sortedIds = idToSiriSaid.keys.sorted()
        calculateNextScores()
    }

    func calculateNextScores() {
        var promiseArr: [Promise<Void>] = []
        let batchSize = 30
        let endIndex = min(sentencesIdx + batchSize - 1, sortedIds.count - 1)
        //print(sortedIds[sentencesIdx...endIndex])

        for id in sortedIds[sentencesIdx...endIndex] {
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

    @IBAction func syllablesCountButtonClicked(_ sender: Any) {
        startTime = now()
        speaker = .alex
        prepareSentences()
        for id in idToSentences.keys.sorted() {
            guard let en = idToSentences[id] else { continue }
            let syllablesCount = SwiftSyllables.getSyllables(en.spellOutNumbers())
            updateSyllablesCount(id: id, syllablesCount: syllablesCount)
        }
        print("Syllables count updated \(round(now() - startTime))s")
    }

    @IBAction func topicSentenceButtonClicked(_ sender: Any) {
        verifyAllTopicSentences()
    }
}

func prepareSentences() {
    sentenceIds = []
    if isInfiniteChallengePreprocessingMode {
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

            //guard id % 30 == 0 else { continue }

            guard idToSiriSaid[id] == "" || idToSiriSaid[id] == nil else { continue }
            let pairedScore = idToPairedScore[id]
            if pairedScore == nil || pairedScore == 100 {
                sentenceIds.append(id)
            }
        }
        sentences = getSentencesByIds(ids: sentenceIds)
    }

    print(sentenceIds.count)
    print(bothPerfectCounts)
    print(currentVoicePerfectCounts)
}

func verifyNextChallengeSentence() {
    let duration = "\(round(now() - startTime))s"
    let percentage = "\(round(100.0*Double(sentencesIdx)/Double(sentences.count)))%"
    vc.label.stringValue = "\(percentage) | \(duration) | \(sentencesIdx)/\(sentences.count)"

    vc.scrollView.becomeFirstResponder()
    
    while true {
        guard sentencesIdx < sentences.count else { return }
        guard isInfiniteChallengePreprocessingMode else { break }
        if isPerfectCountOverLimit(id: sentenceIds[sentencesIdx]){
            sentencesIdx = sentencesIdx + 1
        } else {
            break
        }
    }

    let s = sentences[sentencesIdx]
    vc.textView.string = ""
    toggleSTT()
    Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
        speak(s)
    }
    sentencesIdx += 1
}

private func isPerfectCountOverLimit(id: Int) -> Bool {
    //let id = sentenceIds[sentencesIdx]
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
