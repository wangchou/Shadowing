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
private let engine = GameEngine.shared

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

    override init() {
        super.init()
        if !isSimulator {
            speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))
            authorize()
        }

    }

    // MARK: - Public Methods
    func start(stopAfterSeconds: Double = 5) -> Promise<String> {
        promise = Promise<String>.pending()
        guard !isSimulator else {
            self.isRunning = true
            postEvent(.listenStarted, string: "")
            Timer.scheduledTimer(withTimeInterval: stopAfterSeconds, repeats: false) {_ in
                let fakeSuffix = ["", "", "西宮", "はは"]
                let fakeSaidString = context.targetString + fakeSuffix[Int(arc4random_uniform(UInt32(fakeSuffix.count)))]
                postEvent(.listenEnded, string: fakeSaidString)
                context.userSaidString = fakeSaidString

                self.promise.fulfill(fakeSaidString)
            }
            return promise
        }

        if !isAuthorized {
            promise.reject(SpeechRecognitionError.unauthorized)
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

        self.inputNode = engine.audioEngine.inputNode
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

    func endAudio() {
        if self.isRunning {
            guard !isSimulator else {
                context.userSaidString = context.targetString
                postEvent(.listenEnded, string: context.userSaidString)
                promise.fulfill(context.userSaidString)
                isRunning = false
                return
            }
            inputNode.removeTap(onBus: 0)
            recognitionRequest?.endAudio()

            recognitionRequest = nil
            recognitionTask = nil
            isRunning = false
        }
    }

    func stop() {
        if self.isRunning {
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
    }

    func resultHandler(result: SFSpeechRecognitionResult?, error: Error?) {
        if !engine.isEngineRunning {
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
