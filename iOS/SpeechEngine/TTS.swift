//
//  TTS.swift (Text to Speech)
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/04/16.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
#if os(iOS)
import AVFoundation
import Promises

enum TTSError: Error {
    case TTSStop
}

class TTS: NSObject, AVSpeechSynthesizerDelegate {
    var synthesizer: AVSpeechSynthesizer = AVSpeechSynthesizer()
    var promise = Promise<Void>.pending()
    var targetLanguage: String {
        switch gameLang {
        case .jp:
            return "ja-JP"
        default:
            return "en-US"

        }
    }

    func say(
        _ text: String,
        voiceId: String,
        rate: Float = AVSpeechUtteranceDefaultSpeechRate // 0.5, range 0 ~ 1.0
        ) -> Promise<Void> {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        }
        synthesizer.delegate = self
        let utterance = AVSpeechUtterance(string: getKanaFixedText(text))
        if let voice = AVSpeechSynthesisVoice(identifier: voiceId) {
            utterance.voice = voice
        } else {
            if targetLanguage == AVSpeechSynthesisVoice.currentLanguageCode() {
                // Do nothing, if not set utterance.voice
                // Siri will say it
            } else {
                utterance.voice = AVSpeechSynthesisVoice(language: targetLanguage)
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
#endif

let siriKanaFix: [String: String] = [
    "明日": "あした",
    "行って": "いって",
    "台湾人": "台湾じん",
    "辛い": "つらい",
    "何で": "なんで",
    "高すぎ": "たかすぎ",
    "後で": "あとで",
    "次いつ": "つぎいつ",
    "こちらの方": "こちらのほう",
    "米は不作": "こめは不作",
    "星野源": "ほしのげん",
    "宮城": "みやぎ",
    "原宿": "はぁらじゅく",
    "米、": "こめ、",
    "霞ケ関": "霞が関",
    "鶏肉": "とりにく",
    "欅坂46、乃木坂46": "欅坂フォーティーシックス、乃木坂フォーティーシックス",
    "二宮和也": "二宮かずなり",
    "隆盛": "たかもり",
    "博士": "はかせ",
    "私立学校": "しりつ学校"
]

func getKanaFixedText(_ text: String) -> String {
    var fixedText = text
    siriKanaFix.forEach { (kanji, kana) in
        fixedText = fixedText.replace(kanji, kana)
    }
    return fixedText
}
