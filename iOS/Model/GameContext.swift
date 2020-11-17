//
//  AudioController.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/04/24.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import AVFoundation
import Foundation
import Promises
import UIKit

enum GameFlowMode: String, Codable {
    case shadowing, chat
}

enum UITab {
    case topics, infiniteChallenge
}

enum GameMode {
    case topicMode, infiniteChallengeMode, medalMode
}

class GameContext {
    // MARK: - Singleton

    static let shared = GameContext()

    private init() {}

    // MARK: - Long-term data will be kept in UserDefault

    var gameHistory: [GameRecord] {
        if gameLang == .jp { return jpHistory }
        if gameLang == .en { return enHistory }
        return []
    }

    var gameSetting = GameSetting()
    var gameMedal = GameMedal()
    var bottomTab: UITab = .topics

    // MARK: - Medium-term context of current game

    var gameRecord: GameRecord?
    var sentenceIndex: Int = 0
    var sentences: [String] = []

    var gameMode: GameMode = .topicMode
    var infiniteChallengeLevel: Level = .lv0
    var topicDataSetKey: String = ""
    var gameState: GameState = .justStarted {
        didSet {
            postEvent(.gameStateChanged, gameState: gameState)
        }
    }

    var dataSetKey: String {
        get {
            switch gameMode {
            case .topicMode:
                return topicDataSetKey
            case .infiniteChallengeMode:
                return infiniteChallengeLevel.infinteChallengeDatasetKey
            case .medalMode:
                return medalModeKey
            }
        }

        set {
            topicDataSetKey = newValue
        }
    }

    var teachingRate: Float {
        guard gameSetting.isAutoSpeed else { return gameSetting.preferredSpeed }
        return gameRecord?.level.autoSpeed ?? AVSpeechUtteranceDefaultSpeechRate * 0.8
    }

    var gameTitleToSpeak: String {
        switch gameMode {
        case .topicMode:
            return getDataSetTitle(dataSetKey: dataSetKey)
        case .infiniteChallengeMode:
            return "[\(i18n.infiniteChallenge)] \(infiniteChallengeLevel.title)"
        case .medalMode:
            return "[\(i18n.medalMode)] \(gameMedal.lowLevel.title)"
        }
    }

    var gameSimpleTitle: String {
        switch gameMode {
        case .topicMode:
            return getDataSetTitle(dataSetKey: dataSetKey)
        case .infiniteChallengeMode:
            return "[♾] \(infiniteChallengeLevel.title)"
        case .medalMode:
            let isEn = !i18n.isZh && !i18n.isJa
            return "[🏅\(isEn ? gameMedal.lowLevel.lvlTitle : "")] \(gameMedal.lowLevel.title)"
        }
    }

    // MARK: - Short-term context for a sentence, will be discarded after each sentence played

    var score: Score = Score(value: 100)

    // Real duration in seconds of tts speaking
    var speakDuration: Float = 0

    var targetString: String {
        guard sentenceIndex < sentences.count else { return "" }
        return sentences[sentenceIndex]
    }

    var targetAttrString: NSMutableAttributedString {
        var attrText = NSMutableAttributedString()
        if let tokenInfos = kanaTokenInfosCacheDictionary[targetString] {
            attrText = getFuriganaString(tokenInfos: tokenInfos)
        } else {
            attrText.append(rubyAttrStr(targetString))
        }
        return attrText
    }

    var userSaidString: String {
        return userSaidSentences[self.targetString] ?? ""
    }

    // Calculated duration when guide voice off mode
    var calculatedSpeakDuration: Promise<Float> {
        let duration: Promise<Float> = Promise<Float>.pending()
        if gameLang == .jp {
            getKana(targetString, originalString: nil).then { [unowned self] kana in
                duration.fulfill(
                    1.0 +
                        kana.count.f * 0.13 /
                        (self.teachingRate / AVSpeechUtteranceDefaultSpeechRate)
                )
            }
        } else {
            let level = gameRecord?.level ?? Level.lv4
            duration.fulfill(
                1.0 +
                    level.maxSyllablesCount.f * 0.13 /
                    (teachingRate / AVSpeechUtteranceDefaultSpeechRate)
            )
        }
        return duration
    }
}

// MARK: - functions for a single game

extension GameContext {
    func loadLearningSentences() {
        switch gameMode {
        case .topicMode:
            loadTopicSentence()
        case .infiniteChallengeMode:
            loadInfiniteChallengeLevelSentence()
        case .medalMode:
            loadMedalGameSentence()
        }
    }

    private func loadTopicSentence() {
        sentenceIndex = 0
        guard let selectedDataSet = dataSets[dataSetKey] else { return }
        sentences = selectedDataSet

        let level = dataKeyToLevels[dataSetKey] ?? .lv0
        gameRecord = GameRecord(dataSetKey, sentencesCount: sentences.count, level: level)
    }

    private func loadInfiniteChallengeLevelSentence() {
        let level = infiniteChallengeLevel
        sentenceIndex = 0
        let numOfSentences = isSimulator ? 3 : 10
        sentences = getRandSentences(
            level: level,
            numOfSentences: numOfSentences
        )

        if gameLang == .jp {
            sentences.forEach { s in
                _ = s.furiganaAttributedString // load furigana
            }
        }

        gameRecord = GameRecord(dataSetKey, sentencesCount: sentences.count, level: level)
    }

    private func loadMedalGameSentence() {
        sentenceIndex = 0
        let numOfSentences = isSimulator ? 3 : 10
        let lowLevelNumOfSentence = Int(Double(numOfSentences) * gameMedal.lowPercent)

        sentences = getRandSentences(
            level: gameMedal.lowLevel,
            numOfSentences: lowLevelNumOfSentence
        )
        sentences += getRandSentences(
            level: gameMedal.highLevel,
            numOfSentences: numOfSentences - lowLevelNumOfSentence
        )
        sentences.shuffle()

        if gameLang == .jp {
            sentences.forEach { s in
                _ = s.furiganaAttributedString // load furigana
            }
        }

        gameRecord = GameRecord(dataSetKey, sentencesCount: sentences.count, level: gameMedal.lowLevel)
    }

    func loadMedalCorrectionSentence() {
        sentences = Array(getTodaySentenceSet()).sorted {
            (sentenceScores[$0]?.value ?? 0) < (sentenceScores[$1]?.value ?? 0)
        }

        // This should not trigger network requests
        // It is safeNet for bug side effect in 1.3.0 & 1.3.1
        // Should be removed in 1.4.0
        if gameLang == .jp {
            waitKanaInfoLoaded.then { _ in
                self.sentences.forEach { s in
                    if kanaTokenInfosCacheDictionary[s] == nil {
                        _ = s.furiganaAttributedString // load furigana
                    }
                    if let userSaidSentence = userSaidSentences[s],
                        kanaTokenInfosCacheDictionary[userSaidSentence] == nil {
                        _ = userSaidSentence.furiganaAttributedString
                    }
                }
            }
        }
    }

    private func getTodaySentenceSet() -> Set<String> {
        var sentencesSet: Set<String> = []
        let todayKey = getDateKey(date: Date())
        for r in GameContext.shared.gameHistory {
            if todayKey == getDateKey(date: r.startedTime) {
                for string in r.sentencesScore.keys {
                    sentencesSet.insert(string)
                }
            }
        }
        return sentencesSet
    }

    func getMissedCount() -> Int {
        var missedCount = 0
        getTodaySentenceSet().forEach { str in
            let score = sentenceScores[str]?.value ?? 0
            if score < 60 {
                missedCount += 1
            }
        }
        return missedCount
    }

    func nextSentence() -> Bool {
        sentenceIndex += 1
        if isSimulator {
            guard sentenceIndex < 3 else { return false }
        }
        guard sentenceIndex < sentences.count else { return false }

        userSaidSentences[targetString] = ""
        return true
    }

    func loadNextChallenge() {
        if gameMode == .topicMode {
            if let currentIdx = dataSetKeys.lastIndex(of: dataSetKey) {
                dataSetKey = dataSetKeys[(currentIdx + 1) % dataSetKeys.count]
            }
        }
        if gameMode == .infiniteChallengeMode {
            infiniteChallengeLevel = infiniteChallengeLevel.next
        }
        loadLearningSentences()
    }

    func loadPrevousChallenge() {
        if gameMode == .topicMode {
            if let currentIdx = dataSetKeys.lastIndex(of: dataSetKey) {
                dataSetKey = dataSetKeys[(currentIdx + dataSetKeys.count - 1) % dataSetKeys.count]
            }
        }
        if gameMode == .infiniteChallengeMode {
            infiniteChallengeLevel = infiniteChallengeLevel.previous
        }
        loadLearningSentences()
    }
}
