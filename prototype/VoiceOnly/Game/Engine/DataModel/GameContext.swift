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
import UIKit

enum GameMode {
    case phone, messenger, console, reader
}

class GameContext {
    // Singleton
    static let shared = GameContext()

    // Long term data will be kept in UserDefault
    var gameHistory = [GameRecord]()
    var gameCharacter: GameCharacter = GameCharacter()
    var characterImage: UIImage?

    // Short term data for single game
    var engine = AVAudioEngine()
    var micVolumeNode = AVAudioMixerNode()
    var speechRecognizer = SpeechRecognizer()
    var bgm = BGM()
    var tts = TTS()

    var gameMode: GameMode = .phone

    var isEngineRunning = false
    var isNewRecord = false
    var sentences: [String] = []
    var userSaidSentences: [String: String] = [:]
    var sentenceIndex: Int = 0
    var targetString: String = ""
    var userSaidString: String {
        get {
            return userSaidSentences[self.targetString] ?? ""
        }

        set {
            userSaidSentences[self.targetString] = newValue
        }
    }
    var score: Score = Score(value: 0)
    var life: Int = 40
    var startTime: Double = getNow()

    var teachingRate: Float {
        return AVSpeechUtteranceDefaultSpeechRate * (0.5 + life.f * 0.005)
    }
    var dataSetKey: String = ""
    var gameRecord: GameRecord?

    // MARK: - Lifecycle
    private init() {
        guard !isSimulator else { return }
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
        guard let selectedDataSet = allSentences[dataSetKey] else { return }
        sentences = isShuffle ? selectedDataSet.shuffled() : selectedDataSet
        userSaidSentences = [:]

        targetString = sentences[0]
        life = isSimulator ? 100 : 40

        let level = allLevels[dataSetKey] ?? .n5a
        gameRecord = GameRecord(dataSetKey, sentencesCount: sentences.count, level: level)

        isNewRecord = false
    }

    func nextSentence() -> Bool {
        sentenceIndex += 1
        var sentencesBound = sentences.count
        if isSimulator {
            sentencesBound = 3
        }
        guard sentenceIndex < sentencesBound else { return false }
        targetString = sentences[sentenceIndex]
        userSaidString = ""
        return true
    }
}
