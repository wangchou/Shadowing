//
//  GameEngine.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 8/27/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import AVFoundation
import Foundation
import Promises
import Speech

private let context = GameContext.shared
private let engine = SpeechEngine.shared

// MARK: - SpeechEngine

// A wrapper of AVAudioEngine, SpeechRecognizer and TTS
class SpeechEngine {
    // Singleton
    static let shared = SpeechEngine()

    var isEngineRunning = false
    var isInstallTapSuceeced = false
    var audioEngine = AVAudioEngine()
    private var audioPlayer: AVAudioPlayer?

    private var speechRecognizer = SpeechRecognizer.shared

    // two tts for preventing fullfill previous promise
//    private var tts: TTS {
//        switch currentTTSIdx % 3 {
//        case 1:
//            return tts1
//        case 2:
//            return tts2
//        default:
//            return tts0
//        }
//    }

    private var currentTTSIdx = 0
    private var tts0 = TTS() // teacher
    private var tts1 = TTS() // assistant
    private var tts2 = TTS() // translator
    private var tts3 = TTS() // narrator

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

    // elimiated delay
    func preloadTTSVoice() {
        _ = tts0.slientSay(voiceId: context.gameSetting.teacher)
        _ = tts1.slientSay(voiceId: context.gameSetting.assistant)
    }

    func restart() {
        stop()
        start()
    }

    func listen(duration: Double) -> Promise<String> {
        return speechRecognizer.listen(stopAfterSeconds: duration)
    }

    func stopListeningAndSpeaking() {
        speechRecognizer.endAudio()
        if tts0.synthesizer.isSpeaking {
            tts0.stop()
        }
        if tts1.synthesizer.isSpeaking {
            tts1.stop()
        }
        if tts2.synthesizer.isSpeaking {
            tts2.stop()
        }
        if tts3.synthesizer.isSpeaking {
            tts3.stop()
        }
    }

    func monitoringOn() {
        guard isHeadphonePlugged() else { return }
        audioEngine.mainMixerNode.outputVolume = pow(2, Float(context.gameSetting.monitoringVolume)/10 + 1.0)
    }

    func monitoringOff() {
        audioEngine.mainMixerNode.outputVolume = 0
    }

    func stop(isStopTTS: Bool = true) {
        guard isEngineRunning else { return }

        if isStopTTS {
            tts0.stop()
            tts1.stop()
            tts2.stop()
            tts3.stop()
        }

        guard !isSimulator else { return }
        speechRecognizer.endAudio(isCanceling: true)
        audioEngine.stop()
        isEngineRunning = false
    }

    // MARK: - Private
    private func buildNodeGraph() {
        isInstallTapSuceeced = false
        let mainMixer = audioEngine.mainMixerNode
        let mic = audioEngine.inputNode // only for real device, simulator will crash

        #if !(targetEnvironment(macCatalyst))
        mic.removeTap(onBus: 0)
        mic.installTap(onBus: 0, bufferSize: 1024, format: nil) { [weak self] buffer, _ in
            guard let self = self,
                  let recognitionRequest = self.speechRecognizer.recognitionRequest else { return }
            self.isInstallTapSuceeced = true
            recognitionRequest.append(buffer)
            calculateMicLevel(buffer: buffer)
        }

        audioEngine.connect(mic, to: mainMixer, format: nil)
        mainMixer.outputVolume = 0
        #else
        // mac catalyst
        // not knowing why... but need to convert to the same format in catalyst to
        // make wired mic work...
        // for built-in mic work need to force channel = 2
        // ps: my sony wireless mic is always working
        // tested in macOS 11.0.1, xcode 12.2
        let inputFormat = mic.outputFormat(forBus: 0)
        print(inputFormat)
        let outputFormat = AVAudioFormat(commonFormat: inputFormat.commonFormat,
                                        sampleRate: inputFormat.sampleRate,
                                        channels: 2, // 1 or built-in 4 not working?
                                        interleaved: inputFormat.isInterleaved)!
        let converter = AVAudioConverter(from: inputFormat, to: outputFormat)!

        mic.removeTap(onBus: 0)
        mic.installTap(onBus: 0, bufferSize: 1024, format: inputFormat) { [weak self] buffer, _ in
            guard let self = self,
                  let recognitionRequest = self.speechRecognizer.recognitionRequest else { return }

            self.isInstallTapSuceeced = true

            let inputCallback: AVAudioConverterInputBlock = { inNumPackets, outStatus in
                outStatus.pointee = AVAudioConverterInputStatus.haveData
                return buffer
            }

            let convertedBuffer = AVAudioPCMBuffer(pcmFormat: outputFormat,
                                                  frameCapacity: buffer.frameCapacity)!

            var error: NSError?
            _ = converter.convert(to: convertedBuffer, error: &error, withInputFrom: inputCallback)

            if let error = error { print(error) }

            recognitionRequest.append(convertedBuffer)
            calculateMicLevel(buffer: convertedBuffer)
        }
        #endif
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
                restart()
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
    fileprivate func speak(text: String,
                           speaker: String,
                           rate: Float,
                           lang: Lang,
                           ttsFixes: [(String, String)] = []) -> Promise<Void> {
        let startTime = getNow()
        func updateSpeakDuration() -> Promise<Void> {
            context.speakDuration = Float(getNow() - startTime)
            return fulfilledVoidPromise()
        }
        currentTTSIdx += 1

        let tts: TTS!
        switch speaker {
        case context.gameSetting.teacher:
            tts = tts0
        case context.gameSetting.assistant:
            tts = tts1
        case context.gameSetting.translator:
            tts = tts2
        case context.gameSetting.narrator:
            tts = tts3
        default:
            tts = tts3
        }
        return tts.say(
            text,
            voiceId: speaker,
            rate: rate,
            lang: lang,
            ttsFixes: ttsFixes
        ).then(updateSpeakDuration)
    }
}

func speakTitle() -> Promise<Void> {
    let title = context.gameTitleToSpeak
    if context.gameMode == .topicMode {
        let voiceId = context.gameSetting.translatorZh
        return engine.speak(text: title, speaker: voiceId, rate: normalRate, lang: .zh)
    }

    return narratorSay(title)
}

func narratorSay(_ text: String) -> Promise<Void> {
    return engine.speak(text: text,
                        speaker: context.gameSetting.narrator,
                        rate: context.assistantRate,
                        lang: i18n.lang)
}

func translatorSay(_ text: String) -> Promise<Void> {
    var voiceId = context.gameSetting.translator

    if AVSpeechSynthesisVoice(identifier: voiceId) == nil {
        switch context.gameSetting.translationLang {
        case .ja:
            voiceId = getDefaultVoiceId(language: Lang.ja.defaultCode)
        case .en:
            voiceId = getDefaultVoiceId(language: Lang.en.defaultCode)
        case .zh:
            voiceId = getDefaultVoiceId(language: Lang.zh.defaultCode, isPreferEnhanced: false)
        default:
            print("\(context.gameSetting.translationLang.key) should not be translation lang")
            voiceId = "unknown"
        }
    }

    print("translator:", voiceId, text)
    return engine.speak(text: text,
                        speaker: voiceId,
                        rate: context.translatorNormalRate,
                        lang: context.gameSetting.translationLang)
}

func assisantSay(_ text: String) -> Promise<Void> {
    return engine.speak(text: text,
                        speaker: context.gameSetting.assistant,
                        rate: context.assistantRate,
                        lang: gameLang)
}

func teacherSay(_ text: String, rate: Float = context.teachingRate, ttsFixes: [(String, String)]) -> Promise<Void> {
    return engine.speak(text: text,
                        speaker: context.gameSetting.teacher,
                        rate: rate,
                        lang: gameLang,
                        ttsFixes: ttsFixes)
}

// only for voice selection page
func ttsSay(_ text: String, speaker: String, rate: Float = context.teachingRate, lang: Lang) -> Promise<Void> {
    return engine.speak(text: text, speaker: speaker, rate: rate, lang: lang)
}

// MARK: - Utilities

func isHeadphonePlugged() -> Bool {
    let currentRoute = AVAudioSession.sharedInstance().currentRoute
    for description in currentRoute.outputs {
        if description.portType == AVAudioSession.Port.headphones ||
            description.portType == AVAudioSession.Port.lineOut {
            return true
        }
    }
    return false
}

func isBluetooth() -> Bool {
    let currentRoute = AVAudioSession.sharedInstance().currentRoute
    for description in currentRoute.outputs {
        if description.portType == AVAudioSession.Port.bluetoothA2DP ||
           description.portType == AVAudioSession.Port.bluetoothLE ||
           description.portType == AVAudioSession.Port.bluetoothHFP {
            return true
        }
    }
    return false
}
