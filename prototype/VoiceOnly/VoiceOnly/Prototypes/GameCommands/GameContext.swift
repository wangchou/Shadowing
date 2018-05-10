//
//  AudioController.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/04/24.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import AVFoundation
import Speech
import Promises

struct GameRecord {
    let dataSetKey: String
    let sentencesCount: Int
    var perfectCount: Int
    var greatCount: Int
    var goodCount: Int
    
    func getP() -> Int {
        return 100 * (perfectCount + greatCount) / sentencesCount
    }
    
    var rank: String {
        let p = getP()
        if p == 100 && perfectCount == sentencesCount { return "SS" }
        if p == 100 { return "S" }
        if p > 90 { return "A" }
        if p > 80 { return "B" }
        if p > 70 { return "C" }
        if p > 60 { return "D" }
        if p > 50 { return "E" }
        return "F"
    }
    
    init(_ dataSetKey: String, sentencesCount: Int, perfectCount: Int = 0, greatCount: Int = 0, goodCount: Int = 0) {
        self.dataSetKey = dataSetKey
        self.sentencesCount = sentencesCount
        self.perfectCount = perfectCount
        self.greatCount = greatCount
        self.goodCount = goodCount
    }
    
    var progress: String {
       return "\(getP())%"
    }
}

class GameContext {
    //Singleton
    static let shared = GameContext()
    
    var gameHistory = [String: GameRecord]()
    
    var engine = AVAudioEngine()
    var micVolumeNode = AVAudioMixerNode()
    var speechRecognizer = SpeechRecognizer()
    var bgm = BGM()
    var tts = TTS()
    
    var isEngineRunning = false
    var sentences: [String] = []
    var sentenceIndex: Int = 0
    var targetString: String = ""
    var userSaidString: String = ""
    var score = 0
    var life: Int = 40 {
        didSet {
            teachingRate = AVSpeechUtteranceDefaultSpeechRate * (0.5 + (Float(life) * 0.005))
        }
    }
    
    var teachingRate = AVSpeechUtteranceDefaultSpeechRate * 0.7
    var dataSetKey: String = allSentences.keys.first!
    var gameRecord: GameRecord?
    
    // MARK: - Lifecycle
    private init() {
        configureAudioSession()
        buildNodeGraph()
        engine.prepare()
    }
    
    private func buildNodeGraph() {
        let mainMixer = engine.mainMixerNode
        let mic = engine.inputNode // only for real device, simulator will crash

        engine.attach(bgm.node)
        engine.attach(micVolumeNode)
        
        engine.connect(bgm.node, to: mainMixer, format: bgm.buffer.format)
        engine.connect(mic, to: micVolumeNode, format: mic.inputFormat(forBus: 0))
        engine.connect(micVolumeNode, to: mainMixer, format: micVolumeNode.outputFormat(forBus: 0))

        micVolumeNode.volume = micOutVolume
        bgm.node.volume = 0.5
    }
    
    func loadLearningSentences() {
        sentenceIndex = 0
        sentences = allSentences[dataSetKey]!.shuffled()
        targetString = sentences[0]
        userSaidString = ""
        life = 40
        gameRecord = GameRecord(dataSetKey, sentencesCount: sentences.count)
    }
    
    func nextSentence() -> Bool {
        sentenceIndex = sentenceIndex + 1
        if sentenceIndex < sentences.count {
            targetString = sentences[sentenceIndex]
            userSaidString = ""
            return true
        } else {
            return false
        }
    }
}


