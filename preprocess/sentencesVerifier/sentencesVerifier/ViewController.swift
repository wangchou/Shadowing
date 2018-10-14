//
//  ViewController.swift
//  sentencesVerifier
//
//  Created by Wangchou Lu on 10/14/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

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

// 1. do not use offline enhanced dictation (turn off in setting, because the accuracy is much lower than iOS)
// 2. set sunflower 2ch as input and output
// 3. in accessibility make sure the setting of "STT do not mute other audio"
// run this whole day

class ViewController: NSViewController {
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var label: NSTextField!
    @IBOutlet var textView: NSTextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSentenceDB()
        createWritableDB()
        prepareSpeak()
        vc = self
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        scrollView.becomeFirstResponder()
        sentenceIds = []
        sentenceIds.append(contentsOf: randSentenceIds(minKanaCount: 1, maxKanaCount: 8, numOfSentences: 3000))
        sentenceIds.append(contentsOf: randSentenceIds(minKanaCount: 6, maxKanaCount: 12, numOfSentences: 3000))
        sentenceIds.append(contentsOf: randSentenceIds(minKanaCount: 9, maxKanaCount: 18, numOfSentences: 3000))
        sentenceIds.append(contentsOf: randSentenceIds(minKanaCount: 12, maxKanaCount: 24, numOfSentences: 3000))
        sentenceIds.append(contentsOf: randSentenceIds(minKanaCount: 18, maxKanaCount: 36, numOfSentences: 3000))

        sentences = getSentencesByIds(ids: sentenceIds)
        print(sentenceIds.count)
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
            verifyNextSentence()
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

func prepareSpeak() {
    // new channel
    theErr = NewSpeechChannel(nil, &fCurSpeechChannel)
    if theErr != OSErr(noErr) { print("error... 1") }

    // set voice to otoya
    let fSelectedVoiceID: OSType = 369338093
    let fSelectedVoiceCreator: OSType = 1886745202

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
    print("\(s) is spoken")
}

func verifyNextSentence() {
    let duration = "\(round(now() - startTime))s"
    let percentage = "\(round(100.0*Double(sentencesIdx)/Double(sentences.count)))%"
    vc.label.stringValue = "\(percentage) | \(duration) | \(sentencesIdx)/\(sentences.count)"
    print("verify \(sentencesIdx) < \(sentences.count)")
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
    DispatchQueue.main.async {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
            let s = vc.textView.string
            let id = sentenceIds[sentencesIdx-1]
            updateIdWithListened(id: id, siriSaid: s)
            print("id: \(id), siriSaid: \(s)")
            verifyNextSentence()
        }
    }
}

//https://stackoverflow.com/questions/27484330/simulate-keypress-using-swift
func toggleSTT() {
    FakeKey.send(63, useCommandFlag: false)
    FakeKey.send(63, useCommandFlag: false)
}
