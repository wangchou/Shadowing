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

import Foundation
// SOP => 1~6 50句 大概花一小時
// 1. 找句子 > 20句
// 2. 整批看 otoya & kyoko 單句能不能念出來
// 3. 移除/修正不能唸的
// 4. 拆成短句組
// 5. 整批看 otoya & kyoko 能不能念出來
// 6. 移除/修正不能唸的
// 7. 全部弄完後，累積超過 500句。再加上中文翻譯
let inWork =
"""
"""
var isGroupMode = false
var groupStartIdx = 0
var isGroupCorrect = true
extension ViewController {
    func verifyAllTopicSentences() {
        isInfiniteChallengePreprocessingMode = false
        sentences = grammarN5.joined(separator: "\n")
                             .components(separatedBy: "\n")
                             .filter {s in
                                return !s.hasPrefix("#") && (isGroupMode || s != "" )
                             }
                             .map {s in
                                let subStrings = s.components(separatedBy: "|")
                                return subStrings[0]
                             }

        for i in 0...sentences.count {
            sentenceIds.append(i)
        }

        prepareSpeak()
        //speaker = .otoya
        speaker = .kyoko
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
        if !isLast && isGroupMode {
            groupText.append("\n")
        }
        if isGroupCorrect {
            vc.rightTextView.string += groupText
        } else {
            vc.wrongTextView.string += groupText
        }
    }

    if !isGroupMode {
        appendGroupText()
        isGroupCorrect = true
        groupStartIdx = sentencesIdx
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
