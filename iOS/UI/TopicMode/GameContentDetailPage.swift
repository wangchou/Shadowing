//
//  GameContentDetailPage.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/13.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit
import Promises

private let context = GameContext.shared
private let i18n = I18n.shared

class GameContentDetailPage: UIViewController {
    static var isChallengeButtonDisabled = false

    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var challengeButton: UIButton!

    @IBOutlet weak var perfectCountLabel: UILabel!
    @IBOutlet weak var greatCountLabel: UILabel!
    @IBOutlet weak var goodCountLabel: UILabel!
    @IBOutlet weak var missedCountLabel: UILabel!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var peekButton: UIButton!

    @IBOutlet weak var topBarView: TopBarView!
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
        if IAPHelper.shared.products.isEmpty {
            IAPHelper.shared.requsestProducts()
        }
        titleLabel.text = context.dataSetKey
        peekButton.setTitle(i18n.chineseOrJapanese, for: .normal)

        if let gameRecord = findBestRecord(key: context.dataSetKey) {
            rankLabel.attributedText = getRankAttrText(rank: gameRecord.rank.rawValue, color: gameRecord.rank.color)

            progressLabel.attributedText = getProgressAttrText(progress: gameRecord.progress)

            perfectCountLabel.text = gameRecord.perfectCount.s
            greatCountLabel.text = gameRecord.greatCount.s
            goodCountLabel.text = gameRecord.goodCount.s
            missedCountLabel.text = (context.sentences.count - gameRecord.perfectCount - gameRecord.greatCount - gameRecord.goodCount).s
        } else {
            rankLabel.text = "?"
            rankLabel.attributedText = getRankAttrText(rank: "?", color: UIColor.white)
            progressLabel.attributedText = getProgressAttrText(progress: "??")
            perfectCountLabel.text = 0.s
            greatCountLabel.text = 0.s
            goodCountLabel.text = 0.s
            missedCountLabel.text = 0.s
        }
        challengeButton.roundBorder(borderWidth: 0, cornerRadius: 5, color: .clear)
        challengeButton.setTitleColor(UIColor.white.withAlphaComponent(0.6), for: .highlighted)

        // load furigana
        all(context.sentences.map {$0.furiganaAttributedString}).then {_ in
            self.tableView.reloadData()
        }
    }

    private func setupTopBar() {
        topBarView.titleLabel.text = "關  卡"
        topBarView.titleLabel.textColor = myWhite
        topBarView.backgroundColor = UIColor.black.withAlphaComponent(0)
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

    @IBAction func challenge(_ sender: Any) {
        guard !GameContentDetailPage.isChallengeButtonDisabled else { return }
        launchGame()
    }

    @IBAction func touchUpPeekButton(_ sender: Any) {
        context.gameSetting.isShowTranslationInPractice = !context.gameSetting.isShowTranslationInPractice
        saveGameSetting()
        tableView.reloadData()
    }

    private func launchGame() {
        if isUnderDailySentenceLimit() {
            launchStoryboard(self, "MessengerGame")
        }
    }
}

extension GameContentDetailPage: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return context.sentences.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "ContentTableCell", for: indexPath)
        guard let contentCell = cell as? SentencesTableCell else { print("detailCell convert error"); return cell }
        let sentence = context.sentences[indexPath.row]
        contentCell.update(sentence: sentence, isShowTranslate: context.gameSetting.isShowTranslationInPractice)

        return contentCell
    }
}

extension GameContentDetailPage: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if let cell = cell as? SentencesTableCell {
            cell.practiceSentence()
        }
    }
}
