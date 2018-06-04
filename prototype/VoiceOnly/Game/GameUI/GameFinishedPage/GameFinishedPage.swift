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

    @objc func injected() {
        #if DEBUG
        viewWillAppear(false)
        #endif
    }

    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .lightContent
        super.viewWillAppear(animated)
        reportView.removeAllSubviews()
        reportView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        let frame = CGRect(x: 0, y: 0, width: screen.width, height: screen.width * 1.1)
        reportView.frame = frame
        gridSystem = GridSystem(axis: .horizontal, gridCount: gridCount, bounds: frame)

        guard let record = context.gameRecord else { return }

        addRoundRect(x: 2, y: 4, w: 44, h: 37, color: myLightText, radius: 15, backgroundColor: UIColor.black.withAlphaComponent(0.6))

        addText(context.dataSetKey, x: 4, y: 5, lineHeight: 6)

        let y = 12
        addText("達成率", x: 4, y: y, lineHeight: 2)
        let progress = getAttrText([
            ( record.progress, .white, getFontSize(h: 12)),
            ( "%", .lightGray, getFontSize(h: 4))
        ])
        addAttrText(progress, x: 4, y: y, lineHeight: 12)

        addText("Rank", x: 28, y: y, lineHeight: 2)
        addText(record.rank.rawValue, color: getRankColor(rank: record.rank), x: 28, y: y, lineHeight: 12)

        addText("正解 \(record.perfectCount) | すごい \(record.greatCount) | いいね \(record.goodCount) | ミス \(record.missedCount)", x: 4, y: 22)

        addRoundRect(x: 20, y: 26, w: 20, h: 4, color: myBlue)
        addText("+\(record.exp) EXP", x: 21, y: 26, lineHeight: 4)

        let goldText = getAttrText([
            ( "+\(record.gold)", .white, getFontSize(h: 4)),
            ( " G", myOrange, getFontSize(h: 4))
        ])
        addRoundRect(x: 20, y: 33, w: 20, h: 4, color: myOrange)
        addAttrText(goldText, x: 21, y: 33, lineHeight: 4)

        addBackButton()

        context.gameCharacter.gold += record.gold
        context.gameCharacter.exp += record.exp
        saveGameCharacter()
    }

    func addRoundRect(x: Int, y: Int, w: Int, h: Int, color: UIColor, radius: CGFloat? = nil, backgroundColor: UIColor? = nil) {
        let roundRect = UIView()
        gridSystem.frame(roundRect, x: x, y: y, w: w, h: h)
        let radius = radius ?? h.c * gridSystem.step / 2
        roundRect.roundBorder(borderWidth: 3, cornerRadius: radius, color: color)
        if let backgroundColor = backgroundColor {
            roundRect.backgroundColor = backgroundColor
        }
        reportView.addSubview(roundRect)
    }

    func addText(_ text: String, color: UIColor = .white, x: Int, y: Int, lineHeight: Int = 3) {
        let fontSize = getFontSize(h: lineHeight)
        let font = MyFont.bold(ofSize: fontSize)
        addAttrText(
            getText(text, color: color, strokeWidth: -1.5, strokeColor: .white, font: font),
            x: x,
            y: y,
            lineHeight: lineHeight
        )
    }

    func addAttrText(_ attrText: NSAttributedString, x: Int, y: Int, lineHeight: Int = 3) {
        let label = UILabel()
        label.attributedText = attrText
        gridSystem.frame(label, x: x, y: y, w: gridCount - x, h: lineHeight)
        reportView.addSubview(label)
    }

    func getFontSize(h: Int) -> CGFloat {
        return h.c * gridSystem.step * 0.7
    }

    func addDigits(_ text: String, x: Int, y: Int, lineHeight: Int = 3) {
        let label = UILabel()
        let fontSize = getFontSize(h: lineHeight)
        label.font = UIFont.monospacedDigitSystemFont(ofSize: fontSize, weight: UIFont.Weight.medium)
        label.text = text
        label.textColor = myWhite
        gridSystem.frame(label, x: x, y: y, w: gridCount - x, h: lineHeight)
        reportView.addSubview(label)
    }

    func addBackButton() {
        let backButton = UIButton()
        backButton.setTitle("戻 る", for: .normal)
        backButton.backgroundColor = .red
        backButton.titleLabel?.font = MyFont.regular(ofSize: gridSystem.step * 4)
        backButton.titleLabel?.textColor = myLightText
        backButton.roundBorder(borderWidth: 3, cornerRadius: 15, color: UIColor.white.withAlphaComponent(0.5))

        let backButtonTap = UITapGestureRecognizer(target: self, action: #selector(self.backButtonTapped))
        backButton.addGestureRecognizer(backButtonTap)
        gridSystem.frame(backButton, x: 2, y: 43, w: 44, h: 8)
        reportView.addSubview(backButton)
    }

    @objc func backButtonTapped() {
        launchStoryboard(self, "MainViewController")
        UIApplication.shared.statusBarStyle = .default
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
