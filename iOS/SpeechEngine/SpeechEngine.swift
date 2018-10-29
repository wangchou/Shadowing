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

func narratorSay(_ text: String) -> Promise<Void> {
    return engine.speak(text: text, speaker: context.gameSetting.narrator, rate: fastRate)
}

func assisantSay(_ text: String) -> Promise<Void> {
    return engine.speak(text: text, speaker: context.gameSetting.assisant, rate: normalRate)
}

func teacherSay(_ text: String, rate: Float = context.teachingRate) -> Promise<Void> {
    return engine.speak(text: text, speaker: context.gameSetting.teacher, rate: rate)
}

class SpeechEngine {
    // Singleton
    static let shared = SpeechEngine()

    var isEngineRunning = false
    var audioEngine = AVAudioEngine()

    private var micVolumeNode = AVAudioMixerNode()
    private var speechRecognizer = SpeechRecognizer()
    private var tts = TTS()

    // MARK: - Lifecycle
    private init() {
        guard !isSimulator else { return }
        setupNotifications()
    }

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

    func stop() {
        guard isEngineRunning else { return }
        isEngineRunning = false
        tts.stop()

        guard !isSimulator else { return }
        speechRecognizer.stop()
        closeNodeGraph()
    }

    func listen(duration: Double) -> Promise<String> {
        return speechRecognizer.listen(stopAfterSeconds: duration)
    }

    func reset() {
        stopListen()
        tts.stop()
    }
}

// MARK: - Private
extension SpeechEngine {
    private func stopListen() {
        speechRecognizer.endAudio()
    }

    fileprivate func speak(text: String, speaker: ChatSpeaker, rate: Float) -> Promise<Void> {
        let startTime = getNow()
        func updateSpeakDuration() -> Promise<Void> {
            context.speakDuration = Float((getNow() - startTime))
            return fulfilledVoidPromise()
        }

        return tts.say(
            text,
            name: speaker.rawValue,
            rate: rate
            ).then(updateSpeakDuration)
    }

    private func buildNodeGraph() {
        let mainMixer = audioEngine.mainMixerNode
        let mic = audioEngine.inputNode // only for real device, simulator will crash

        audioEngine.attach(micVolumeNode)

        audioEngine.connect(mic, to: micVolumeNode, format: mic.inputFormat(forBus: 0))
        audioEngine.connect(micVolumeNode, to: mainMixer, format: micVolumeNode.outputFormat(forBus: 0))

        micVolumeNode.volume = 0
    }

    private func closeNodeGraph() {
        guard audioEngine.isRunning else { return }
        audioEngine.stop()
        audioEngine.detach(micVolumeNode)
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
            if self.isEngineRunning {
                self.stop()
                self.start()
            }
        default: ()
            print("unhandle route change notification:", reason.rawValue)
        }

    }

}
