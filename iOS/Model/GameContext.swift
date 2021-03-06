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

enum UITabMode {
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
        if gameLang == .ja { return jaHistory }
        if gameLang == .en { return enHistory }
        return []
    }

    var gameSetting = GameSetting()
    var gameMedal = GameMedal()
    var bottomTab: UITabMode = .topics

    // MARK: - Medium-term context of current game

    var gameRecord: GameRecord?
    var sentenceIndex: Int = 0
    var sentences: [Sentence] = []

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

    var teachingSpeed: Float {
        return gameSetting.gameSpeed
    }

    var assistantSpeed: Float {
        return teachingSpeed > fastSpeed ? teachingSpeed : fastSpeed
    }

    var translatorSpeed: Float {
        return teachingSpeed > fastSpeed ? teachingSpeed : fastSpeed
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
            return "[🏅] \(gameMedal.lowLevel.title)"
        }
    }

    // MARK: - Short-term context for a sentence, will be discarded after each sentence played

    var score = Score(value: 100)

    // Real duration in seconds of tts speaking
    var speakDuration: Float = 0

    var targetSentence: Sentence {
        return sentences[sentenceIndex]
    }

    var targetString: String {
        return targetSentence.origin
    }

    var ttsFixes: [(String, String)] {
        return targetSentence.ttsFixes
    }

    var translation: String {
        return gameMode == .topicMode ? targetSentence.cmn : targetSentence.translation
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
        return userSaidSentences[targetString] ?? ""
    }

    // Calculated duration when guide voice off mode
    var calculatedSpeakDuration: Promise<Float> {
        let duration = Promise<Float>.pending()
        if gameLang == .ja {
            getKana(targetString, originalString: nil).then { [unowned self] kana in
                duration.fulfill(
                    1.0 +
                        kana.count.f * 0.13 /
                        (self.teachingSpeed)
                )
            }
        } else {
            let level = gameRecord?.level ?? Level.lv4
            duration.fulfill(
                1.0 +
                    level.maxSyllablesCount.f * 0.13 /
                    (teachingSpeed)
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
        sentences = selectedDataSet.map { ja in
            getSentenceByString(ja)
        }

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

        if gameLang == .ja {
            sentences.forEach { s in
                _ = s.ja.furiganaAttributedString // load furigana
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

        if gameLang == .ja {
            sentences.forEach { s in
                _ = s.ja.furiganaAttributedString // load furigana
            }
        }

        gameRecord = GameRecord(dataSetKey, sentencesCount: sentences.count, level: gameMedal.lowLevel)
    }

    func loadMedalCorrectionSentence() {
        sentenceIndex = 0
        sentences = Array(getTodaySentenceSet()).sorted {
            (sentenceScores[$0]?.value ?? 0) < (sentenceScores[$1]?.value ?? 0)
        }.map { str -> Sentence in
            getSentenceByString(str)
        }

        // This should not trigger network requests
        // It is safeNet for bug side effect in 1.3.0 & 1.3.1
        // Should be removed in 1.4.0
        if gameLang == .ja {
            waitKanaInfoLoaded.then { _ in
                self.sentences.forEach { s in
                    if kanaTokenInfosCacheDictionary[s.ja] == nil {
                        _ = s.ja.furiganaAttributedString // load furigana
                    }
                    if let userSaidSentence = userSaidSentences[s.ja],
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
        for record in GameContext.shared.gameHistory {
            if todayKey == getDateKey(date: record.startedTime) {
                for string in record.sentencesScore.keys {
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

// MARK: - Wrappers of engine.speak

// narratorSay      speak intitial instructions
// translatorSay    speak translation
// teacherSay       speak the text for repeating
// assisantSay      speak correct, good, wrong...
// ttsSay           speak sample text in voiceSelection Page

private extension SpeechEngine {
    func speak(text: String,
               speaker: String,
               speed: Float,
               lang: Lang,
               ttsFixes: [(String, String)] = []) -> Promise<Void> {

        return getFixedTTSString(
            text,
            localFixes: ttsFixes,
            isJa: lang == .ja
        ).then { ttsString, ttsToDisplayMap in
            self.say(
                text,
                voiceId: speaker,
                speed: speed,
                lang: lang,
                ttsString: ttsString,
                ttsToDisplayMap: ttsToDisplayMap
            )
        }
    }
}

private let context = GameContext.shared
private let engine = SpeechEngine.shared

func speakTitle() -> Promise<Void> {
    context.gameState = .speakTitle
    let title = context.gameTitleToSpeak
    if context.gameMode == .topicMode {
        let voiceId = context.gameSetting.translatorZh
        return engine.speak(text: title, speaker: voiceId, speed: normalSpeed, lang: .zh)
    }

    return narratorSay(title)
}

func narratorSay(_ text: String) -> Promise<Void> {
    return engine.speak(text: text,
                        speaker: context.gameSetting.narrator,
                        speed: context.assistantSpeed,
                        lang: i18n.lang)
}

func translatorSay(_ text: String) -> Promise<Void> {
    var voiceId = context.gameSetting.translator

    if AVSpeechSynthesisVoice(identifier: voiceId) == nil {
        switch context.gameSetting.translationLang {
        case .ja:
            voiceId = VoiceDefaults.translatorJa
        case .en:
            voiceId = VoiceDefaults.translatorEn
        case .zh:
            voiceId = VoiceDefaults.translatorZh
        default:
            print("\(context.gameSetting.translationLang.key) should not be translation lang")
            voiceId = "unknown"
        }
    }

    return engine.speak(text: text,
                        speaker: voiceId,
                        speed: context.translatorSpeed,
                        lang: context.gameSetting.translationLang)
}

func topicTranslatorSay(_ text: String) -> Promise<Void> {
    return engine.speak(text: text,
                        speaker: context.gameSetting.translatorZh,
                        speed: context.translatorSpeed,
                        lang: .zh)
}

func assisantSay(_ text: String) -> Promise<Void> {
    return engine.speak(text: text,
                        speaker: context.gameSetting.assistant,
                        speed: context.assistantSpeed,
                        lang: gameLang)
}

func teacherSay(_ text: String, speed: Float = context.teachingSpeed, ttsFixes: [(String, String)]) -> Promise<Void> {
    return engine.speak(text: text,
                        speaker: context.gameSetting.teacher,
                        speed: speed,
                        lang: gameLang,
                        ttsFixes: ttsFixes)
}

// only for voice selection page
func ttsSay(_ text: String, speaker: String, speed: Float = context.teachingSpeed, lang: Lang) -> Promise<Void> {
    return engine.speak(text: text, speaker: speaker, speed: speed, lang: lang)
}
