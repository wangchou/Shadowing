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

// MARK: - SpeechEngine

// A wrapper of AVAudioEngine, SpeechRecognizer and TTS
class SpeechEngine {
    // Singleton
    static let shared = SpeechEngine()

    var isEngineRunning = false
    var isInstallTapSuceeced = false
    var audioEngine = AVAudioEngine()
    var isMonitoring: Bool = false
    var monitoringVolume: Float = 0

    private var speechRecognizer = SpeechRecognizer.shared

    private var tts = TTS()

    private let eq = AVAudioUnitEQ()

    // MARK: - Public Funtions

    func start(isMonitoring: Bool? = nil, monitoringVolume: Float? = nil) {
        guard !isEngineRunning else { return }
        isEngineRunning = true
        self.isMonitoring = isMonitoring ?? self.isMonitoring
        self.monitoringVolume = monitoringVolume ?? self.monitoringVolume
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
    func preloadTTSVoice(voiceIds: [String]) {
        voiceIds.forEach {
            tts.preloadVoice(voiceId: $0)
        }
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

    func listen(duration: Double, localeId: String, originalStr: String? = nil ) -> Promise<[String]> {
        return speechRecognizer.authorize().then {
            self.speechRecognizer.listen(
                stopAfterSeconds: duration,
                localeId: localeId,
                originalStr: originalStr
            )
        }
    }

    func say(_ text: String, voiceId: String, speed: Float, lang: Lang, ttsString: String, ttsToDisplayMap: [Int]) -> Promise<Void> {
        return tts.say(text, voiceId: voiceId, speed: speed, lang: lang, ttsString: ttsString, ttsToDisplayMap: ttsToDisplayMap)
    }

    func stopListeningAndSpeaking() {
        speechRecognizer.endAudio()
        tts.stop()
    }

    func stop(isStopTTS: Bool = true) {
        guard audioEngine.isRunning || isEngineRunning else { return }

        if isStopTTS {
            tts.stop()
        }

        guard !isSimulator else { return }
        speechRecognizer.endAudio(isCanceling: true)
        audioEngine.reset()
        audioEngine.stop()
        isEngineRunning = false
        print("engine stopped")
    }

    // MARK: - Private

    private func buildNodeGraph() {
        isInstallTapSuceeced = false
        let mic = audioEngine.inputNode // only for real device, simulator will crash
        let micFormat = mic.inputFormat(forBus: 0)

        #if !targetEnvironment(macCatalyst)
            mic.removeTap(onBus: 0)
            mic.installTap(onBus: 0, bufferSize: 1024, format: micFormat) { [weak self] buffer, _ in
                guard let self = self,
                      let recognitionRequest = self.speechRecognizer.recognitionRequest else { return }
                self.isInstallTapSuceeced = true
                recognitionRequest.append(buffer)
                calculateMicLevel(buffer: buffer)
            }

            if isHeadphonePlugged() && isMonitoring {
                if #available(iOS 13, *) {
                    mic.isVoiceProcessingAGCEnabled = false
                }
                audioEngine.attach(eq)
                eq.globalGain = monitoringVolume
                audioEngine.connect(mic, to: eq, format: micFormat)
                audioEngine.connect(eq, to: audioEngine.mainMixerNode, format: micFormat)
            } else {
                if #available(iOS 13, *) {
                    mic.isVoiceProcessingAGCEnabled = true
                }
                audioEngine.disconnectNodeInput(audioEngine.mainMixerNode)
            }
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
