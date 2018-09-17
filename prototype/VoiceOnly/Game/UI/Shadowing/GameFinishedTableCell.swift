//
//  GameFinishedTableCell.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/22.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit
import Promises

class GameFinishedTableCell: UITableViewCell {
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var sentenceLabel: FuriganaLabel!
    @IBOutlet weak var userSaidSentenceLabel: FuriganaLabel!
    @IBOutlet weak var practiceButton: UIButton!

    var startTime: Double = 0
    var targetString: String {
        return sentenceLabel.text ?? " "
    }
    var tableView: UITableView? {
        var view = superview
        while let tmpView = view, tmpView.isKind(of: UITableView.self) == false {
            view = tmpView.superview
        }
        return view as? UITableView
    }

    @IBAction func practiceButtonTapped(_ sender: Any) {
        prepareForSpeaking()
        Game.speakString(string: targetString)
            .then(listenPart)
            .then(afterListeningCalculateScore)
            .then(updateUIByScore)
    }

    func update(sentence: String, gameRecord: GameRecord?) {
        sentenceLabel.widthPadding = 4
        userSaidSentenceLabel.widthPadding = 4

        if let tokenInfos = kanaTokenInfosCacheDictionary[sentence] {
            sentenceLabel.attributedText = getFuriganaString(tokenInfos: tokenInfos)
        } else {
            sentenceLabel.text = sentence
        }

        let userSaidSentence = userSaidSentences[sentence] ?? ""
        if let tokenInfos = kanaTokenInfosCacheDictionary[userSaidSentence] {
            userSaidSentenceLabel.attributedText = getFuriganaString(tokenInfos: tokenInfos)
        } else {
            userSaidSentenceLabel.text = userSaidSentence
        }

        if let gameRecord = gameRecord,
            let score = gameRecord.sentencesScore[sentence] {
            scoreLabel.text = score.valueText
            scoreLabel.textColor = score.color
            userSaidSentenceLabel.backgroundColor = score.color
            userSaidSentenceLabel.isHidden = score.type == .perfect ? true : false
        } else {
            scoreLabel.text = "無分"
            scoreLabel.textColor = myGray
            userSaidSentenceLabel.isHidden = true
        }
    }

    private func prepareForSpeaking() {
        tableView?.beginUpdates()
        userSaidSentenceLabel.text = " "
        userSaidSentenceLabel.backgroundColor = UIColor.white
        userSaidSentenceLabel.isHidden = false
        startTime = getNow()
        tableView?.endUpdates()
    }

    private func listenPart() -> Promise<String> {
        let duration = getNow() - startTime + Double(pauseDuration)
        tableView?.beginUpdates()
        userSaidSentenceLabel.text = " listening..."
        userSaidSentenceLabel.textColor = UIColor.red
        tableView?.endUpdates()

        return listen(duration: duration, langCode: targetString.langCode)
    }

    private func afterListeningCalculateScore(userSaidSentence: String) -> Promise<Score> {
        tableView?.beginUpdates()
        userSaidSentences[targetString] = userSaidSentence
        userSaidSentenceLabel.textColor = UIColor.black
        if let tokenInfos = kanaTokenInfosCacheDictionary[userSaidSentence] {
            userSaidSentenceLabel.attributedText = getFuriganaString(tokenInfos: tokenInfos)
        } else {
            userSaidSentenceLabel.text = userSaidSentence
        }
        tableView?.endUpdates()

        return calculateScore(targetString, userSaidSentence)
    }

    private func updateUIByScore(score: Score) {
        tableView?.beginUpdates()
        scoreLabel.text = score.valueText
        scoreLabel.textColor = score.color
        userSaidSentenceLabel.backgroundColor = score.color
        userSaidSentenceLabel.isHidden = score.type == .perfect ? true : false
        tableView?.endUpdates()
    }
}
