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

func teacherSay(_ text: String) -> Promise<Void> {
    return engine.speak(text: text, speaker: context.gameSetting.teacher)
}

class SpeechEngine {
    // Singleton
    static let shared = SpeechEngine()

    var isEngineRunning = false
    var audioEngine = AVAudioEngine()

    private var micVolumeNode = AVAudioMixerNode()
    private var speechRecognizer = SpeechRecognizer()
    private var bgm = BGM()
    private var tts = TTS()

    // MARK: - Lifecycle
    private init() {
        guard !isSimulator else { return }
        configureAudioSession()
        buildNodeGraph()
        audioEngine.prepare()
        setupNotifications()
    }

    // MARK: - Public Funtions
    func start() {
        isEngineRunning = true

        guard !isSimulator else { return }

        do {
            configureAudioSession()
            try audioEngine.start()
            // engine.bgm.play()
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
        audioEngine.stop()
    }

    func speak(text: String, speaker: ChatSpeaker? = nil, rate: Float = context.teachingRate) -> Promise<Void> {
        let startTime = getNow()
        var speakPromise: Promise<Void>
        func updateSpeakDuration() -> Promise<Void> {
            context.speakDuration = Float((getNow() - startTime))
            return fulfilledVoidPromise()
        }

        if let speaker = speaker {
            switch speaker {
            case .hattori, .otoya, .kyoko, .oren, .meijia, .system:
                speakPromise = tts.say(
                    text,
                    name: speaker.rawValue,
                    rate: rate
                )
            case .user:
                speakPromise = fulfilledVoidPromise()
            }
        } else {
            speakPromise = tts.say(text, rate: rate)
        }

        return speakPromise.then(updateSpeakDuration)
    }

    // MARK: - Voice Recognition
    func listen(duration: Double, langCode: String? = nil) -> Promise<String> {
        let langCode = langCode ?? context.targetString.langCode ?? "ja"
        return speechRecognizer.start(stopAfterSeconds: duration, localIdentifier: langCode)
    }

    func stopListen() {
        speechRecognizer.endAudio()
    }

    private func buildNodeGraph() {
        let mainMixer = audioEngine.mainMixerNode
        let mic = audioEngine.inputNode // only for real device, simulator will crash

        audioEngine.attach(bgm.node)
        audioEngine.attach(micVolumeNode)

        audioEngine.connect(bgm.node, to: mainMixer, format: bgm.buffer.format)
        audioEngine.connect(mic, to: micVolumeNode, format: mic.inputFormat(forBus: 0))
        audioEngine.connect(micVolumeNode, to: mainMixer, format: micVolumeNode.outputFormat(forBus: 0))

        micVolumeNode.volume = micOutVolume
        bgm.node.volume = 0.5
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
        case .newDeviceAvailable:
            print("new device available")
            self.stop()
            self.start()
        case .oldDeviceUnavailable:
            print("old device unavailable")
            self.stop()
            self.start()
        default: ()
        }
    }

}
