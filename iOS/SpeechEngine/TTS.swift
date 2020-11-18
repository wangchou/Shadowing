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

    // input/displayed: 1日○○○○
    // after fix, we let tts say いちにち○○○○
    // ttsToDisplayMap will map willSpeakRange from いちにち○○○○ to 1日○○○○
    // it looks like [1 1 1 1 2 3 4 5]
    class TTS: NSObject {
        var synthesizer: AVSpeechSynthesizer = AVSpeechSynthesizer()
        var ttsToDisplayMap: [Int] = []
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

            getFixedTTSString(text, isJP: targetLanguage == "ja-JP").then { ttsString, ttsToDisplayMap in
                self.ttsToDisplayMap = ttsToDisplayMap
                let utterance = AVSpeechUtterance(string: ttsString)
                if let voice = AVSpeechSynthesisVoice(identifier: voiceId) {
                    utterance.voice = voice
                } else {
                    if self.targetLanguage == AVSpeechSynthesisVoice.currentLanguageCode() {
                        // Do nothing, if not set utterance.voice
                        // Siri will say it
                    } else {
                        utterance.voice = AVSpeechSynthesisVoice(language: self.targetLanguage)
                    }
                }

                utterance.rate = rate

                if isHeadphonePlugged() {
                    utterance.volume = 0.6
                } else {
                    utterance.volume = 1.0
                }
                // said jpn
                postEvent(.sayStarted, string: text)
                self.synthesizer.speak(utterance)
            }

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
            let first = ttsToDisplayMap[characterRange.lowerBound]
            let last = ttsToDisplayMap[characterRange.upperBound-1]
            postEvent(.willSpeakRange, range: NSRange(location: first,
                                                     length: last - first + 1))
        }

        func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
            postEvent(.speakEnded)
            promise.fulfill(())
        }
    }
#endif
