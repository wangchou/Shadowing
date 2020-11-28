//
//  SentencesTableCell.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 9/17/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Promises
import UIKit
// import AudioToolbox
// AudioServicesPlaySystemSound(1116)

private let context = GameContext.shared

class SentencesTableCell: UITableViewCell {
    static var id = "ContentTableCell"
    static var isPracticing: Bool = false
    private var buttonColor = rgb(42, 163, 239)
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var sentenceLabel: FuriganaLabel!
    @IBOutlet var userSaidSentenceLabel: FuriganaLabel!
    @IBOutlet var practiceButton: UIButton!
    @IBOutlet var translationTextView: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        practiceButton.roundBorder(radius: 5)
        practiceButton.backgroundColor = buttonColor
        practiceButton.setTitleColor(rgb(50, 50, 50), for: .normal)
        practiceButton.setTitleColor(.lightGray, for: .disabled)

        addTapGestureRecognizer { [weak self] in
            self?.practiceSentence()
        }
    }

    var targetString: String = ""

    private var startTime: Double = 0
    private var ttsFixes: [(String, String)] = []

    private var tableView: UITableView? {
        var view = superview
        while let tmpView = view, tmpView.isKind(of: UITableView.self) == false {
            view = tmpView.superview
        }
        return view as? UITableView
    }

    @IBAction func practiceButtonTapped(_: Any) {
        practiceSentence()
    }

    func practiceSentence() {
        stopCountDown()
        guard SentencesTableCell.isPracticing != true else { return }
        startEventObserving(self)
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
                SentencesTableCell.isPracticing = false
                TopicDetailPage.isChallengeButtonDisabled = false
                SpeechEngine.shared.monitoringOff()
                SpeechEngine.shared.stop(isStopTTS: false)
                self.practiceButton.backgroundColor = self.buttonColor
                stopEventObserving(self)
            }
    }

    func update(sentence: Sentence, isShowTranslate: Bool = false, isTopicDetail: Bool = false) {
        targetString = sentence.origin
        ttsFixes = sentence.ttsFixes
        sentenceLabel.widthPadding = 4
        userSaidSentenceLabel.widthPadding = 4
        translationTextView.textContainerInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)

        if let tokenInfos = kanaTokenInfosCacheDictionary[sentence.origin] {
            sentenceLabel.attributedText = getFuriganaString(tokenInfos: tokenInfos)
        } else {
            sentenceLabel.text = sentence.origin
        }

        translationTextView.text = isTopicDetail ? sentence.cmn : sentence.translation

        if isShowTranslate, translationTextView.text != "" {
            sentenceLabel.alpha = 0
            translationTextView.alpha = 1
        } else {
            sentenceLabel.alpha = 1
            translationTextView.alpha = 0
        }

        let userSaidSentence = userSaidSentences[sentence.origin] ?? ""
        if let tokenInfos = kanaTokenInfosCacheDictionary[userSaidSentence] {
            userSaidSentenceLabel.attributedText = getFuriganaString(tokenInfos: tokenInfos)
        } else {
            userSaidSentenceLabel.text = userSaidSentence
        }

        if let score = sentenceScores[sentence.origin] {
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
        prepareForSpeaking()
        return teacherSay(targetString,
                          rate: context.gameSetting.practiceSpeed,
                          ttsFixes: ttsFixes)
    }

    private func prepareForSpeaking() {
        tableView?.beginUpdates()
        scoreLabel.text = ""
        userSaidSentences[targetString] = ""
        sentenceScores[targetString] = nil
        userSaidSentenceLabel.isHidden = false
        userSaidSentenceLabel.text = i18n.listening
        userSaidSentenceLabel.textColor = UIColor.white
        userSaidSentenceLabel.backgroundColor = UIColor.white
        tableView?.endUpdates()
    }

    private func listenPart() -> Promise<String> {
        if !context.gameSetting.isShowTranslationInPractice {
            if let tokenInfos = kanaTokenInfosCacheDictionary[targetString] {
                sentenceLabel.attributedText = getFuriganaString(tokenInfos: tokenInfos)
            } else {
                sentenceLabel.text = targetString
            }
            FuriganaLabel.clearHighlighRange()
        }
        stopEventObserving(self)

        func prepareListening() {
            tableView?.beginUpdates()
            userSaidSentenceLabel.textColor = UIColor.red
            tableView?.endUpdates()
        }

        func updateUIAfterListeningFor(duration: TimeInterval) {
            Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
                DispatchQueue.main.async {
                    self.tableView?.beginUpdates()
                    self.userSaidSentenceLabel.textColor = .clear
                    self.tableView?.endUpdates()
                }
            }
        }

        let duration = getNow() - startTime + Double(practicePauseDuration)
        prepareListening()
        updateUIAfterListeningFor(duration: duration)
        print("listen for \(targetString): ", duration)
        return SpeechEngine.shared.listen(duration: duration)
    }

    private func calculateScorePart(userSaidSentence: String) -> Promise<Score> {
        userSaidSentences[targetString] = userSaidSentence
        return calculateScore(targetString, userSaidSentence)
    }

    private func updateUIByScore(score: Score) -> Promise<Void> {
        _ = assisantSay(score.text)
        SpeechEngine.shared.stop(isStopTTS: false)

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

        return fulfilledVoidPromise()
    }
}
