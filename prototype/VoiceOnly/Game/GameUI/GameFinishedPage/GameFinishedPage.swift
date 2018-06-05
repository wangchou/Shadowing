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

    @IBOutlet weak var reportView: UIView!

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
        reportView.removeAllSubviews()

        reportView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        let frame = CGRect(x: 0, y: 0, width: screen.width, height: screen.width * 1.2)
        reportView.frame = frame
        gridSystem.view = reportView
        addRoundRect(2, 4, 44, 42, color: myLightText, radius: 15, backgroundColor: UIColor.black.withAlphaComponent(0.6))
        renderRecord()
        renderCharacter()
        addBackButton()
    }

    func renderCharacter() {
        addRoundRect(4, 26, 18, 18, color: myLightText, radius: 15, backgroundColor: UIColor.white.withAlphaComponent(0.6))
    }

    func renderRecord() {
        guard let record = context.gameRecord else { return }

        addText(4, 5, 6, record.dataSetKey)

        let y = 12
        addText(4, y, 2, "達成率")
        let progress = getAttrText([
            ( record.progress, .white, getFontSize(h: 12)),
            ( "%", .lightGray, getFontSize(h: 4))
            ])
        addAttrText(4, y, 12, progress)

        addText(28, y, 2, "Rank")
        addText(28, y, 12, record.rank.rawValue, color: record.rank.color)

        addText(4, 22, 3, "正解 \(record.perfectCount) | すごい \(record.greatCount) | いいね \(record.goodCount) | ミス \(record.missedCount)")

        addRoundRect(24, 26, 20, 4, color: myBlue)
        addText(25, 26, 4, " +\(record.exp) EXP")

        let goldText = getAttrText([
            (" +\(record.gold)", .white, getFontSize(h: 4)),
            (" G", myOrange, getFontSize(h: 4))
            ])
        addRoundRect(24, 31, 20, 4, color: myOrange)
        addAttrText(25, 31, 4, goldText)

        addRoundRect(24, 36, 20, 4, color: myRed)
        addText(25, 36, 4, " Level Up!")

        context.gameCharacter.gold += record.gold
        context.gameCharacter.exp += record.exp
        saveGameCharacter()
    }

    func addRoundRect(_ x: Int, _ y: Int, _ w: Int, _ h: Int,
                      color: UIColor, radius: CGFloat? = nil, backgroundColor: UIColor? = nil) {
        gridSystem.addRoundRect(x: x, y: y, w: w, h: h, borderColor: color, radius: radius, backgroundColor: backgroundColor)
    }

    func addText(_ x: Int, _ y: Int, _ h: Int, _ text: String, color: UIColor = .white) {
        let fontSize = getFontSize(h: h)
        let font = MyFont.bold(ofSize: fontSize)
        addAttrText( x, y, h,
            getText(text, color: color, strokeWidth: -1.5, strokeColor: .white, font: font)
        )
    }

    func addAttrText(_ x: Int, _ y: Int, _ h: Int, _ attrText: NSAttributedString) {
        gridSystem.addAttrText(x: x, y: y, w: gridCount - x, h: h, text: attrText)
    }

    func getFontSize(h: Int) -> CGFloat {
        return h.c * gridSystem.step * 0.7
    }

    func addBackButton() {
        let backButton = UIButton()
        backButton.setTitle("戻  る", for: .normal)
        backButton.backgroundColor = .red
        backButton.titleLabel?.font = MyFont.regular(ofSize: gridSystem.step * 4)
        backButton.titleLabel?.textColor = myLightText
        backButton.roundBorder(borderWidth: 3, cornerRadius: 15, color: UIColor.white.withAlphaComponent(0.5))

        let backButtonTap = UITapGestureRecognizer(target: self, action: #selector(self.backButtonTapped))
        backButton.addGestureRecognizer(backButtonTap)
        gridSystem.frame(2, 48, 44, 8, backButton)
        reportView.addSubview(backButton)
    }

    @objc func backButtonTapped() {
        launchStoryboard(self, "MainViewController")
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
