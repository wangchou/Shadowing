//
//  ViewController.swift
//  sentencesVerifier
//
//  Created by Wangchou Lu on 10/14/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//
import SwiftSyllablesMac
import Cocoa
typealias SRefCon = UnsafeRawPointer
private var fCurSpeechChannel: SpeechChannel? = nil
private var theErr = OSErr(noErr)

var sentencesIdx = 0
var sentenceIds: [Int] = []
var sentences: [String] = []
func now() -> TimeInterval { return NSDate().timeIntervalSince1970 }
var startTime = now()

var vc:ViewController!

// 1. set sunflower 2ch as input and output
// 2. in accessibility make sure the setting of "STT do not mute other audio"
// 3. let programe say some sentence with offline enhanced dictation then turn it off.
//    then use online STTlike iOS
// run this whole day

var isInfiniteChallengePreprocessingMode = true
var isUpdateDB = true
var isEnglishMode = true

class ViewController: NSViewController {
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var label: NSTextField!
    @IBOutlet var textView: NSTextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareSentences()
        prepareSpeak()
        vc = self
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func jaInfiniteChallengeButtonClicked(_ sender: Any) {
        isInfiniteChallengePreprocessingMode = true
        isEnglishMode = false
        scrollView.becomeFirstResponder()
        verifyNextSentence()
    }

    @IBAction func enInifiniteChallengeButtonClicked(_ sender: Any) {
        isInfiniteChallengePreprocessingMode = true
        isEnglishMode = true
        scrollView.becomeFirstResponder()
        verifyNextSentence()
    }

    // This is freaking slow, only 30 updates/sec
    // Not sure why swift sqlite3 library could be so slow
    // Nodejs runs on 500 updates/sec
    @IBAction func enCalculateScoreButtonClicked(_ sender: Any) {
        startTime = now()
        var count = 0
        var totalCount = 0
        for id in idToSiriSaid.keys.sorted() {
            guard let siriSaid = idToSiriSaid[id],
                  siriSaid != "" else { continue }
            guard let en = idToSentences[id] else { continue }
            let score = calculateScoreEn(en, siriSaid)
            let syllablesCount = SwiftSyllables.getSyllables(en.spellOutNumbers())
            updateEnScoreAndSyllablesCount(id: id, score: score, syllablesCount: syllablesCount)
            totalCount += 1
            if score.value != 100 { count += 1 }
            if totalCount % 100 == 0 {
                print("\(count) / \(totalCount) \(round(now() - startTime))s")
            }
        }
        print("\(count) / \(totalCount) \(round(now() - startTime))s")
    }

    @IBAction func topicSentenceButtonClicked(_ sender: Any) {
        isInfiniteChallengePreprocessingMode = false
        isEnglishMode = true
        scrollView.becomeFirstResponder()
        verifyNextSentence()
    }
}

func prepareSentences() {
    sentenceIds = []
    if isInfiniteChallengePreprocessingMode {
        loadSentenceDB()
        createWritableDB()
        for id in idToSiriSaid.keys.sorted() {
            //guard id % 30 == 0 else { continue }
            if idToSiriSaid[id] == "" {
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
}

func prepareSpeak() {
    // new channel
    theErr = NewSpeechChannel(nil, &fCurSpeechChannel)
    if theErr != OSErr(noErr) { print("error... 1") }

    // set voice to Otoya
    var fSelectedVoiceID: OSType = 369338093
    var fSelectedVoiceCreator: OSType = 1886745202

    // set voice to Alex
    if isEnglishMode {
        fSelectedVoiceCreator = 1835364215
        fSelectedVoiceID = 201
    }

    let voiceDict: NSDictionary = [kSpeechVoiceID: fSelectedVoiceID,
                                   kSpeechVoiceCreator: fSelectedVoiceCreator]
    theErr = SetSpeechProperty(fCurSpeechChannel!, kSpeechCurrentVoiceProperty, voiceDict)

    if theErr != OSErr(noErr) { print("error... 2") }

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
    guard sentencesIdx < sentences.count else { return }
    let s = sentences[sentencesIdx]
    vc.textView.string = ""
    toggleSTT()
    Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
        speak(s)
    }
    sentencesIdx += 1
}

func OurSpeechDoneCallBackProc(_ inSpeechChannel: SpeechChannel, _ inRefCon: SRefCon) {
    toggleSTT()
    var waitTime:TimeInterval = 1.5
    if sentencesIdx % 100 == 0 {
        waitTime = 5.0
    }
    DispatchQueue.main.async {
        Timer.scheduledTimer(withTimeInterval: waitTime, repeats: false) { _ in
            let s = vc.textView.string
            let id = sentenceIds[sentencesIdx-1]
            if isInfiniteChallengePreprocessingMode {
                updateIdWithListened(id: id, siriSaid: s)
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

            verifyNextSentence()
        }
    }
}

//https://stackoverflow.com/questions/27484330/simulate-keypress-using-swift
func toggleSTT() {
    FakeKey.send(63, useCommandFlag: false)
    FakeKey.send(63, useCommandFlag: false)
}
