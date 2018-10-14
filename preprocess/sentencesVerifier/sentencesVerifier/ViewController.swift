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
var sentences: [String] = ["おはよう", "こんにちわ", "わかりました", "いろいろどぞよろしく"]

var vc:ViewController!

class ViewController: NSViewController {
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet var textView: NSTextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareSpeak()
        vc = self
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        scrollView.becomeFirstResponder()
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
    print("verify \(sentencesIdx) < \(sentences.count)")
    vc.scrollView.becomeFirstResponder()
    guard sentencesIdx < sentences.count else { return }
    let s = sentences[sentencesIdx]
    vc.textView.insertText("\n\(s)|")
    toggleSTT()
    Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
        speak(s)
    }
    sentencesIdx += 1
}

func OurSpeechDoneCallBackProc(_ inSpeechChannel: SpeechChannel, _ inRefCon: SRefCon) {
    print("speech is done1")
    toggleSTT()
    print("speech is done2")
    DispatchQueue.main.async {
        print("x")
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            print("y")
            verifyNextSentence()
        }
    }
}

//https://stackoverflow.com/questions/27484330/simulate-keypress-using-swift
func toggleSTT() {
    FakeKey.send(63, useCommandFlag: false)
    FakeKey.send(63, useCommandFlag: false)
}
