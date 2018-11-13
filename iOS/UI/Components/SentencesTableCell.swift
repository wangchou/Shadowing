//
//  SentencesTableCell.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 9/17/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import UIKit
import Promises

private let context = GameContext.shared

class SentencesTableCell: UITableViewCell {
    static var isPracticing: Bool = false
    private var buttonColor = myBlue.withAlphaComponent(0.5)
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
        guard SentencesTableCell.isPracticing != true else { return }
        SentencesTableCell.isPracticing = true
        GameContentDetailPage.isChallengeButtonDisabled = true
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
                GameContentDetailPage.isChallengeButtonDisabled = false
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

        var translationsDict = (gameLang == .jp && context.contentTab == .topics) ?
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
            scoreLabel.text = "無分"
            scoreLabel.textColor = myGray
            userSaidSentenceLabel.isHidden = true
        }
    }
}

// MARK: Private Methods
extension SentencesTableCell {
    private func speakPart() -> Promise<Void> {
        guard context.gameSetting.isUsingGuideVoice else { return fulfilledVoidPromise() }
        startTime = getNow()
        let promise = teacherSay(targetString, rate: context.gameSetting.practiceSpeed)
        prepareForSpeaking()
        return promise
    }

    private func prepareForSpeaking() {
        tableView?.beginUpdates()
        userSaidSentenceLabel.text = " "
        userSaidSentenceLabel.backgroundColor = UIColor.white
        userSaidSentenceLabel.isHidden = false
        tableView?.endUpdates()
    }

    private func listenPart() -> Promise<String> {
        func prepareListening() {
            tableView?.beginUpdates()
            userSaidSentenceLabel.text = "listening..."
            userSaidSentenceLabel.textColor = UIColor.red
            tableView?.endUpdates()
        }

        if !context.gameSetting.isUsingGuideVoice {
            return context.calculatedSpeakDuration.then { duration -> Promise<String> in
                prepareListening()
                return SpeechEngine.shared.listen(duration: Double(duration))
            }
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
        saveGameMiscData()
        return assisantSay(score.text)
    }
}
