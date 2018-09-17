//
//  SentencesTableCell.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 9/17/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import UIKit
import Promises

class SentencesTableCell: UITableViewCell {
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var sentenceLabel: FuriganaLabel!
    @IBOutlet weak var userSaidSentenceLabel: FuriganaLabel!
    @IBOutlet weak var practiceButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        practiceButton.roundBorder(borderWidth: 0.5, cornerRadius: 5, color: UIColor.blue.withAlphaComponent(0.1))
        practiceButton.backgroundColor = UIColor.blue.withAlphaComponent(0.03)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        // super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

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
        var speaker: ChatSpeaker? = nil
        if targetString.langCode == "ja" {
            speaker = ChatSpeaker.man1
        }
        Game.speakString(string: targetString, speaker: speaker)
            .then(listenPart)
            .then(afterListeningCalculateScore)
            .then(updateUIByScore)
    }

    func update(sentence: String) {
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

        if let score = sentenceScores[sentence] {
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
        userSaidSentenceLabel.text = "listening..."
        userSaidSentenceLabel.textColor = UIColor.red
        tableView?.endUpdates()

        // print("listenPart", duration, targetString, targetString.langCode)

        return listen(duration: duration, langCode: targetString.langCode)
    }

    private func afterListeningCalculateScore(userSaidSentence: String) -> Promise<Score> {
        userSaidSentences[targetString] = userSaidSentence

        // print("afterListeningCalcScore", userSaidSentence )

        return calculateScore(targetString, userSaidSentence)
    }

    private func updateUIByScore(score: Score) {
        tableView?.beginUpdates()
        let userSaidSentence = userSaidSentences[targetString] ?? ""
        userSaidSentenceLabel.textColor = UIColor.black
        if let tokenInfos = kanaTokenInfosCacheDictionary[userSaidSentence] {
            userSaidSentenceLabel.attributedText = getFuriganaString(tokenInfos: tokenInfos)
        } else {
            userSaidSentenceLabel.text = userSaidSentence
        }
        scoreLabel.text = score.valueText
        scoreLabel.textColor = score.color
        userSaidSentenceLabel.backgroundColor = score.color
        userSaidSentenceLabel.isHidden = score.type == .perfect ? true : false
        tableView?.endUpdates()

        sentenceScores[targetString] = score
        saveUserSaidSentencesAndScore()
        // speak feedback
        _ = oren(score.text, rate: normalRate)
        // print("updateUIByScore", score.value)
    }
}
