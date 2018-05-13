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

fileprivate let context = GameContext.shared

enum SpeechRecognitionError: Error {
    case unauthorized
    case engineStopped
}

class SpeechRecognizer: NSObject {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))!
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
        authorize()
    }
    
    // MARK: - Public Methods
    func start(stopAfterSeconds: Double = 5) -> Promise<String> {
        promise = Promise<String>.pending()
        
        if(!isAuthorized) {
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

        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: resultHandler)
        
        self.inputNode = context.engine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) {
            (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
                self.recognitionRequest?.append(buffer)
        }
        
        Timer.scheduledTimer(withTimeInterval: stopAfterSeconds, repeats: false) { timer in
            self.endAudio()
        }
        
        self.isRunning = true
        postEvent(.listenStarted, string: "")
        return promise
    }

    func endAudio() {
        if(self.isRunning) {
            inputNode.removeTap(onBus: 0)
            recognitionRequest?.endAudio()
            
            recognitionRequest = nil
            recognitionTask = nil
            isRunning = false
        }
    }
    
    func stop() {
        if(self.isRunning) {
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
        if !context.isEngineRunning {
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
