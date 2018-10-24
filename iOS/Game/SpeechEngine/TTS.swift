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

    func say(
        _ text: String,
        name: String,
        rate: Float = AVSpeechUtteranceDefaultSpeechRate // 0.5, range 0 ~ 1.0
        ) -> Promise<Void> {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        }
        synthesizer.delegate = self
        let utterance = AVSpeechUtterance(string: getKanaFixedText(text))
        if let voice = AVSpeechSynthesisVoice(identifier: name) {
            utterance.voice = voice
        } else {
            // prefer use system default(Siri) than lanuage default
            if "ja-JP" != AVSpeechSynthesisVoice.currentLanguageCode() {
                utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
            }
        }

        utterance.rate = rate
        postEvent(.sayStarted, string: text)
        synthesizer.speak(utterance)
        promise = Promise<Void>.pending()

        return promise
    }

    func stop() {
        synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        promise.fulfill(())
    }

    func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didFinish utterance: AVSpeechUtterance
        ) {
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
    for (kanji, kana) in siriKanaFix {
        fixedText = fixedText.replace(kanji, kana)
    }
    return fixedText
}
