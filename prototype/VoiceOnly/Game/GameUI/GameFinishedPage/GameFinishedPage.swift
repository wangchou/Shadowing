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

private let gridCount = 48
class GameFinishedPage: UIViewController {
    var gridSystem: GridSystem = GridSystem(gridCount: gridCount)

    @IBOutlet weak var reportView: GameReportView!

    @objc func injected() {
        #if DEBUG
        viewWillAppear(false)
        #endif
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reportView.viewWillAppear()
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
            finishedCell.scoreLabel.text = score.valueText
            finishedCell.scoreLabel.textColor = score.color
            finishedCell.userSaidSentenceLabel.backgroundColor = score.color
            finishedCell.userSaidSentenceLabel.isHidden = score.type == .perfect ? true : false
        } else {
            finishedCell.scoreLabel.text = "無分"
            finishedCell.scoreLabel.textColor = myGray
            finishedCell.userSaidSentenceLabel.isHidden = true
        }

        return finishedCell
    }
}
