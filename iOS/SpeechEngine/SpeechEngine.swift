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
    static let shared = SpeechEngine()

    var isEngineRunning = false
    var isInstallTapSuceeced = false

    private var audioEngine = AVAudioEngine()
    private var isMonitoring: Bool = false
    private var monitoringVolume: Float = 0

    private var speechRecognizer = SpeechRecognizer()
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

    func say(_ text: String, voiceId: String, speed: Float, lang: Lang, ttsString: String? = nil, ttsToDisplayMap: [Int]? = nil) -> Promise<Void> {
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

    private init() {
        guard !isSimulator else { return }
        setupNotifications()
    }

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

    // MARK: - Audio Session

    private func configureAudioSession(isAskingPermission: Bool = true) {
        let session = AVAudioSession.sharedInstance()

        do {
            try session.setCategory(
                AVAudioSession.Category.playAndRecord,
                mode: AVAudioSession.Mode.default,
                // if set both allowBluetooth and allowBluetoothA2DP here will
                // cause installTap callback not be calling. Not sure why
                options: [
                    .mixWithOthers, .allowBluetoothA2DP, .allowAirPlay, .defaultToSpeaker, .allowBluetooth,
                ]
            )

            // turn the measure mode will crash bluetooh, duckOthers and mixWithOthers
            // try session.setMode(AVAudioSessionModeMeasurement)

            // per ioBufferDuration delay, for live monitoring
            // default  23ms | 1024 frames | <1% CPU (iphone SE)
            // 0.001   0.7ms |   32 frames |  8% CPU
            // 0.008   5.6ms |  256 frames |  1% CPU

            // Important Warning
            // if bufferDuration is too low (0.004) => dyanmic installTap failure on default mic (iPhone 8 and later)
            // if bufferDuration is too high (0.04) => tts be muted through bluetooth

            try session.setPreferredIOBufferDuration(0.008)
            try session.setActive(true)
        } catch {
            print("configuare audio session with \(error)")
        }

        guard isAskingPermission else { return }

        session.requestRecordPermission { success in
            if success {
                print("Record Permission Granted")
            } else {
                print("Record Permission fail")
                showGoToPermissionSettingAlert()
            }
        }
    }

    // MARK: - Handle Route Change

    private func setupNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleRouteChange),
                                               name: AVAudioSession.routeChangeNotification,
                                               object: AVAudioSession.sharedInstance())
    }

    @objc private func handleRouteChange(_ notification: Notification) {
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
}
