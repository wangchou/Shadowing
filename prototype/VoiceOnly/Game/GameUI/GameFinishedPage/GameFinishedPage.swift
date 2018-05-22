//
//  GameFinishedPage.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/22.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

private let context = GameContext.shared

class GameFinishedPage: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var perfectCountLabel: UILabel!
    @IBOutlet weak var greatCountLabel: UILabel!
    @IBOutlet weak var goodCountLabel: UILabel!
    @IBOutlet weak var missedCountLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "  " + context.dataSetKey
        guard let record = context.gameRecord else { return }
        rankLabel.text = record.rank
        progressLabel.text = record.progress
        perfectCountLabel.text = record.perfectCount.s
        greatCountLabel.text = record.greatCount.s
        goodCountLabel.text = record.goodCount.s
        missedCountLabel.text = (context.sentences.count - record.perfectCount - record.greatCount - record.goodCount).s
    }

    @IBAction func finshedButtonClicked(_ sender: Any) {
        launchStoryboard(self, "ContentViewController")
    }
}

extension GameFinishedPage: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return context.sentences.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "FinishedSentenceCell", for: indexPath)
        guard let finishedCell = cell as? GameFinishedTableCell else { print("detailCell convert error"); return cell }
        let sentence = context.sentences[indexPath.row]

        if let tokenInfos = kanaTokenInfosCacheDictionary[sentence] {
            finishedCell.sentenceLabel.attributedText = getFuriganaString(tokenInfos: tokenInfos)
        } else {
            finishedCell.sentenceLabel.text = sentence
        }

        let userSaidSentence = context.userSaidSentences[indexPath.row]
        if let tokenInfos = kanaTokenInfosCacheDictionary[userSaidSentence] {
            finishedCell.userSaidSentenceLabel.attributedText = getFuriganaString(tokenInfos: tokenInfos)
        } else {
            finishedCell.userSaidSentenceLabel.text = userSaidSentence
        }

        if let gameRecord = context.gameRecord,
           let score = gameRecord.sentencesScore[sentence] {
            finishedCell.scoreLabel.text = "\(score)分"
            var color = myRed
            if score >= 80 {
                color = myGreen
            } else if score >= 60 {
                color = myOrange
            }
            finishedCell.scoreLabel.textColor = color
            finishedCell.userSaidSentenceLabel.backgroundColor = color
            finishedCell.userSaidSentenceLabel.isHidden = score == 100 ? true : false
        } else {
            finishedCell.scoreLabel.text = "無分"
            finishedCell.scoreLabel.textColor = rgb(192, 192, 192)
            finishedCell.userSaidSentenceLabel.isHidden = true
        }

        return finishedCell
    }
}
