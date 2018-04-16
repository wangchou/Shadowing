//
//  SpeechRecognizer.swift
//  PlayThrough
//
//  Created by Wangchou Lu on H30/04/16.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import Speech

class SpeechRecognizer {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))!
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private var isRunning: Bool = false
    
    private var isAuthorized: Bool = false
    
    private var inputNode: AVAudioInputNode!
    
    func authorize() {
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
    
    init() {
        authorize()
    }
    
    func start(inputNode: AVAudioInputNode, resultHandler: @escaping (SFSpeechRecognitionResult?, Error?) -> Void) {
        if(!isAuthorized) {
            print("speech service is unauthorized, cannot start recogniztion")
            return
        }
   
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
    
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        recognitionRequest.shouldReportPartialResults = true

        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: resultHandler)
        
        self.inputNode = inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
    
        self.isRunning = true
        print("(Go ahead, I'm listening)")
    }
    
    func stop() {
        if(self.isRunning) {
            recognitionRequest?.endAudio()
            inputNode.removeTap(onBus: 0)
            
            self.recognitionRequest = nil
            self.recognitionTask = nil
            self.isRunning = false
            print("Speech recognition is stopped")
        }
    }
}
