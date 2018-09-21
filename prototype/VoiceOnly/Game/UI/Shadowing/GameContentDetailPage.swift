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

class GameContentDetailPage: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var challengeButton: UIButton!
    @IBOutlet weak var backButton: UIButton!

    @IBOutlet weak var perfectCountLabel: UILabel!
    @IBOutlet weak var greatCountLabel: UILabel!
    @IBOutlet weak var goodCountLabel: UILabel!
    @IBOutlet weak var missedCountLabel: UILabel!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var peekButton: UIButton!

    @IBOutlet weak var topBarView: TopBarView!
    override func viewDidLoad() {
        super.viewDidLoad()
        topBarView.titleLabel.text = context.dataSetKey
        topBarView.backgroundColor = UIColor.black.withAlphaComponent(0)
        topBarView.leftButton.setTitleColor(myWhite, for: .normal)
        topBarView.rightButton.setTitle("關閉", for: .normal)
        topBarView.rightButton.setTitleColor(myWhite, for: .normal)
        topBarView.customOnRightButtonClicked = {
            self.dismiss(animated: true, completion: nil)
        }
        tableView.register(
            UINib(nibName: "SentencesTableCell", bundle: nil),
            forCellReuseIdentifier: "ContentTableCell"
        )

        titleLabel.text = context.dataSetKey
        if let gameRecord = findBestRecord(key: context.dataSetKey) {
            rankLabel.text = gameRecord.rank.rawValue
            rankLabel.textColor = gameRecord.rank.color

            progressLabel.attributedText = getProgressAttrText(progress: gameRecord.progress)

            perfectCountLabel.text = gameRecord.perfectCount.s
            greatCountLabel.text = gameRecord.greatCount.s
            goodCountLabel.text = gameRecord.goodCount.s
            missedCountLabel.text = (context.sentences.count - gameRecord.perfectCount - gameRecord.greatCount - gameRecord.goodCount).s
        } else {
            rankLabel.text = "?"
            progressLabel.attributedText = getProgressAttrText(progress: "??")
            perfectCountLabel.text = 0.s
            greatCountLabel.text = 0.s
            goodCountLabel.text = 0.s
            missedCountLabel.text = 0.s
        }
        challengeButton.roundBorder(borderWidth: 0, cornerRadius: 3, color: UIColor.black)
        backButton.roundBorder(borderWidth: 0, cornerRadius: 3, color: UIColor.black)

        // load furigana
        all(context.sentences.map {$0.string.furiganaAttributedString}).then {_ in
            self.tableView.reloadData()
        }
    }

    func getProgressAttrText(progress: String) -> NSAttributedString {
        let attrText = NSMutableAttributedString()
        attrText.append(getStrokeText(progress, .black, strokeWidth: -1.5, strokColor: .lightGray, font: UIFont.boldSystemFont(ofSize: 60)))
        attrText.append(getStrokeText("%", .white, strokeWidth: 0, strokColor: .black, font: UIFont.boldSystemFont(ofSize: 20)))

        return attrText
    }

    @objc func injected() {
        #if DEBUG
            viewDidLoad()
        #endif
    }

    @IBAction func backButtonClicked(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }

    @IBAction func challenge(_ sender: Any) {
        context.gameFlowMode = .shadowing
        launchGame()
    }

    @IBAction func touchUpPeekButton(_ sender: Any) {
        context.gameSetting.isUsingTranslation = !context.gameSetting.isUsingTranslation
        saveGameSetting()
        tableView.reloadData()
    }

    private func launchGame() {
        launchStoryboard(self, "MessengerGame")
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
        let sentence = context.sentences[indexPath.row].string
        contentCell.update(sentence: sentence, isShowTranslate: context.gameSetting.isUsingTranslation)

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
