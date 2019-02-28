//
//  SpeechRecognizer.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/04/16.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import Speech
import Promises

private let context = GameContext.shared
private let engine = SpeechEngine.shared
private let minDb: Float = -60

enum SpeechRecognitionError: Error {
    case unauthorized
    case engineStopped
}

class SpeechRecognizer: NSObject {
    private let speechRecognizerJP: SFSpeechRecognizer! = SFSpeechRecognizer(locale: Locale(identifier: "ja_JP"))
    private let speechRecognizerEN: SFSpeechRecognizer! = SFSpeechRecognizer(locale: Locale(identifier: "en_US"))

    private var speechRecognizer: SFSpeechRecognizer {
        switch gameLang {
        case .jp:
            return speechRecognizerJP
        default:
            if  let voice = AVSpeechSynthesisVoice(identifier: context.gameSetting.teacher),
                let recognizer = SFSpeechRecognizer(locale: Locale(identifier: voice.language.replace("-", "_"))) {
                return recognizer
            }
            return speechRecognizerEN
        }
    }
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var isRunning: Bool = false
    private var isAuthorized: Bool = false
    private var inputNode: AVAudioNode!
    private var promise = Promise<String>.pending()

    override init() {
        super.init()
        if !isSimulator {
            authorize()
        }
    }

    // MARK: - Public Methods
    func listen(stopAfterSeconds: Double = 5) -> Promise<String> {
        endAudio()
        promise = Promise<String>.pending()
        // mocked start for simulator
        guard !isSimulator else {
            return startFaked(stopAfterSeconds: stopAfterSeconds)
        }

        guard engine.isEngineRunning else {
            promise.fulfill("Error: SpeechEninge is not started")
            return promise
        }

        if !isAuthorized {
            promise.reject(SpeechRecognitionError.unauthorized)
            showGoToPermissionSettingAlert()
            return promise
        }

        speechRecognizer.defaultTaskHint = .dictation

        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            promise.fulfill("Error: cannot create recognitionRequest")
            return promise
        }

        recognitionRequest.shouldReportPartialResults = false
        recognitionRequest.taskHint = .dictation

        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: resultHandler)

        guard recognitionTask != nil else {
            promise.fulfill("Error: cannot create recognitionTask")
            return promise
        }

        inputNode = engine.audioEngine.inputNode
        //let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: nil) { buffer, _ in
            self.recognitionRequest?.append(buffer)

            // calculate mic volume
            // https://www.raywenderlich.com/5154-avaudioengine-tutorial-for-ios-getting-started
            guard let channelData = buffer.floatChannelData else { return }
            let channelDataValue = channelData.pointee
            let channelDataValueArray = stride(from: 0,
                                               to: Int(buffer.frameLength),
                                               by: buffer.stride).map { channelDataValue[$0] }

            let rms = sqrt(channelDataValueArray
                            .reduce(0) {$0 + $1*$1 } / Float(buffer.frameLength)
                      )
            let avgPower = 20 * log10(rms)
            let meterLevel = self.scaledPower(power: avgPower)
            postEvent(.levelMeterUpdate, int: Int(meterLevel * 100))
        }

        Timer.scheduledTimer(withTimeInterval: stopAfterSeconds, repeats: false) { _ in
            self.endAudio()
        }

        self.isRunning = true
        postEvent(.listenStarted, string: "")
        return promise
    }

    func scaledPower(power: Float) -> Float {
        guard power.isFinite else { return 0.0 }

        if power < minDb {
            return 0.0
        } else if power >= 1.0 {
            return 1.0
        } else {
            return (abs(minDb) - abs(power)) / abs(minDb)
        }
    }

    // isCanceling is true  => cancel task, discard any said words
    //                false => listen until now, ask apple to return recognized result
    func endAudio(isCanceling: Bool = false) {
        guard isRunning else { return }
        isRunning = false

        guard !isSimulator else { return }

        inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        if isCanceling {
            recognitionTask?.cancel()
        }

        recognitionRequest = nil
        recognitionTask = nil
    }

    // MARK: - Private Methods
    func resultHandler(result: SFSpeechRecognitionResult?, error: Error?) {
        guard engine.isEngineRunning else {
            promise.reject(SpeechRecognitionError.engineStopped)
            return
        }

        if let result = result {
            promise.fulfill( result.bestTranscription.formattedString)
        }

        if let error = error {
            if let userInfo = error._userInfo,
               let desc = userInfo["NSLocalizedDescription"] as? String {
                // Retry means didn't hear anything please say again
                if desc == "Retry" {
                    promise.fulfill("")
                } else {
                    promise.fulfill("")
                    _ = getKanaTokenInfos("\(error)")
                    print(error)
                }
                promise.fulfill("")
                return
            }
            _ = getKanaTokenInfos("\(error)")
            print(error)
            promise.fulfill("")
        }
    }

    private func authorize() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            switch authStatus {
            case .authorized:
                self.isAuthorized = true
                print("Speech Recogntion is authorized")

            case .denied:
                self.isAuthorized = false
                print("User denied access to speech recognition")

            case .restricted:
                self.isAuthorized = false
                print("Speech recognition restricted on this device")

            case .notDetermined:
                self.isAuthorized = false
                print("Speech recognition not yet authorized")
            }
        }
    }

    private func startFaked(stopAfterSeconds: Double = 5) -> Promise<String> {
        isRunning = true
        postEvent(.listenStarted, string: "")
        Timer.scheduledTimer(withTimeInterval: stopAfterSeconds, repeats: false) {_ in
            let fakeSuffix = ["", "", "西宮", "はは"]
            let fakeSaidString = context.targetString + fakeSuffix[Int(arc4random_uniform(UInt32(fakeSuffix.count)))]

            self.promise.fulfill(fakeSaidString)
        }
        return promise
    }
}
