//
//  AudioController.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/04/24.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import Promises
import UIKit
import AVFoundation

enum GameFlowMode: String, Codable {
    case shadowing, chat
}

enum ContentTab: String, Codable {
    case topics, infiniteChallenge
}

class GameContext {
    // MARK: - Singleton
    static let shared = GameContext()

    private init() {}

    // MARK: - Long-term data will be kept in UserDefault
    var gameHistory = [GameRecord]()
    var gameSetting = GameSetting()

    // MARK: - Medium-term context of current game
    var gameRecord: GameRecord?
    var sentenceIndex: Int = 0
    var sentences: [String] = []

    var contentTab: ContentTab = .topics
    var infiniteChallengeLevel: Level = .lv0
    var topicDataSetKey: String = ""
    var gameState: GameState = .justStarted {
        didSet {
            postEvent(.gameStateChanged, gameState: gameState)
        }
    }

    var dataSetKey: String {
        get {
            return contentTab == .topics ? topicDataSetKey : infiniteChallengeLevel.infinteChallengeDatasetKey
        }

        set {
            topicDataSetKey = newValue
        }
    }

    var teachingRate: Float {
        guard gameSetting.isAutoSpeed else { return gameSetting.preferredSpeed }
        return gameRecord?.level.autoSpeed ?? AVSpeechUtteranceDefaultSpeechRate * 0.8
    }

    var gameTitle: String {
        return contentTab == .topics ?
            getDataSetTitle(dataSetKey: dataSetKey) :
        "[無限挑戦] \(infiniteChallengeLevel.title)"
    }

    // MARK: - Short-term context for a sentence, will be discarded after each sentence played
    var targetString: String {
        guard sentenceIndex < sentences.count else { return ""}
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

    var score: Score = Score(value: 100)

    // Real duration in seconds of tts speaking
    var speakDuration: Float = 0

    // Calculated duration when guide voice off mode
    var calculatedSpeakDuration: Promise<Float> {
        let duration: Promise<Float> = Promise<Float>.pending()
        if gameLang == .jp {
            getKana(targetString).then({ [unowned self] kana in
                duration.fulfill(
                    1.0 +
                    kana.count.f * 0.13 /
                    (self.teachingRate/AVSpeechUtteranceDefaultSpeechRate)
                )
            })
        } else {
            let level = gameRecord?.level ?? Level.lv4
            duration.fulfill(
                    1.0 +
                    level.maxSyllablesCount.f * 0.13 /
                    (self.teachingRate/AVSpeechUtteranceDefaultSpeechRate)
            )
        }
        return duration
    }
}

// MARK: - functions for a single game
extension GameContext {

    func loadLearningSentences() {
        if contentTab == .topics {
            loadTopicSentence()
        } else {
            loadInfiniteChallengeLevelSentence()
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
        let sentenceIds = randSentenceIds(
            minKanaCount: level.minSyllablesCount,
            maxKanaCount: level.maxSyllablesCount,
            numOfSentences: numOfSentences
        )

        sentences = getSentencesByIds(ids: sentenceIds)

        if gameLang == .jp {
            sentences.forEach { s in
                _ = s.furiganaAttributedString // load furigana
            }
        }

        gameRecord = GameRecord(dataSetKey, sentencesCount: sentences.count, level: level)
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
        if contentTab == .topics {
            if let currentIdx = dataSetKeys.lastIndex(of: dataSetKey) {
                dataSetKey = dataSetKeys[(currentIdx + 1) % dataSetKeys.count]
            }
        } else {
            infiniteChallengeLevel = infiniteChallengeLevel.next
        }
        loadLearningSentences()
    }

    func loadPrevousChallenge() {
        if contentTab == .topics {
            if let currentIdx = dataSetKeys.lastIndex(of: dataSetKey) {
                dataSetKey = dataSetKeys[(currentIdx + dataSetKeys.count - 1) % dataSetKeys.count]
            }
        } else {
            infiniteChallengeLevel = infiniteChallengeLevel.previous
        }
        loadLearningSentences()
    }
}
