//
//  TTS.swift (Text to Speech)
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/04/16.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import AVFoundation
import Promises

enum TTSError: Error {
    case TTSStop
}

class TTS: NSObject, AVSpeechSynthesizerDelegate {
    var synthesizer: AVSpeechSynthesizer = AVSpeechSynthesizer()
    var promise = Promise<Void>.pending()
    var name: String = ""

    func say(
        _ text: String,
        name: String? = nil,
        language: String? = nil,
        rate: Float = AVSpeechUtteranceDefaultSpeechRate // 0.5, range 0 ~ 1.0
        ) -> Promise<Void> {
        synthesizer.delegate = self
        let utterance = AVSpeechUtterance(string: text)
        if let name = name {
            utterance.voice = AVSpeechSynthesisVoice(identifier: name)
        } else if let language = language {
            utterance.voice = AVSpeechSynthesisVoice(language: language)
        } else {
            print("Error not specifiy voice name or language code")
            return fulfilledVoidPromise()
        }
        utterance.rate = rate
        postEvent(.sayStarted, string: text)
        synthesizer.speak(utterance)
        promise = Promise<Void>.pending()
        self.name = name ?? language ?? "nil"
        return promise
    }

    func stop() {
        synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        postEvent(.sayEnded, string: "")
        promise.reject(TTSError.TTSStop)
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                           willSpeakRangeOfSpeechString characterRange: NSRange,
                           utterance: AVSpeechUtterance) {
        let speechString = utterance.speechString as NSString
        let token = speechString.substring(with: characterRange)
        postEvent(.stringSaid, string: token)
    }

    func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didFinish utterance: AVSpeechUtterance
        ) {
        postEvent(.sayEnded, string: name)
        promise.fulfill(())
    }
}
