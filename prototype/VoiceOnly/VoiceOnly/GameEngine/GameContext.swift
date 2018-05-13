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
    var life: Int = 40
    var startTime: Double = getNow()
    
    var teachingRate: Float {
        return AVSpeechUtteranceDefaultSpeechRate * (0.5 + life.f * 0.005)
    }
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
    
    func loadLearningSentences(isShuffle: Bool = true) {
        sentenceIndex = 0
        
        sentences = isShuffle ? allSentences[dataSetKey]!.shuffled() : allSentences[dataSetKey]!
        
        targetString = sentences[0]
        userSaidString = ""
        life = 40
        gameRecord = GameRecord(dataSetKey, sentencesCount: sentences.count)
    }
    
    func nextSentence() -> Bool {
        sentenceIndex = sentenceIndex + 1
        guard sentenceIndex < sentences.count else { return false }
        
        targetString = sentences[sentenceIndex]
        userSaidString = ""
        return true
    }
}


