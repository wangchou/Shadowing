//
//  ViewController+VerifyTopicSentences.swift
//  sentencesVerifier
//
//  Created by Wangchou Lu on 12/26/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation
import Cocoa
import Promises

var groupStartIdx = 0
var isGroupCorrect = true
extension ViewController {
    func verifyAllTopicSentences() {
        isInfiniteChallengePreprocessingMode = false
        sentences = inWork.components(separatedBy: "\n")

        for i in 0...sentences.count {
            sentenceIds.append(i)
        }

        prepareSpeak()
        speaker = .otoya
        scrollView.becomeFirstResponder()
        verifyNextSentence = verifyNextTopicSentence

        groupStartIdx = 0
        isGroupCorrect = true

        verifyNextSentence()
    }
}

func verifyNextTopicSentence() {
    let duration = "\(round(now() - startTime))s"
    let percentage = "\(round(100.0*Double(sentencesIdx)/Double(sentences.count)))%"
    vc.label.stringValue = "\(percentage) | \(duration) | \(sentencesIdx)/\(sentences.count)"

    vc.scrollView.becomeFirstResponder()

    func appendGroupText(isLast: Bool = false) {
        var groupText = ""
        for i in groupStartIdx..<sentencesIdx {
            groupText.append(sentences[i]+"\n")
        }
        if !isLast {
            groupText.append("\n")
        }
        if isGroupCorrect {
            vc.rightTextView.string += groupText
        } else {
            vc.wrongTextView.string += groupText
        }
    }

    guard sentencesIdx < sentences.count else {
        appendGroupText(isLast: true)
        return
    }

    let s = sentences[sentencesIdx]

    if s == "" {
        appendGroupText()
        isGroupCorrect = true
        sentencesIdx += 1
        groupStartIdx = sentencesIdx
        verifyNextTopicSentence()
        return
    }

    vc.textView.string = ""
    toggleSTT()
    Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
        speak(s)
    }
    sentencesIdx += 1
}
