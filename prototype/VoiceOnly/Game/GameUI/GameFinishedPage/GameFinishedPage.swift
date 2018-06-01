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
    var gridSystem: GridSystem = GridSystem()

    @IBOutlet weak var reportView: UIView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reportView.removeAllSubviews()
        reportView.backgroundColor = UIColor.black
        gridSystem = GridSystem(axis: .horizontal, gridCount: gridCount, bounds: reportView.frame)

        guard var record = context.gameRecord else { return }
        addText(context.dataSetKey, x: 2, y: 0, lineHeight: 6)

        record.perfectCount = 15
        record.greatCount = 4
        record.goodCount = 5
        record.playDuration = 150
        addText("達成率", x: 2, y: 6, lineHeight: 2)
        addText(record.progress, x: 2, y: 6, lineHeight: 12)
        addText("Rank", x: 28, y: 6, lineHeight: 2)
        addText(record.rank.rawValue, color: getRankColor(rank: record.rank), x: 28, y: 6, lineHeight: 12)
        addText("正解 \(record.perfectCount) | すごい \(record.greatCount) | いいね \(record.goodCount) | ミス \(record.missedCount)", x: 2, y: 17)

        addRoundRect(x: 18, y: 22, w: 28, h: 6, color: myBlue)
        addText("+\(record.exp) EXP", x: 19, y: 22, lineHeight: 6)

        addRoundRect(x: 18, y: 29, w: 28, h: 6, color: myOrange)
        addText("+\(record.gold) G", x: 19, y: 29, lineHeight: 6)
    }

    func addRoundRect(x: Int, y: Int, w: Int, h: Int, color: UIColor = .white) {
        let roundRect = UIView()
        gridSystem.frame(roundRect, x: x, y: y, w: w, h: h)
        roundRect.roundBorder(borderWidth: 3, cornerRadius: h.c * gridSystem.step / 2, color: color)
        reportView.addSubview(roundRect)
    }

    func addText(_ text: String, color: UIColor = .white, x: Int, y: Int, lineHeight: Int = 3) {
        let label = UILabel()
        let fontSize = lineHeight.c * gridSystem.step * 0.7
        let font = MyFont.bold(ofSize: fontSize)
        label.attributedText = getText(text, color: color, strokeWidth: -1.5, strokeColor: .gray, font: font)
        gridSystem.frame(label, x: x, y: y, w: gridCount - x, h: lineHeight)
        reportView.addSubview(label)
    }

    func addDigits(_ text: String, x: Int, y: Int, lineHeight: Int = 3) {
        let label = UILabel()
        let fontSize = lineHeight.c * gridSystem.step * 0.7
        label.font = UIFont.monospacedDigitSystemFont(ofSize: fontSize, weight: UIFont.Weight.medium)
        label.text = text
        label.textColor = myWhite
        gridSystem.frame(label, x: x, y: y, w: gridCount - x, h: lineHeight)
        reportView.addSubview(label)
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
