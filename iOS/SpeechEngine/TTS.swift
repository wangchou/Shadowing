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

    // jp -> en have some chance get wrong in iOS14
    var isPreviousJa = false
    var isPreviousZh = false
    var isPreviousJaExisted = false

    var lastUtterance: AVSpeechUtterance?
    var isPaused = false
    var startTime = getNow()

    func say(_ text: String,
             voiceId: String,
             speed: Float = 1.0,
             lang: Lang,
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
            utterance.rate = speedToTTSRate(speed: speed)
            utterance.volume = 1.0
            if let voice = AVSpeechSynthesisVoice(identifier: voiceId) {
                utterance.voice = voice
                utterance.volume = self.getNormalizedVolume(voice: voice)
            } else {
                utterance.voice = getDefaultVoice(language: lang.defaultCode)
            }

//            print("ori:", text, utterance.voice?.identifier ?? "", speed, utterance.volume)
//            if ttsString != text {
//                print("tts:", ttsString)
//            }

            guard let voice = utterance.voice else {
                showNoVoicePrompt(language: lang.defaultCode)
                print("Error: utterance.voice is nil")
                self.promise.fulfill(())
                return
            }
            var synth: AVSpeechSynthesizer!
            if voice.language.contains("en"), // workaround for iOS14 tts bug
               (self.isPreviousJa || (self.isPreviousJaExisted && self.isPreviousZh)) {
                synth = AVSpeechSynthesizer()
                self.synths[voice.identifier] = synth
            } else {
                synth = self.synths[voice.identifier] ?? AVSpeechSynthesizer()
                self.synths[voice.identifier] = synth
            }
            self.lastSynth = synth

            self.lastUtterance = utterance
            self.isPaused = false
            synth.delegate = self
            synth.speak(utterance)

            // workaound for iOS 14 bug
            self.isPreviousJa = voice.language.contains("ja")
            self.isPreviousZh = voice.language.contains("zh")
            self.isPreviousJaExisted = (self.isPreviousJaExisted || self.isPreviousJa) && !voice.language.contains("en")
        }
        return promise
    }

    private func getNormalizedVolume(voice: AVSpeechSynthesisVoice) -> Float {
        if voice.identifier == "com.apple.ttsbundle.Mei-Jia-compact" {
            return 0.76
        }
        if voice.identifier == "com.apple.ttsbundle.Mei-Jia-premium" {
            return 0.85
        }
        if voice.identifier == "com.apple.ttsbundle.Sin-Ji-compact" {
            return 0.82
        }
        if voice.identifier == "com.apple.ttsbundle.Sin-Ji-premium" {
            return 0.75
        }
        if voice.language.contains("en") && voice.quality == .enhanced {
            return 0.86
        }
        if voice.language.contains("en") && voice.quality == .default {
            return 0.96
        }
        if voice.language.contains("ja") && voice.quality == .enhanced {
            return 0.86
        }
        return 1.0
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

            // iOS 14 tts bug workaround
            self.isPreviousJa = voice.language.contains("ja")
            self.isPreviousZh = voice.language.contains("zh")
            self.isPreviousJaExisted = (self.isPreviousJaExisted || self.isPreviousJa) && !voice.language.contains("en")
        }
    }

    func pause() {
        // pauseSpeaking of AVSpeechSynthesizer causes "japanese didFinish not be called" bug
        // so try to stop and speak whole utterance later
        isPaused = true
        lastSynth?.stopSpeaking(at: .word)
    }

    func continueSpeaking() {
        if isPaused, let utterance = lastUtterance {
            lastSynth?.speak(utterance)
        }
        isPaused = false
    }

    func stop() {
        isPaused = false
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
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        postEvent(.sayStarted, string: lastString)
    }

    func speechSynthesizer(_ synth: AVSpeechSynthesizer,
                           willSpeakRangeOfSpeechString characterRange: NSRange,
                           utterance: AVSpeechUtterance) {
        if utterance.speechString == lastTTSString {
            let fixedRange = fixRange(characterRange: characterRange, ttsToDisplayMap: ttsToDisplayMap)
            let first = ttsToDisplayMap[fixedRange.lowerBound]
            let last = ttsToDisplayMap[fixedRange.upperBound - 1]
            postEvent(.willSpeakRange, range: NSRange(location: first,
                                                      length: last - first + 1))
//            guard let rangeInString = Range(characterRange, in: utterance.speechString) else { return }
//            print("Will speak: \(utterance.speechString[rangeInString])", synth.isSpeaking)
        }
    }

    func speechSynthesizer(_: AVSpeechSynthesizer,
                           didFinish utterance: AVSpeechUtterance) {
        // not sure why, but the delegate is called by other strings anyway. (bug? for iOS14 en only)
        if utterance.speechString == lastTTSString {
            postEvent(.speakEnded, string: utterance.speechString + " did said")
            promise.fulfill(())
            lastUtterance = nil
        }
    }

    func speechSynthesizer(_: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        if utterance.speechString == lastTTSString {
            // for cancel not due to "pause by cancel utterance -> continue" action
            if !isPaused {
                postEvent(.speakEnded, string: utterance.speechString + " cancelled")
                promise.fulfill(())
                lastUtterance = nil
            }
        }
    }
}
