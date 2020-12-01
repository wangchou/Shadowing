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
        var lastString = ""

        func say(_ text: String,
                 voiceId: String,
                 rate: Float = AVSpeechUtteranceDefaultSpeechRate, // 0.5, range 0 ~ 1.0,
                 lang: Lang = .unset,
                 ttsFixes: [(String, String)] = []
        ) -> Promise<Void> {
            stop()
            synthesizer.delegate = self
            let isJa = lang == .ja
            getFixedTTSString(text,
                              localFixes: ttsFixes,
                              isJa: isJa).then { ttsString, ttsToDisplayMap in
                self.lastString = text
                self.ttsToDisplayMap = ttsToDisplayMap
                let utterance = AVSpeechUtterance(string: ttsString)
                if let voice = AVSpeechSynthesisVoice(identifier: voiceId) {
                    utterance.voice = voice
                } else if lang != .unset { // fallback
                    utterance.voice = getDefaultVoice(language: lang.defaultCode)
                } else {
                    utterance.voice = getDefaultVoice(language: gameLang.defaultCode)
                }

                utterance.rate = rate

                print("ori:", text, utterance.voice?.identifier ?? "", rate)
                print("tts:", ttsString)
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

        // silent speak
        func preloadVoice(voiceId: String) -> Promise<Void> {
            if let voice = AVSpeechSynthesisVoice(identifier: voiceId) {
                synthesizer.delegate = self
                let utterance = AVSpeechUtterance(string: "hi")
                utterance.voice = voice
                utterance.rate = AVSpeechUtteranceMaximumSpeechRate
                utterance.volume = 0
                ttsToDisplayMap = [0, 1]
                self.synthesizer.speak(utterance)
                promise = Promise<Void>.pending()
                return promise
            }
            return fulfilledVoidPromise()
        }

        func stop() {
            if synthesizer.isSpeaking {
                synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
                promise.fulfill(())
            }
        }

        func fixRange(characterRange: NSRange, ttsToDisplayMap: [Int]) -> NSRange {
            let min = 0
            let max = ttsToDisplayMap.count
            var lowerBound = characterRange.lowerBound
            var upperBound = characterRange.upperBound
            if lowerBound < min {
                lowerBound = min
            }
            if lowerBound > max - 1 {
                lowerBound = max - 1
            }
            if upperBound < min {
                upperBound = min + 1
            }
            if upperBound > max {
                upperBound = max
            }
            if lowerBound != characterRange.lowerBound ||
                upperBound != characterRange.upperBound {
                print("Something wrong with character range: \(characterRange)")
                print("from string '\(lastString)'")
            }

            return NSRange(location: lowerBound, length: upperBound - lowerBound)
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
            let fixedRange = fixRange(characterRange: characterRange, ttsToDisplayMap: ttsToDisplayMap)
            let first = ttsToDisplayMap[fixedRange.lowerBound]
            let last = ttsToDisplayMap[fixedRange.upperBound-1]
            postEvent(.willSpeakRange, range: NSRange(location: first,
                                                     length: last - first + 1))
        }

        func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
            postEvent(.speakEnded)
            promise.fulfill(())
        }
    }
#endif
