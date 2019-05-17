//
//  ViewController+addEnDifficulty.swift
//  sentencesVerifier
//
//  Created by Wangchou Lu on 5/17/31 H.
//  Copyright © 31 Heisei Lu, WangChou. All rights reserved.
//

import Foundation

extension ViewController {
    func updateEnSentencesDifficulty() {
        speaker = .alex
        loadWritableDb()
        startTime = now()
        for id in idToSentences.keys.sorted() {
            // perfect count filtering
            guard let syllablesLen = idToSyllablesLen[id] else { continue }
            guard syllablesLen <= syllablesLenLimit else { continue }
            let bothPerfectCount = bothPerfectCounts[syllablesLen] ?? 0
            let pairedVoicePerfectCount = pairedVoicePerfectCounts[syllablesLen] ?? 0
            let currentVoicePerfectCount = currentVoicePerfectCounts[syllablesLen] ?? 0
            if pairedVoicePerfectCount >= voicePerfectCountLimit { continue }
            if bothPerfectCount >= bothPerfectCountLimit { continue }
            if currentVoicePerfectCount >= voicePerfectCountLimit { continue }

            if idToScore[id] == 100 && idToPairedScore[id] == 100 {
                sentenceIds.append(id)
            }
        }
        sentences = getSentencesByIds(ids: sentenceIds)
        var difficultyCounts: [Int: Int] = [:]
        var maxDifficultySentences: [String] = []
        for i in 0 ..< sentenceIds.count {
            var difficulty = DifficultyCalculator.shred.getDifficulty(sentence: sentences[i])
            if difficulty > 10000 {
                difficulty = 10000
                maxDifficultySentences.append(sentences[i])
            }
            difficultyCounts[difficulty] = (difficultyCounts[difficulty] ?? 0) + 1
            updateEnDifficuty(id: sentenceIds[i], difficulty: difficulty)

            if i % 100 == 0 {
                print(i, String(format: "%.1f", now() - startTime), difficulty, sentences[i])
            }
        }
        for i in 0 ... 24 {
            if difficultyCounts[i] != nil {
                print(i, difficultyCounts[i]!)
            }
        }
        print("10000", difficultyCounts[10000]!)
        print("sentence count:", sentenceIds.count)
//        print("==========")
//        for s in maxDifficultySentences {
//            print(s)
//        }
    }
}
