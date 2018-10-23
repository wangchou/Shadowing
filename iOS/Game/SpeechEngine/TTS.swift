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
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        }
        synthesizer.delegate = self
        let utterance = AVSpeechUtterance(string: getKanaFixedText(text))
        if let name = name,
           let voice = AVSpeechSynthesisVoice(identifier: name) {
            utterance.voice = voice
        } else {
            // prefer use system default(Siri) than lanuage default
            if let language = language,
                language != AVSpeechSynthesisVoice.currentLanguageCode() {
                utterance.voice = AVSpeechSynthesisVoice(language: language)
            } else if language == nil {
                utterance.voice = AVSpeechSynthesisVoice(language: "ja")
            }
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
        //promise.reject(TTSError.TTSStop)
        promise.fulfill(())
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

private let siriKanaFix: [String: String] = [
    "明日": "あした",
    "行って": "いって",
    "台湾人": "台湾じん"
]

private func getKanaFixedText(_ text: String) -> String {
    var fixedText = text
    siriKanaFix.keys.forEach { kanji in
        fixedText = fixedText.replace(kanji, siriKanaFix[kanji]!)
    }
    return fixedText
}
