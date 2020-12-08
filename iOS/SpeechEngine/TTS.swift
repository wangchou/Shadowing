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

// input/displayed: 1日○○○○
// after fix, we let tts say いちにち○○○○
// ttsToDisplayMap will map willSpeakRange from いちにち○○○○ to 1日○○○○
// it looks like [1 1 1 1 2 3 4 5]
class TTS: NSObject {
    var synths: [String: AVSpeechSynthesizer] = [:]
    var lastSynth: AVSpeechSynthesizer?
    var ttsToDisplayMap: [Int] = []
    var promise = fulfilledVoidPromise()
    var lastString = ""
    var lastTTSString = ""
    var isPreviousJP = false // jp -> en have some chance get wrong in iOS14

    func say(_ text: String,
             voiceId: String,
             rate: Float = AVSpeechUtteranceDefaultSpeechRate, // 0.5, range 0 ~ 1.0,
             lang: Lang = .unset,
             ttsFixes: [(String, String)] = []) -> Promise<Void> {
        stop()
        let isJa = lang == .ja
        promise = Promise<Void>.pending()
        getFixedTTSString(
            text,
            localFixes: ttsFixes,
            isJa: isJa
        ).then { [weak self] ttsString, ttsToDisplayMap in
            guard let self = self else { return }

            // for text highlight
            self.lastString = text
            self.lastTTSString = ttsString
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

//            print("ori:", text, utterance.voice?.identifier ?? "", rate)
//            if ttsString != text {
//                print("tts:", ttsString)
//            }
            
            if isHeadphonePlugged() {
                utterance.volume = 0.6
            } else {
                utterance.volume = 1.0
            }

            postEvent(.sayStarted, string: text)
            guard let voice = utterance.voice else {
                print("Error: utterance.voice is nil")
                self.promise.fulfill(())
                return
            }
            var synth: AVSpeechSynthesizer!
            if self.isPreviousJP, voice.language.contains("en") { // for iOS14 tts bug
                synth = AVSpeechSynthesizer()
                self.synths[voice.identifier] = synth
            } else {
                synth = self.synths[voice.identifier] ?? AVSpeechSynthesizer()
                self.synths[voice.identifier] = synth
            }
            self.lastSynth = synth
            synth.delegate = self
            synth.speak(utterance)
            self.isPreviousJP = voice.language.contains("ja")
        }
        return promise
    }

    // silent speak
    func preloadVoice(voiceId: String) {
        if let voice = AVSpeechSynthesisVoice(identifier: voiceId) {
            let utterance = AVSpeechUtterance(string: "hi")
            utterance.voice = voice
            utterance.rate = AVSpeechUtteranceMaximumSpeechRate
            utterance.volume = 0
            let synth = synths[voiceId] ?? AVSpeechSynthesizer()
            synths[voiceId] = synth
            synth.speak(utterance)
        }
    }

    func stop() {
        lastSynth?.stopSpeaking(at: AVSpeechBoundary.immediate)
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
                           didFinish utterance: AVSpeechUtterance) {
        // not sure why, but the delegate is called by other strings anyway. (bug? for iOS14 en only)
        if utterance.speechString == lastTTSString {
            postEvent(.speakEnded, string: utterance.speechString + " did said")
            promise.fulfill(())
        }
    }

    func speechSynthesizer(_: AVSpeechSynthesizer,
                           willSpeakRangeOfSpeechString characterRange: NSRange,
                           utterance: AVSpeechUtterance) {
        if utterance.speechString == lastTTSString {
            let fixedRange = fixRange(characterRange: characterRange, ttsToDisplayMap: ttsToDisplayMap)
            let first = ttsToDisplayMap[fixedRange.lowerBound]
            let last = ttsToDisplayMap[fixedRange.upperBound - 1]
            postEvent(.willSpeakRange, range: NSRange(location: first,
                                                      length: last - first + 1))
        }
    }

    func speechSynthesizer(_: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        if utterance.speechString == lastTTSString {
            postEvent(.speakEnded, string: utterance.speechString + " cancelled")
            promise.fulfill(())
        }
    }
}

