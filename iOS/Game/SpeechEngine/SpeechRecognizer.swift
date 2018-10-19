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

enum SpeechRecognitionError: Error {
    case unauthorized
    case engineStopped
}

class SpeechRecognizer: NSObject {
    private var speechRecognizer: SFSpeechRecognizer?
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
    func start(stopAfterSeconds: Double = 5, localIdentifier: String = "ja") -> Promise<String> {
        promise = Promise<String>.pending()

        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: localIdentifier))
        speechRecognizer?.defaultTaskHint = .dictation
        // mocked start for simulator
        guard !isSimulator else {
            return startFaked(stopAfterSeconds: stopAfterSeconds)
        }

        guard engine.isEngineRunning else {
            print("Engine is not started error")
            promise.fulfill("SpeechRecognizer: Eninge is not started error")
            return promise
        }

        if !isAuthorized {
            promise.reject(SpeechRecognitionError.unauthorized)
            showMessage("無法取得語音辨識權限。")
            return promise
        }

        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object")
        }

        recognitionRequest.shouldReportPartialResults = true //false
        recognitionRequest.taskHint = .dictation

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: resultHandler)

        inputNode = engine.audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }

        Timer.scheduledTimer(withTimeInterval: stopAfterSeconds, repeats: false) { _ in
            self.endAudio()
        }

        self.isRunning = true
        postEvent(.listenStarted, string: "")
        return promise
    }

    func stop() {
        guard isRunning else { return }

        guard !isSimulator else {
            postEvent(.listenEnded, string: "")
            isRunning = false
            return
        }

        inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()

        recognitionRequest = nil
        recognitionTask = nil
        isRunning = false
        postEvent(.listenEnded, string: "")
    }

    // MARK: - Private Methods
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
            context.userSaidString = fakeSaidString
            postEvent(.listenEnded, string: fakeSaidString)

            self.promise.fulfill(fakeSaidString)
        }
        return promise
    }

    func endAudio() {
        guard isRunning, !isSimulator else { return }

        inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()

        recognitionRequest = nil
        recognitionTask = nil
        isRunning = false
    }

    private func resultHandler(result: SFSpeechRecognitionResult?, error: Error?) {
        guard engine.isEngineRunning else {
            promise.reject(SpeechRecognitionError.engineStopped)
            return
        }

        if let result = result {
            if result.isFinal {
                context.userSaidString = result.bestTranscription.formattedString
                postEvent(.listenEnded, string: context.userSaidString)
                promise.fulfill(context.userSaidString)
            } else {
                postEvent(.stringRecognized, string: result.bestTranscription.formattedString)
            }
        }

        if error != nil {
            context.userSaidString = ""
            postEvent(.listenEnded, string: context.userSaidString)
            promise.fulfill(context.userSaidString)
        }
    }
}
