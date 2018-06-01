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

enum GameMode {
    case phone, messenger, console, reader
}

class GameContext {
    //Singleton
    static let shared = GameContext()

    var gameHistory = [GameRecord]()
    var gameCharacter: GameCharacter = GameCharacter()
    var engine = AVAudioEngine()
    var micVolumeNode = AVAudioMixerNode()
    var speechRecognizer = SpeechRecognizer()
    var bgm = BGM()
    var tts = TTS()

    var gameMode: GameMode = .phone

    var isEngineRunning = false
    var isNewRecord = false
    var sentences: [String] = []
    var userSaidSentences: [String] = []
    var sentenceIndex: Int = 0
    var targetString: String = ""
    var userSaidString: String {
        get {
            return userSaidSentences[sentenceIndex]
        }

        set {
            userSaidSentences[sentenceIndex] = newValue
        }
    }
    var score = 0
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
        gameCharacter = loadGameCharacter()
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
        userSaidSentences = sentences.map { _ in "" }

        targetString = sentences[0]
        life = isSimulator ? 100 : 40

        let level = allLevels[dataSetKey] ?? .n5a
        gameRecord = GameRecord(dataSetKey, sentencesCount: sentences.count, level: level)

        isNewRecord = false
    }

    func nextSentence() -> Bool {
        sentenceIndex += 1
        guard sentenceIndex < sentences.count else { return false }
        //guard sentenceIndex < 3 else { return false }
        targetString = sentences[sentenceIndex]
        userSaidString = ""
        return true
    }
}
