//
//  GameContentDetailPage.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/13.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Firebase
import Foundation
import Promises
import UIKit

private let context = GameContext.shared

class TopicDetailPage: UIViewController {
    static var lastDisplayed: TopicDetailPage?
    static var isChallengeButtonDisabled = false
    var isViewReady = false

    @IBOutlet var rankLabel: UILabel!
    @IBOutlet var progressLabel: UILabel!
    @IBOutlet var skipPreviousButton: UIButton!
    @IBOutlet var challengeButton: UIButton!
    @IBOutlet var skipNextButton: UIButton!

    @IBOutlet var perfectTitleLabel: UILabel!
    @IBOutlet var greatTitleLabel: UILabel!
    @IBOutlet var goodTitleLabel: UILabel!
    @IBOutlet var missedTitleLabel: UILabel!

    @IBOutlet var perfectCountLabel: UILabel!
    @IBOutlet var greatCountLabel: UILabel!
    @IBOutlet var goodCountLabel: UILabel!
    @IBOutlet var missedCountLabel: UILabel!

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var peekButton: UIButton!

    @IBOutlet var topBarView: TopBarView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTopBar()
        tableView.register(
            UINib(nibName: "SentencesTableCell", bundle: nil),
            forCellReuseIdentifier: "ContentTableCell"
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = darkBackground
        isViewReady = true
        if IAPHelper.shared.products.isEmpty {
            IAPHelper.shared.requsestProducts()
        }
        render()
        TopicDetailPage.lastDisplayed = self
    }

    func render() {
        guard isViewReady else { return }
        tableView?.tableHeaderView?.backgroundColor = darkBackground
        titleLabel.text = getDataSetTitle(dataSetKey: context.dataSetKey)
        peekButton.setTitle(i18n.chineseOrJapanese, for: .normal)
        peekButton.titleLabel?.font = getBottomButtonFont()

        if let gameRecord = findBestRecord(dataSetKey: context.dataSetKey) {
            rankLabel.attributedText = getRankAttrText(rank: gameRecord.rank.rawValue, color: gameRecord.rank.color)

            progressLabel.attributedText = getProgressAttrText(progress: gameRecord.progress)

            perfectCountLabel.text = gameRecord.perfectCount.s
            greatCountLabel.text = gameRecord.greatCount.s
            goodCountLabel.text = gameRecord.goodCount.s
            missedCountLabel.text = (context.sentences.count - gameRecord.perfectCount - gameRecord.greatCount - gameRecord.goodCount).s
            perfectCountLabel.textColor = rgb(240, 240, 240)
            greatCountLabel.textColor = rgb(240, 240, 240)
            goodCountLabel.textColor = rgb(240, 240, 240)
            missedCountLabel.textColor = rgb(240, 240, 240)
        } else {
            rankLabel.text = "?"
            rankLabel.attributedText = getRankAttrText(rank: "?", color: UIColor.white)
            progressLabel.attributedText = getProgressAttrText(progress: "??")
            perfectCountLabel.text = 0.s
            greatCountLabel.text = 0.s
            goodCountLabel.text = 0.s
            missedCountLabel.text = 0.s
        }
        perfectTitleLabel.text = i18n.excellent
        greatTitleLabel.text = i18n.great
        goodTitleLabel.text = i18n.good
        missedTitleLabel.text = i18n.wrong
        missedTitleLabel.sizeToFit()

        challengeButton.setStyle(style: .darkAction)
        skipPreviousButton.setStyle(style: .darkAction)
        skipNextButton.setStyle(style: .darkAction)

        // load furigana
        all(context.sentences.map { $0.ja.furiganaAttributedString }).then { _ in
            self.tableView.reloadData()
        }
    }

    private func setupTopBar() {
        topBarView.titleLabel.text = i18n.challenge
        topBarView.titleLabel.textColor = myWhite
        topBarView.backgroundColor = .clear
        topBarView.leftButton.setIconImage(named: "round_arrow_back_ios_black_48pt", tintColor: UIColor(white: 255, alpha: 0.9))
        topBarView.rightButton.isHidden = true
        topBarView.bottomSeparator.backgroundColor = UIColor.white.withAlphaComponent(0.2)
    }

    func getProgressAttrText(progress: String) -> NSAttributedString {
        let attrText = NSMutableAttributedString()
        attrText.append(getStrokeText(progress, .black, strokeWidth: -1.5, strokColor: .white, font: UIFont.boldSystemFont(ofSize: 60)))
        attrText.append(getStrokeText("%", .white, strokeWidth: -1.5, strokColor: .black, font: UIFont.boldSystemFont(ofSize: 20)))

        return attrText
    }

    func getRankAttrText(rank: String, color: UIColor) -> NSAttributedString {
        let attrText = NSMutableAttributedString()
        attrText.append(getStrokeText(rank, color, strokeWidth: -1.5, strokColor: .black, font: UIFont.boldSystemFont(ofSize: 60)))

        return attrText
    }

    @objc func injected() {
        #if DEBUG
            viewDidLoad()
        #endif
    }

    @IBAction func challenge(_: Any) {
        guard !TopicDetailPage.isChallengeButtonDisabled else { return }
        launchGame()
    }

    @IBAction func onSkipPreviousButtonClicked(_: Any) {
        context.loadPrevousChallenge()
        render()
    }

    @IBAction func onSkipNextButtonClicked(_: Any) {
        context.loadNextChallenge()
        render()
    }

    @IBAction func touchUpPeekButton(_: Any) {
        context.gameSetting.isShowTranslationInPractice = !context.gameSetting.isShowTranslationInPractice
        saveGameSetting()
        tableView.reloadData()
    }

    private func launchGame() {
        context.gameMode = .topicMode
        if isUnderDailySentenceLimit() {
            #if !(targetEnvironment(macCatalyst))
            Analytics.logEvent("challenge_topic_\(gameLang.prefix)", parameters: nil)
            #endif
            launchVC(Messenger.id, self, isOverCurrent: false)
        }
    }
}

extension TopicDetailPage: UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return context.sentences.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContentTableCell", for: indexPath)
        guard let contentCell = cell as? SentencesTableCell else { print("detailCell convert error"); return cell }
        let sentence = context.sentences[indexPath.row]
        contentCell.update(sentence: sentence,
                           isShowTranslate: context.gameSetting.isShowTranslationInPractice,
                           isTopicDetail: true)

        return contentCell
    }
}

extension TopicDetailPage: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if let cell = cell as? SentencesTableCell {
            cell.practiceSentence()
        }
    }
}
