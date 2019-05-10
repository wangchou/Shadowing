//
//  ViewContoller+Speak.swift
//  sentencesVerifier
//
//  Created by Wangchou Lu on 12/26/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation
import Cocoa
import Promises

typealias SRefCon = UnsafeRawPointer
private var fCurSpeechChannel: SpeechChannel? = nil
private var theErr = OSErr(noErr)

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

func say(_ s: String) {
    theErr = SpeakCFString(fCurSpeechChannel!, getFixedKanaForTTS(s) as CFString, nil)
    if theErr != OSErr(noErr) { print("error... speak") }
    //print("\(s) is spoken")
}

func setupSpeechChannelAndDoneCallback() {
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
        let callback = onSpeakEnded as DoneCallBackType?
        let callbackAddr = unsafeBitCast(callback, to: UInt.self) as CFNumber
        theErr = SetSpeechProperty(fCurSpeechChannel!,
                                   kSpeechSpeechDoneCallBack,
                                   callbackAddr)
        if theErr != OSErr(noErr) {
            print("gg in setup done call back")
        }
    }
}

private func onSpeakEnded(_ inSpeechChannel: SpeechChannel, _ inRefCon: SRefCon) {
    toggleSpeechToText()
    let waitTime:TimeInterval = 1.5
    var isEmptyString: Bool = false

    DispatchQueue.main.async {
        Timer.scheduledTimer(withTimeInterval: waitTime, repeats: false) { _ in
            let s = vc.textView.string
            isEmptyString = s == ""
            let id = sentenceIds[sentencesIdx-1]
            if isProcessingICDataset {
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
                    nextSentence(isNeedToReset: isEmptyString)
                }
            } else {
                let s1 = sentences[id]
                let s2 = s
                calculateScore(s1, s2).then { score -> Void in
                    if score.value != 100 {
                        print(score.value)
                        print(s1)
                        print(s2)
                        isGroupCorrect = false
                    }
                    nextSentence(isNeedToReset: isEmptyString)
                }
            }
        }
    }
}

func nextSentence(isNeedToReset: Bool) {
    let waitTime:TimeInterval = 1.5
    // listening and speaking time off => one more double fn-fn
    if isNeedToReset {
        toggleSpeechToText()
        Timer.scheduledTimer(withTimeInterval: waitTime, repeats: false) { _ in
            verifyNextSentence()
        }
    } else {
        verifyNextSentence()
    }
}

//https://stackoverflow.com/questions/27484330/simulate-keypress-using-swift
func toggleSpeechToText() {
    FakeKey.send(63, useCommandFlag: false)
    FakeKey.send(63, useCommandFlag: false)
}
