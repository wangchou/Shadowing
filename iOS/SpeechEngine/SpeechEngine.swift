//
//  GameEngine.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 8/27/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation
import AVFoundation
import Speech
import Promises

private let context = GameContext.shared
private let engine = SpeechEngine.shared

// MARK: - SpeechEngine
// A wrapper of AVAudioEngine, SpeechRecognizer and TTS
class SpeechEngine {
    // Singleton
    static let shared = SpeechEngine()

    var isEngineRunning = false
    var audioEngine = AVAudioEngine()
    private var audioPlayer: AVAudioPlayer?

    private var speechRecognizer = SpeechRecognizer.shared

    // two tts for preventing fullfill previous promise
    private var tts: TTS {
        return currentTTSIdx % 2 == 0 ? tts1 : tts2
    }

    private var currentTTSIdx = 0
    private var tts1 = TTS()
    private var tts2 = TTS()

    // MARK: - Public Funtions
    func start() {
        guard !isEngineRunning else { return }
        isEngineRunning = true
        guard !isSimulator else { return }
        do {
            configureAudioSession()
            buildNodeGraph()
            audioEngine.prepare()
            try audioEngine.start()
        } catch {
            print("Start Play through failed \(error)")
        }
    }

    func listen(duration: Double) -> Promise<String> {
        return speechRecognizer.listen(stopAfterSeconds: duration)
    }

    func stopListeningAndSpeaking() {
        speechRecognizer.endAudio()
        if tts1.synthesizer.isSpeaking {
            tts1.stop()
        }
        if tts2.synthesizer.isSpeaking {
            tts2.stop()
        }
    }

    func monitoringOn() {
        guard isHeadphonePlugged() else { return }
        audioEngine.mainMixerNode.outputVolume = 1
    }

    func monitoringOff() {
        audioEngine.mainMixerNode.outputVolume = 0
    }

    // MARK: - Private
    private func stop() {
        guard isEngineRunning else { return }
        isEngineRunning = false
        tts.stop()

        guard !isSimulator else { return }
        speechRecognizer.endAudio(isCanceling: true)
        closeNodeGraph()
    }

    private func buildNodeGraph() {
        let mainMixer = audioEngine.mainMixerNode
        let mic = audioEngine.inputNode // only for real device, simulator will crash
        audioEngine.connect(mic, to: mainMixer, format: nil)

        mainMixer.outputVolume = 0
    }

    private func closeNodeGraph() {
        guard audioEngine.isRunning else { return }
        audioEngine.stop()
    }

    // MARK: - Handle Route Change
    private init() {
        guard !isSimulator else { return }
        setupNotifications()
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleRouteChange),
                                               name: AVAudioSession.routeChangeNotification,
                                               object: AVAudioSession.sharedInstance())
    }

    @objc func handleRouteChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
                return
        }
        switch reason {
        case .newDeviceAvailable, .oldDeviceUnavailable, .override, .categoryChange:
            print("route change notification:", reason.rawValue)
            if isEngineRunning {
                stop()
                start()
            }
        default: ()
            print("unhandle route change notification:", reason.rawValue)
        }
    }
}

// MARK: - Wrappers of engine.speak
// narratorSay      speak intitial instructions
// translatorSay    speak translation
// teacherSay       speak the text for repeating
// assisantSay      speak correct, good, wrong...
// ttsSay           speak sample text in voiceSelection Page

extension SpeechEngine {
    fileprivate func speak(text: String, speaker: String, rate: Float) -> Promise<Void> {
        let startTime = getNow()
        func updateSpeakDuration() -> Promise<Void> {
            context.speakDuration = Float((getNow() - startTime))
            return fulfilledVoidPromise()
        }
        currentTTSIdx += 1
        return tts.say(
            text,
            voiceId: speaker,
            rate: rate
            ).then(updateSpeakDuration)
    }
}

func speakTitle() -> Promise<Void> {
    let title = context.gameTitleToSpeak
    if context.gameMode == .topicMode {
        let voiceId = getDefaultVoiceId(language: "zh-TW")
        return engine.speak(text: title, speaker: voiceId, rate: normalRate)
    }

    if (gameLang == .jp && i18n.isJa) ||
       (gameLang == .en && !(i18n.isZh || i18n.isJa)) {
        return teacherSay(title, rate: normalRate)
    }
    return narratorSay(title)
}

func narratorSay(_ text: String) -> Promise<Void> {
    let currentLocale = AVSpeechSynthesisVoice.currentLanguageCode()
    var voiceId = "unknown"
    var rate = normalRate
    if currentLocale.hasPrefix("ja") {
        voiceId = getDefaultVoiceId(language: "ja-JP")
    } else if currentLocale.hasPrefix("zh") {
        voiceId = getDefaultVoiceId(language: "zh-TW", isPreferEnhanced: false)
        rate = fastRate
    } else if currentLocale.hasPrefix("en") {
        voiceId = getDefaultVoiceId(language: currentLocale)
    } else {
        voiceId = getDefaultVoiceId(language: "en-US")
    }
    //print("narrator", voiceId)
    return engine.speak(text: text, speaker: voiceId, rate: rate)
}

func translatorSay(_ text: String) -> Promise<Void> {
    var translationLocale = "en-US"
    if gameLang == .jp && context.gameMode == .topicMode {
        translationLocale = "zh-TW"
    }
    if gameLang == .en {
        translationLocale = "ja-JP"
    }
    var voiceId = "unknown"
    var rate = normalRate
    if translationLocale.hasPrefix("zh") {
        voiceId = getDefaultVoiceId(language: "zh-TW", isPreferEnhanced: false)
        rate = fastRate
    } else {
        voiceId = getDefaultVoiceId(language: translationLocale)
    }
    print("translator:", voiceId, text, rate)
    return engine.speak(text: text, speaker: voiceId, rate: rate)
}

func assisantSay(_ text: String) -> Promise<Void> {
    return engine.speak(text: text, speaker: context.gameSetting.assisant, rate: normalRate)
}

func teacherSay(_ text: String, rate: Float = context.teachingRate) -> Promise<Void> {
    return engine.speak(text: text, speaker: context.gameSetting.teacher, rate: rate)
}

func ttsSay(_ text: String, speaker: String, rate: Float = context.teachingRate) -> Promise<Void> {
    return engine.speak(text: text, speaker: speaker, rate: rate)
}

// MARK: - Utilities
private func isHeadphonePlugged() -> Bool {
    let currentRoute = AVAudioSession.sharedInstance().currentRoute
    for description in currentRoute.outputs {
        if description.portType == AVAudioSession.Port.headphones ||
            description.portType == AVAudioSession.Port.lineOut {
            return true
        }
    }
    return false
}
