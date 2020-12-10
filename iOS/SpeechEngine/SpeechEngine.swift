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

    private var speechRecognizer = SpeechRecognizer.shared

    private var tts = TTS()

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
            print("engine start running")
        } catch {
            print("Start Play through failed \(error)")
        }
    }

    // elimiated delay
    func preloadTTSVoice() {
        tts.preloadVoice(voiceId: context.gameSetting.teacher)
        tts.preloadVoice(voiceId: context.gameSetting.assistant)
    }

    func pause() {
        tts.pause()
    }

    func continueSpeaking() {
        tts.continueSpeaking()
    }

    func restart() {
        stop()
        start()
    }

    func listen(duration: Double, originalStr: String? = nil) -> Promise<[String]> {
        return speechRecognizer.authorize().then { _ -> Promise<[String]> in
            self.speechRecognizer.listen(stopAfterSeconds: duration, originalStr: originalStr)
        }
    }

    func stopListeningAndSpeaking() {
        speechRecognizer.endAudio()
        tts.stop()
    }

    func monitoringOn() {
        guard isHeadphonePlugged() else { return }
        audioEngine.mainMixerNode.outputVolume = pow(2, Float(context.gameSetting.monitoringVolume) / 10 + 1.0)
    }

    func monitoringOff() {
        audioEngine.mainMixerNode.outputVolume = 0
    }

    func stop(isStopTTS: Bool = true) {
        guard audioEngine.isRunning || isEngineRunning else { return }

        if isStopTTS {
            tts.stop()
        }

        guard !isSimulator else { return }
        speechRecognizer.endAudio(isCanceling: true)
        audioEngine.stop()
        isEngineRunning = false
        print("engine stopped")
    }

    // MARK: - Private

    private func buildNodeGraph() {
        isInstallTapSuceeced = false
        let mainMixer = audioEngine.mainMixerNode
        let mic = audioEngine.inputNode // only for real device, simulator will crash

        #if !targetEnvironment(macCatalyst)
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

                let inputCallback: AVAudioConverterInputBlock = { _, outStatus in
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
        case .newDeviceAvailable, .oldDeviceUnavailable, .override:
            print("route change notification:", reason.rawValue)
            if isEngineRunning {
                restart()
            }
        default: ()
            print("unhandle route change notification:",
                  reason.rawValue,
                  AVAudioSession.sharedInstance().category)
        }
    }
}

// MARK: - Wrappers of engine.speak

// narratorSay      speak intitial instructions
// translatorSay    speak translation
// teacherSay       speak the text for repeating
// assisantSay      speak correct, good, wrong...
// ttsSay           speak sample text in voiceSelection Page

private extension SpeechEngine {
    func speak(text: String,
               speaker: String,
               speed: Float,
               lang: Lang,
               ttsFixes: [(String, String)] = []) -> Promise<Void> {
        return tts.say(
            text,
            voiceId: speaker,
            speed: speed,
            lang: lang,
            ttsFixes: ttsFixes
        )
    }
}

func speakTitle() -> Promise<Void> {
    context.gameState = .speakTitle
    let title = context.gameTitleToSpeak
    if context.gameMode == .topicMode {
        let voiceId = context.gameSetting.translatorZh
        return engine.speak(text: title, speaker: voiceId, speed: normalSpeed, lang: .zh)
    }

    return narratorSay(title)
}

func narratorSay(_ text: String) -> Promise<Void> {
    return engine.speak(text: text,
                        speaker: context.gameSetting.narrator,
                        speed: context.assistantSpeed,
                        lang: i18n.lang)
}

func translatorSay(_ text: String) -> Promise<Void> {
    var voiceId = context.gameSetting.translator

    if AVSpeechSynthesisVoice(identifier: voiceId) == nil {
        switch context.gameSetting.translationLang {
        case .ja:
            voiceId = VoiceDefaults.translatorJa
        case .en:
            voiceId = VoiceDefaults.translatorEn
        case .zh:
            voiceId = VoiceDefaults.translatorZh
        default:
            print("\(context.gameSetting.translationLang.key) should not be translation lang")
            voiceId = "unknown"
        }
    }

    return engine.speak(text: text,
                        speaker: voiceId,
                        speed: context.translatorSpeed,
                        lang: context.gameSetting.translationLang)
}

func topicTranslatorSay(_ text: String) -> Promise<Void> {
    return engine.speak(text: text,
                        speaker: context.gameSetting.translatorZh,
                        speed: context.translatorSpeed,
                        lang: .zh)
}

func assisantSay(_ text: String) -> Promise<Void> {
    return engine.speak(text: text,
                        speaker: context.gameSetting.assistant,
                        speed: context.assistantSpeed,
                        lang: gameLang)
}

func teacherSay(_ text: String, speed: Float = context.teachingSpeed, ttsFixes: [(String, String)]) -> Promise<Void> {
    return engine.speak(text: text,
                        speaker: context.gameSetting.teacher,
                        speed: speed,
                        lang: gameLang,
                        ttsFixes: ttsFixes)
}

// only for voice selection page
func ttsSay(_ text: String, speaker: String, speed: Float = context.teachingSpeed, lang: Lang) -> Promise<Void> {
    return engine.speak(text: text, speaker: speaker, speed: speed, lang: lang)
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
