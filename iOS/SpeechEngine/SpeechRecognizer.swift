//
//  SpeechRecognizer.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/04/16.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import Promises
import Speech

private let engine = SpeechEngine.shared

enum SpeechRecognitionError: Error {
    case unauthorized
    case engineStopped
}

class SpeechRecognizer: NSObject {
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?

    private var localeId: String?

    private var speechRecognizers: [String: SFSpeechRecognizer] = [
        Lang.ja.defaultCode: SFSpeechRecognizer(locale: Locale(identifier: Lang.ja.defaultCode))!,
        Lang.en.defaultCode: SFSpeechRecognizer(locale: Locale(identifier: Lang.en.defaultCode))!
    ]

    private var speechRecognizer: SFSpeechRecognizer {
        if let localeId = localeId,
           let recognizer = speechRecognizers[localeId] ?? SFSpeechRecognizer(locale: Locale(identifier: localeId)) {
            speechRecognizers[localeId] = recognizer
            return recognizer
        }
        return speechRecognizers[Lang.en.defaultCode]!
    }

    private var recognitionTask: SFSpeechRecognitionTask?
    private var isRunning: Bool = false
    private var isAuthorized: Bool = false
    private var originalStr: String?
    private var promise = Promise<[String]>.pending()

    override init() {
        super.init()
        let session = AVAudioSession.sharedInstance()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleInterruption(notification:)),
                                               name: AVAudioSession.interruptionNotification,
                                               object: session)
    }

    // MARK: - Public Methods

    func listen(
        stopAfterSeconds: Double = 5,
        localeId: String,
        originalStr: String? = nil
    ) -> Promise<[String]> {
        endAudio()
        self.localeId = localeId
        promise = Promise<[String]>.pending()
        // mocked start for simulator
        if isSimulator {
            return fakeListening(stopAfterSeconds: stopAfterSeconds)
        }

        guard engine.isEngineRunning else {
            promise.fulfill(["Error: SpeechEninge is not started"])
            return promise
        }

        if !isAuthorized {
            promise.reject(SpeechRecognitionError.unauthorized)
            showGoToPermissionSettingAlert()
            return promise
        }

        self.originalStr = originalStr

        speechRecognizer.defaultTaskHint = .dictation

        recognitionTask?.cancel()
        recognitionTask = nil

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            promise.fulfill(["Error: cannot create recognitionRequest"])
            return promise
        }

        if #available(iOS 13.0, *) {
            recognitionRequest.requiresOnDeviceRecognition = false
        }

        recognitionRequest.shouldReportPartialResults = false
        recognitionRequest.taskHint = .dictation

        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: resultHandler)

        guard recognitionTask != nil else {
            promise.fulfill(["Error: cannot create recognitionTask"])
            return promise
        }

        Timer.scheduledTimer(withTimeInterval: stopAfterSeconds, repeats: false) { _ in
            self.endAudio()
        }

        isRunning = true
        postEvent(.listenStarted, string: "")
        return promise
    }

    // isCanceling is true  => cancel task, discard any said words
    //                false => listen until now, ask apple to return recognized result
    func endAudio(isCanceling: Bool = false) {
        guard isRunning else { return }
        isRunning = false

        guard !isSimulator else { return }

        recognitionRequest?.endAudio()
        if isCanceling {
            recognitionTask?.cancel()
        }

        recognitionRequest = nil
        recognitionTask = nil
        postEvent(.listenStopped, string: "")
    }

    func authorize() -> Promise<Void> {
        let promise = Promise<Void>.pending()
        SFSpeechRecognizer.requestAuthorization { authStatus in
            switch authStatus {
            case .authorized:
                self.isAuthorized = true
                // print("Speech Recogntion is authorized")

            case .denied:
                self.isAuthorized = false
                print("User denied access to speech recognition")

            case .restricted:
                self.isAuthorized = false
                print("Speech recognition restricted on this device")

            case .notDetermined:
                self.isAuthorized = false
                print("Speech recognition not yet authorized")
            @unknown default:
                print("\n#### requestAuthorization unknown default ####\n")
            }
            promise.fulfill(())
        }
        return isSimulator ? fulfilledVoidPromise() : promise
    }

    // MARK: - Private Methods

    private func resultHandler(result: SFSpeechRecognitionResult?, error: Error?) {
        guard engine.isEngineRunning else {
            promise.reject(SpeechRecognitionError.engineStopped)
            return
        }

        if let result = result {
            var segs: [[String]] = []
            var str = ""
            result.bestTranscription.segments.forEach {
                if $0.alternativeSubstrings.isEmpty {
                    str += "\($0.substring) "
                    segs.append([$0.substring])
                } else {
                    var arr = [$0.substring]
                    arr.append(contentsOf: $0.alternativeSubstrings)
                    str += "\(arr) "
                    segs.append(arr)
                }
            }
            print("segments:", str)
            let bestCandidate = findCandidate(segs: segs, originalStr: originalStr ?? "")

            var candidates = [result.bestTranscription.formattedString]
            if bestCandidate != candidates[0], bestCandidate != "" {
                candidates.append(bestCandidate)
            }

            //print(candidates)

            promise.fulfill(candidates)
        }

        if let error = error {
            if let userInfo = error._userInfo,
               let desc = (userInfo["NSLocalizedDescription"] as? String) {
                // Retry means didn't hear anything please say again
                if desc == "Retry" {
                    promise.fulfill([""])
                    print(error, desc)
                } else {
                    promise.fulfill([""])
                    _ = getKanaTokenInfos("\(error)")
                    print(error, desc)
                }
                promise.fulfill([""])
                return
            }
            _ = getKanaTokenInfos("\(error)")
            print(error)
            promise.fulfill([""])
        }
    }

    // for simulator
    private func fakeListening(stopAfterSeconds: Double = 5) -> Promise<[String]> {
        isRunning = true
        postEvent(.listenStarted, string: "")
        Timer.scheduledTimer(withTimeInterval: stopAfterSeconds, repeats: false) { [weak self] _ in
            let fakeSuffix = ["", "", "西宮", "はは"]
            let fakeSaidString = (self?.originalStr ?? "") + fakeSuffix[Int.random(in: 0 ..< fakeSuffix.count)]

            self?.promise.fulfill([fakeSaidString])
        }
        return promise
    }

    // https://stackoverflow.com/questions/48749729/avaudiosession-interruption-on-declining-phone-call
    @objc private func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let interruptionTypeRawValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let interruptionType = AVAudioSession.InterruptionType(rawValue: interruptionTypeRawValue),
              let session = notification.object as? AVAudioSession else {
            print("Recorder - something went wrong")
            return
        }
        switch interruptionType {
        case .began:
            endAudio()
            try? session.setActive(false)
        case .ended:
            try? session.setActive(true)
        @unknown default:
            print("unkown interruptionType")
        }
    }
}
