//
//  SentencesTableCell.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 9/17/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import UIKit
import Promises
//import AudioToolbox
//AudioServicesPlaySystemSound(1116)

private let context = GameContext.shared

class SentencesTableCell: UITableViewCell {
    static var id = "ContentTableCell"
    static var isPracticing: Bool = false
    private var buttonColor = rgb(42, 163, 239)
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var sentenceLabel: FuriganaLabel!
    @IBOutlet weak var userSaidSentenceLabel: FuriganaLabel!
    @IBOutlet weak var practiceButton: UIButton!
    @IBOutlet weak var translationTextView: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        practiceButton.roundBorder(borderWidth: 0, cornerRadius: 5, color: .clear)
        practiceButton.backgroundColor = buttonColor
        practiceButton.setTitleColor(rgb(50, 50, 50), for: .normal)
        practiceButton.setTitleColor(.lightGray, for: .disabled)

        self.addTapGestureRecognizer(action: practiceSentence)
    }

    private var startTime: Double = 0
    private var targetString: String {
        return sentenceLabel.text ?? " "
    }

    private var tableView: UITableView? {
        var view = superview
        while let tmpView = view, tmpView.isKind(of: UITableView.self) == false {
            view = tmpView.superview
        }
        return view as? UITableView
    }

    @IBAction func practiceButtonTapped(_ sender: Any) {
        practiceSentence()
    }

    func practiceSentence() {
        stopCountDown()
        guard SentencesTableCell.isPracticing != true else { return }
        SentencesTableCell.isPracticing = true
        TopicDetailPage.isChallengeButtonDisabled = true
        isUserInteractionEnabled = false
        practiceButton.isEnabled = false
        practiceButton.backgroundColor = UIColor.lightGray.withAlphaComponent(0.4)
        SpeechEngine.shared.start()
        if context.gameSetting.isMointoring { SpeechEngine.shared.monitoringOn() }
        speakPart()
            .then(listenPart)
            .then(calculateScorePart)
            .then(updateUIByScore)
            .catch { _ in
                self.userSaidSentenceLabel.text = ""
            }
            .always {
                self.isUserInteractionEnabled = true
                self.practiceButton.isEnabled = true
                self.practiceButton.backgroundColor = self.buttonColor
                SentencesTableCell.isPracticing = false
                TopicDetailPage.isChallengeButtonDisabled = false
                SpeechEngine.shared.monitoringOff()
            }
    }

    func update(sentence: String, isShowTranslate: Bool = false) {
        sentenceLabel.widthPadding = 4
        userSaidSentenceLabel.widthPadding = 4

        if let tokenInfos = kanaTokenInfosCacheDictionary[sentence] {
            sentenceLabel.attributedText = getFuriganaString(tokenInfos: tokenInfos)
        } else {
            sentenceLabel.text = sentence
        }

        var translationsDict = (gameLang == .jp && context.gameMode == .topicMode) ?
                            chTranslations : translations

        if let translation = translationsDict[sentence] {
            translationTextView.text = translation
        } else {
            translationTextView.text = ""
        }

        if isShowTranslate, translationsDict[sentence] != nil {
            sentenceLabel.alpha = 0
            translationTextView.alpha = 1
        } else {
            sentenceLabel.alpha = 1
            translationTextView.alpha = 0
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
            scoreLabel.text = i18n.noScore
            scoreLabel.textColor = myGray
            userSaidSentenceLabel.isHidden = true
        }
    }
}

// MARK: Private Methods
extension SentencesTableCell {
    private func speakPart() -> Promise<Void> {
        startTime = getNow()
        let promise = teacherSay(targetString, rate: context.gameSetting.practiceSpeed)
        prepareForSpeaking()
        return promise
    }

    private func prepareForSpeaking() {
        tableView?.beginUpdates()
        scoreLabel.text = ""
        userSaidSentences[targetString] = ""
        sentenceScores[targetString] = nil
        userSaidSentenceLabel.isHidden = false
        userSaidSentenceLabel.text = "listening..."
        userSaidSentenceLabel.textColor = UIColor.white
        userSaidSentenceLabel.backgroundColor = UIColor.white
        tableView?.endUpdates()
    }

    private func listenPart() -> Promise<String> {
        func prepareListening() {
            tableView?.beginUpdates()
            userSaidSentenceLabel.textColor = UIColor.red
            tableView?.endUpdates()
        }

        let duration = getNow() - startTime + Double(practicePauseDuration)
        prepareListening()
        return SpeechEngine.shared.listen(duration: duration)
    }

    private func calculateScorePart(userSaidSentence: String) -> Promise<Score> {
        userSaidSentences[targetString] = userSaidSentence
        return calculateScore(targetString, userSaidSentence)
    }

    private func updateUIByScore(score: Score) -> Promise<Void> {
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
        postEvent(.practiceSentenceCalculated)
        saveGameMiscData()
        return assisantSay(score.text)
    }
}
