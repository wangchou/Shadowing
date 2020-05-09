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

    class TTS: NSObject {
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

        func say(_ text: String,
                 voiceId: String,
                 rate: Float = AVSpeechUtteranceDefaultSpeechRate // 0.5, range 0 ~ 1.0
        ) -> Promise<Void> {
            SpeechEngine.shared.stopListeningAndSpeaking()
            synthesizer.delegate = self
            let utterance = AVSpeechUtterance(string: getFixedKanaForTTS(text))
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

            let isCompactVoice = "\(utterance.voice?.identifier)".contains("compact")
            utterance.volume = isCompactVoice ? 1.0 : 0.8

            postEvent(.sayStarted, string: text)
            synthesizer.speak(utterance)
            promise = Promise<Void>.pending()

            return promise
        }

        func stop() {
            synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
            promise.fulfill(())
        }
    }

    extension TTS: AVSpeechSynthesizerDelegate {
        func speechSynthesizer(_: AVSpeechSynthesizer,
                               didFinish _: AVSpeechUtterance) {
            postEvent(.speakEnded)
            promise.fulfill(())
        }

        func speechSynthesizer(_: AVSpeechSynthesizer,
                               willSpeakRangeOfSpeechString characterRange: NSRange,
                               utterance _: AVSpeechUtterance) {
            postEvent(.willSpeakRange, range: characterRange)
        }

        func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
            postEvent(.speakEnded)
            promise.fulfill(())
        }
    }
#endif
