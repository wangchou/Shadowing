//
//  SpeechRecognizer.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/04/16.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import Speech

let RECORD_URL = URL(fileURLWithPath: Bundle.main.path(forResource: "recoding", ofType: "caf")!)

class SpeechRecognizer: NSObject {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))!
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    private var recognitionTask: SFSpeechRecognitionTask?
    
    public var recordFile: AVAudioFile!
    
    private var isRunning: Bool = false
    
    private var isAuthorized: Bool = false
    
    private var inputNode: AVAudioNode!
    
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
    func start(inputNode: AVAudioNode,
               stopAfterSeconds: Double = 5,
               resultHandler: @escaping (SFSpeechRecognitionResult?, Error?) -> Void
               ) {
        if(!isAuthorized) {
            print("speech service is unauthorized, cannot start recogniztion")
            return
        }
   
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
    
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = false

        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: resultHandler)
        
        self.inputNode = inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        // for replay, record into file for replay
        do {
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as NSString
            let url = NSURL.init(string: path .appendingPathComponent("audio.caf"))
            recordFile = try AVAudioFile(forWriting: url! as URL, settings: [:])
        } catch {
            print("open recoding file error")
        }
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            // for recognition
            self.recognitionRequest?.append(buffer)
            
            do {
                try self.recordFile.write(from: buffer)
            } catch {
                print("recordFile.writeFromBuffer error:", error)
            }
        }
        self.isRunning = true
        
        Timer.scheduledTimer(withTimeInterval: stopAfterSeconds, repeats: false) { timer in
            self.endAudio()
        }
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
        }
    }
}
