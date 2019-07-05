//
//  ICInfoView.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 10/10/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Firebase
import UIKit

private let context = GameContext.shared

class ICInfoView: UIView, GridLayout, ReloadableView {
    var minKanaCount: Int = 1
    var maxKanaCount: Int = 10
    var sentencesCount: Int = -1
    var level: Level = .lv0

    var line1: String {
        return level.title
    }

    var line2: String {
        return "\(i18n.syllablesCount)：\(minKanaCount)〜\(maxKanaCount)"
    }

    var line3: String {
        return "\(i18n.sentencesCount)：\(sentencesCount)"
    }

    var bestRank: String? {
        return level.bestInfinteChallengeRank
    }

    var bestProgress: String? {
        return level.bestInfinteChallengeProgress
    }

    private var dataPoints: [(x: Int, y: Int)] {
        var points = [(x: 0, y: 0)]
        let dataSetKey = level.infinteChallengeDatasetKey
        let gameRecords = context.gameHistory
            .filter { r in
                r.dataSetKey == dataSetKey
            }
            .sorted { r1, r2 in
                r1.startedTime < r2.startedTime
            }
        guard !gameRecords.isEmpty else {
            points.append((x: 100, y: 1))
            return points
        }
        var sentenceCount = 0
        points.append(contentsOf: gameRecords.map { r -> (x: Int, y: Int) in
            sentenceCount += r.sentencesCount
            return (x: sentenceCount, y: Int(r.p))
        })
        return points
    }

    private var progressAttrText: NSAttributedString {
        let attrText = NSMutableAttributedString()
        let font = MyFont.bold(ofSize: getFontSize(h: 11))
        if let string = bestProgress {
            attrText.append(getStrokeText(string.padWidthTo(3), .darkGray, font: font))
            attrText.append(getStrokeText("%", .darkGray, strokeWidth: 0, strokColor: .black, font: UIFont.boldSystemFont(ofSize: 12)))
            return attrText
        } else {
            attrText.append(getStrokeText(" ??", .lightText, font: font))
            attrText.append(getStrokeText("%", .darkGray, strokeWidth: 0, strokColor: .black, font: UIFont.boldSystemFont(ofSize: 12)))
            return attrText
        }
    }

    private var rankAttrText: NSAttributedString {
        let font = MyFont.bold(ofSize: getFontSize(h: 11))
        if let bestRank = bestRank,
            let rank = Rank(rawValue: bestRank) {
            return getStrokeText(bestRank.padWidthTo(2), rank.color, font: font)
        } else {
            return getStrokeText(" ?", .lightText, font: font)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        render()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        render()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        render()
    }

    func render() {
        frame.size.width = screen.width
        frame.size.height = screen.width * 64 / 48
        removeAllSubviews()

        var y = 1
        // line chart
        addRect(x: 0, y: 0, w: gridCount, h: 35, color: rgb(250, 250, 250))
        addText(x: 1, y: y, h: 2, text: i18n.completeness)
        y += 2

        let chart = LineChart()
        chart.setDataCount(level: level, dataPoints: dataPoints)
        layout(1, y, 46, 33, chart)
        addSubview(chart)
        y += 29

        addText(x: 43, y: y, h: 2, text: i18n.sentencesCount)
        y += 3

        // separate Line
        addRect(x: 0, y: y, w: gridCount, h: 1, color: rgb(240, 240, 240))
        addSeparateLine(y: y, color: rgb(212, 212, 212))
        y += 1
        addSeparateLine(y: y, color: rgb(212, 212, 212))
        y += 1

        // description
        addAttrText(x: 18, y: y + 1, h: 10, text: progressAttrText)
        addAttrText(x: 36, y: y + 1, h: 10, text: rankAttrText)

        addText(x: 2, y: y, h: 3, text: line1)
        addText(x: 18, y: y, h: 3, text: i18n.completeness)
        addText(x: 35, y: y, h: 3, text: i18n.rank)

        y += 3

        addText(x: 2, y: y, h: 3, text: line2)
        y += 3

        addText(x: 2, y: y, h: 3, text: line3)
        y += 6

        // challenge button
        addChallengeButton()
        y += 9

        // separate Line
        addRect(x: 0, y: y, w: gridCount, h: 1, color: rgb(240, 240, 240))
        addSeparateLine(y: y, color: rgb(212, 212, 212))
        y += 1

        addRect(x: 0, y: y, w: gridCount, h: 5, color: level.color.withAlphaComponent(0.3))

        addSeparateLine(y: y, color: rgb(180, 180, 180))
        addSeparateLine(y: y + 5, color: rgb(180, 180, 180))
        addText(x: 1, y: y, h: 5, text: i18n.previousGame)
    }

    func addSeparateLine(y: Int, color: UIColor = .darkGray) {
        let separateLine = UIView()
        layout(0, y, gridCount, 1, separateLine)
        separateLine.frame.size.height = 0.5
        separateLine.backgroundColor = color
        addSubview(separateLine)
    }

    func addChallengeButton() {
        let button = UIButton()
        button.setIconImage(named: "baseline_play_arrow_black_48pt", tintColor: .white, isIconOnLeft: false)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.6), for: .highlighted)
        button.backgroundColor = .red
        button.titleLabel?.font = MyFont.regular(ofSize: step * 5)
        button.titleLabel?.textColor = .white
        button.roundBorder(radius: step)
        button.showsTouchWhenHighlighted = true
        button.addTarget(self, action: #selector(onChallengeButtonClicked), for: .touchUpInside)

        layout(2, 48, 44, 8, button)

        addSubview(button)
    }

    @objc func onChallengeButtonClicked() {
        context.gameMode = .infiniteChallengeMode
        guard !TopicDetailPage.isChallengeButtonDisabled else { return }
        context.infiniteChallengeLevel = level
        if isUnderDailySentenceLimit() {
            Analytics.logEvent("challenge_infinite_\(gameLang.prefix)", parameters: nil)
            launchVC(Messenger.id, isOverCurrent: false)
        }
    }
}
