//
//  DifficultyCalculator.swift
//  processVOC
//
//  Created by Wangchou Lu on 5/16/31 H.
//  Copyright © 31 Heisei Lu, WangChou. All rights reserved.
//

import Foundation

class DifficultyCalculator {
    static let shred = DifficultyCalculator()

    let filenames = ["level0", "level1", "level2", "level3", "level4", "level5", "level6", "level7", "level8"]
    var allVocSet: Set<String> = []
    var levelVocSets: [Set<String>] = [[], [], [], [], [], [], [], [], []]
    // work on text
    let tagger = NSLinguisticTagger(tagSchemes: [.tokenType, .language, .lexicalClass, .nameType, .lemma], options: 0)
    let options: NSLinguisticTagger.Options = [.omitPunctuation, .omitWhitespace, .omitOther]

    private init() {
        for (i, filename) in filenames.enumerated() {
            let vocs = getLines(filename: filename)
            for v in vocs {
                if !allVocSet.contains(v) {
                    allVocSet.insert(v)
                    levelVocSets[i].insert(v)
                }
            }
            //print(i, levelVocSets[i].count, allVocSet.count)
        }
    }

    // find top 3 difficult words in sentences and add it as sum
    public func getDifficulty(sentence: String) -> Int {
        var difficults: [Int] = []
        let words = lemmatization(for: sentence.lowercased())
        for word in words {
            let wordLevel = getWordLevel(word: word)
            difficults.append(wordLevel)
        }
        difficults.sort(by: >)
        var difficulty = 0
        for i in 0 ... 2 where i < difficults.count {
            difficulty += difficults[i]
        }
        return difficulty
    }

    private func getLines(filename: String) -> [String] {
        let path = NSHomeDirectory() + "/projects/Shadowing/preprocess/difficultyCalculator/\(filename)"
        let url = URL(fileURLWithPath: path)

        do {
            let text = try String(contentsOf: url, encoding: .utf8)
            return text.split(separator: "\n").map { $0.lowercased() }
        } catch {
            print("error")
        }
        return []
    }

    private func lemmatization(for text: String) -> [String] {
        var words: [String] = []
        tagger.string = text
        let range = NSRange(location: 0, length: text.utf16.count)
        tagger.enumerateTags(in: range, unit: .word, scheme: .lemma, options: options) { tag, tokenRange, _ in
            if let lemma = tag?.rawValue {
                words.append(lemma.lowercased())
            } else {
                words.append(String(text.substring(with: tokenRange)!))
            }
        }
        return words
    }

    private func containsIn(vocSet: Set<String>, words: [String]) -> Bool {
        for modifiedWord in words {
            if vocSet.contains(modifiedWord) {
                return true
            }
        }
        return false
    }

    private func getWordLevel(word: String) -> Int {
        guard !word.isDigit else { return 0 }
        let wordVariations = word.variations
        for (i, vset) in levelVocSets.enumerated() {
            if containsIn(vocSet: vset, words: wordVariations) {
                return i
            }
        }
        return 7
    }
}

extension DifficultyCalculator {
    func showVOCSetStatus() {
        let enSentences = getLines(filename: "en.txt")
        let jaSentences = getLines(filename: "ja.txt")
        var removeCount = 0
        var targetLevel = 0
        var levelSentenceCounts: [Int: Int] = [:]
        for (i, sentence) in enSentences.enumerated() {
            let sentenceLevel = getDifficulty(sentence: sentence)
            levelSentenceCounts[sentenceLevel] = (levelSentenceCounts[sentenceLevel] ?? 0) + 1
            if sentenceLevel == targetLevel % 200 {
                // print(sentenceLevel, sentence, "|", jaSentences[i])
                print(sentenceLevel, sentence)

                targetLevel += 1
            }
            if sentenceLevel > 10000 {
                removeCount += 1
            }
        }

        print("\nRemove Count: \(removeCount) / \(enSentences.count)")
        for i in 0 ... 24 {
            print(i, levelSentenceCounts[i]!)
        }
        // print(10000, levelSentenceCounts[100]!)
        print("\n")
    }

    func showUncoveredWords() {
        let enSentences = getLines(filename: "en.txt")
        // For tuning voc set
        // unknown word checking, current will remove about 3% of sentences (5396/180000)
        var unknownWords: [String] = []
        var exampleSentences: [String: String] = [:]
        for (_, sentence) in enSentences.enumerated() {
            let words = lemmatization(for: sentence)
            for word in words {
                if word.isDigit { continue }
                if !containsIn(vocSet: allVocSet, words: word.variations) {
                    unknownWords.append(word)
                    exampleSentences[word] = sentence
                }
            }
        }

        var unknownFrequency: [String: Int] = [:]
        for word in unknownWords {
            unknownFrequency[word] = (unknownFrequency[word] ?? 0) + 1
        }

        var wordFreqArray: [(word: String, count: Int)] = []
        for (key, value) in unknownFrequency {
            wordFreqArray.append((word: key, count: value))
        }

        wordFreqArray.sort {
            return $0.count > $1.count
        }

        var i = 1
        for (word, count) in wordFreqArray {
            if i % 10 == 1 {
                print("\n==\(i) \(count)==")
            }
            print(word, "|", exampleSentences[word]!)
            i = i + 1
        }
    }
}
