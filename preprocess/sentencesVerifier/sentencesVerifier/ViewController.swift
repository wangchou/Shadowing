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
typealias SRefCon = UnsafeRawPointer
private var fCurSpeechChannel: SpeechChannel? = nil
private var theErr = OSErr(noErr)

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

enum Speaker: String {
    case otoya="otoya"
    case kyoko="kyoko"
    case alex="alex"
    case samantha="samantha"

    var dbField: String {
        return self.rawValue
    }
    var dbScoreField: String {
        return self.rawValue + "_score"
    }

    var pairDbField: String {
        switch self {
        case .otoya:
        return Speaker.kyoko.rawValue
        case .kyoko:
            return Speaker.otoya.rawValue
        case .alex:
            return Speaker.samantha.rawValue
        case .samantha:
            return Speaker.alex.rawValue
        }
    }

    var pairDbScoreField: String {
        switch self {
        case .otoya:
            return Speaker.kyoko.dbScoreField
        case .kyoko:
            return Speaker.otoya.dbScoreField
        case .alex:
            return Speaker.samantha.dbScoreField
        case .samantha:
            return Speaker.alex.dbScoreField
        }
    }
}

var vc:ViewController!

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

class ViewController: NSViewController {
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var label: NSTextField!
    @IBOutlet var textView: NSTextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        vc = self
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func otoyaInfiniteChallengeButtonClicked(_ sender: Any) {
        infiniteChallengeButtonClicked(.otoya)
    }

    @IBAction func kyokoInfiniteChallengeButtonClicked(_ sender: Any) {
        infiniteChallengeButtonClicked(.kyoko)
    }

    @IBAction func alexInifiniteChallengeButtonClicked(_ sender: Any) {
        infiniteChallengeButtonClicked(.alex)
    }

    @IBAction func samanthaInifiniteChallengeButtonClicked(_ sender: Any) {
        infiniteChallengeButtonClicked(.samantha)
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
    @IBAction func alexCalculateScoreButtonClicked(_ sender: Any) {
        calculateScoreButtonClicked(.alex)
    }

    @IBAction func samanthaCalculateScoreButtonClicked(_ sender: Any) {
        calculateScoreButtonClicked(.samantha)
    }

    @IBAction func otoyaCalculateScoreButtonClicked(_ sender: Any) {
        calculateScoreButtonClicked(.otoya)
    }

    @IBAction func kyokoCalculateScoreButtonClicked(_ sender: Any) {
        calculateScoreButtonClicked(.kyoko)
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
        isInfiniteChallengePreprocessingMode = false
        speaker = .otoya
        scrollView.becomeFirstResponder()
        verifyNextSentence()
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
    } else {
        print("set count: ", rawDataSets.count)
        //shadowingSentences.forEach { sArray in sentences.append(contentsOf: sArray) }
        for i in 0...30 {
            sentences.append(contentsOf: rawDataSets[i])
        }
        for i in 0...sentences.count {
            sentenceIds.append(i)
        }
    }

    print(sentenceIds.count)
    print(bothPerfectCounts)
    print(currentVoicePerfectCounts)
}

func prepareSpeak() {
    // new channel
    theErr = NewSpeechChannel(nil, &fCurSpeechChannel)
    if theErr != OSErr(noErr) { print("error... 1") }

    // set voice to Otoya
    var fSelectedVoiceID: OSType = 201
    var fSelectedVoiceCreator: OSType = 1835364215

    // set voice to Alex
    switch speaker {
    case .alex:
        fSelectedVoiceCreator = 1835364215
        fSelectedVoiceID = 201
    case .samantha:
        fSelectedVoiceCreator = 1886745202
        fSelectedVoiceID = 184844493
    case .otoya:
        fSelectedVoiceID = 369338093
        fSelectedVoiceCreator = 1886745202
    case .kyoko:
        fSelectedVoiceCreator = 1886745202
        fSelectedVoiceID = 369275117
    }

    let voiceDict: NSDictionary = [kSpeechVoiceID: fSelectedVoiceID,
                                   kSpeechVoiceCreator: fSelectedVoiceCreator]
    theErr = SetSpeechProperty(fCurSpeechChannel!, kSpeechCurrentVoiceProperty, voiceDict)

    if theErr != OSErr(noErr) {
        // if see this error go to system tts panel and select the voice
        print("error... 2", theErr)
        print(speaker)
        print(fSelectedVoiceCreator, fSelectedVoiceID)
    }

    if theErr == OSErr(noErr) {
        typealias DoneCallBackType = @convention(c) (SpeechChannel, SRefCon)->Void
        let callback = OurSpeechDoneCallBackProc as DoneCallBackType?
        let callbackAddr = unsafeBitCast(callback, to: UInt.self) as CFNumber
        theErr = SetSpeechProperty(fCurSpeechChannel!,
                                   kSpeechSpeechDoneCallBack,
                                   callbackAddr)
        if theErr != OSErr(noErr) {
           print("gg in setup done call back")
        }
    }
}

func speak(_ s: String) {
    theErr = SpeakCFString(fCurSpeechChannel!, s as CFString, nil)
    if theErr != OSErr(noErr) { print("error... speak") }
    //print("\(s) is spoken")
}

func verifyNextSentence() {
    let duration = "\(round(now() - startTime))s"
    let percentage = "\(round(100.0*Double(sentencesIdx)/Double(sentences.count)))%"
    vc.label.stringValue = "\(percentage) | \(duration) | \(sentencesIdx)/\(sentences.count)"

    vc.scrollView.becomeFirstResponder()
    while true {
        guard sentencesIdx < sentences.count else { return }
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
    let id = sentenceIds[sentencesIdx]
    let syllablesLen = idToSyllablesLen[id]!
    let bothPerfectCount = bothPerfectCounts[syllablesLen] ?? 0
    let currentVoicePerfectCount = currentVoicePerfectCounts[syllablesLen] ?? 0
    if bothPerfectCount >= bothPerfectCountLimit ||
        currentVoicePerfectCount >= voicePerfectCountLimit {
        return true
    }
    return false
}


private func updatePerfectCount(id: Int, score: Score) {
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

func OurSpeechDoneCallBackProc(_ inSpeechChannel: SpeechChannel, _ inRefCon: SRefCon) {
    toggleSTT()
    let waitTime:TimeInterval = 1.5
    var isEmptyString: Bool = false

    DispatchQueue.main.async {
        Timer.scheduledTimer(withTimeInterval: waitTime, repeats: false) { _ in
            let s = vc.textView.string
            isEmptyString = s == ""
            let id = sentenceIds[sentencesIdx-1]
            if isInfiniteChallengePreprocessingMode {
                //updateIdWithListened(id: id, siriSaid: s)
                var calcScoreFn: (String, String) -> Promise<Score>
                switch speaker {
                case .alex, .samantha:
                    calcScoreFn = calculateScoreEn
                case .otoya, .kyoko:
                    calcScoreFn = calculateScore
                }
                calcScoreFn(idToSentences[id]!, s).then { score in
                    updatePerfectCount(id: id, score: score)
                    updateSiriSaidAndScore(id: id, siriSaid: s, score: score)
                }
            } else {
                let s1 = sentences[id]
                let s2 = s
                calculateScore(s1, s2).then { score -> Void in
                    if score.value != 100 {
                        print("-------")
                        print(score.value)
                        print(s1)
                        print(s2)
                    }
                }

            }

            // listening and speaking time off => one more double fn-fn
            if isEmptyString {
                toggleSTT()
                Timer.scheduledTimer(withTimeInterval: waitTime, repeats: false) { _ in
                    verifyNextSentence()

                }
            } else {
                verifyNextSentence()
            }
        }
    }
}

//https://stackoverflow.com/questions/27484330/simulate-keypress-using-swift
func toggleSTT() {
    FakeKey.send(63, useCommandFlag: false)
    FakeKey.send(63, useCommandFlag: false)
}
