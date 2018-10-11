//
//  ICInfoView.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 10/10/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import UIKit

private let context = GameContext.shared

private enum Texts: String {
    case precision = "完成率"
    case numOfSentence = "句子數"
}

private func getLevelDescription(_ level: Level) -> String {
    switch level {
    case .lv0:
        return "入門"
    case .lv1:
        return "初級"
    case .lv2:
        return "中級"
    case .lv3:
        return "上級"
    case .lv4:
        return "超難問"
    }
}

class ICInfoView: UIView, GridLayout, ReloadableView {
    // GridLayout
    var gridCount: Int = 48

    var axis: GridAxis = .horizontal

    var spacing: CGFloat = 0

    var minKanaCount: Int = 1
    var maxKanaCount: Int = 10
    var sentencesCount: Int = -1
    var level: Level = .lv0

    var line1: String {
        return "難度：" + getLevelDescription(level) + "です"
    }
    var line2: String {
        return "仮名数：\(minKanaCount)〜\(maxKanaCount)"
    }
    var line3: String {
        return "句数：\(sentencesCount)"
    }
    var bestRank: String? {
        return findBestRecord(key: level.dataSetKey)?.rank.rawValue
    }
    var bestProgress: String? {
        return findBestRecord(key: level.dataSetKey)?.progress
    }

    private var dataPoints: [(x: Int, y: Int)] {
        var points = [(x: 0, y: 0)]
        let dataSetKey = level.dataSetKey
        let gameRecords = context.gameHistory
            .filter { r in
                return r.dataSetKey == dataSetKey
            }
            .sorted {(r1, r2) in
                return r1.startedTime < r2.startedTime
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
        if  let bestRank = bestRank,
            let rank = Rank(rawValue: bestRank) {
            return getStrokeText(bestRank.padWidthTo(2), rank.color, font: font)
        } else {
            return getStrokeText(" ?", .lightText, font: font)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        viewWillAppear()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        viewWillAppear()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        viewWillAppear()
    }

    func viewWillAppear() {
        frame.size.height = screen.width * 54/48
        removeAllSubviews()

        var y = 1
        // line chart
        addRect(x: 0, y: 0, w: gridCount, h: 25, color: rgb(250, 250, 250))
        addText(x: 1, y: y, h: 2, text: Texts.precision.rawValue)
        y += 2

        let chart = LineChart()
        chart.setDataCount(level: level, dataPoints: dataPoints)
        layout(1, y, 46, 23, chart)
        addSubview(chart)
        y += 19

        addText(x: 42, y: y, h: 2, text: Texts.numOfSentence.rawValue)
        y += 3

        // separate Line
        addRect(x: 0, y: y, w: gridCount, h: 1, color: rgb(240, 240, 240))
        addSeparateLine(y: y, color: rgb(212, 212, 212))
        //addRoundRect(x: 2, y: y, w: 44, h: 11, borderColor: .black, radius: 5, backgroundColor: .clear)
        y += 1
        addSeparateLine(y: y, color: rgb(212, 212, 212))
        y += 1
        // description
        addAttrText(x: 18, y: y, h: 11, text: progressAttrText)
        addAttrText(x: 36, y: y, h: 11, text: rankAttrText)

        addText(x: 2, y: y, h: 3, text: line1)
        addText(x: 18, y: y, h: 3, text: "完成率")
        addText(x: 35, y: y, h: 3, text: "Rank")

        y += 3

        addText(x: 2, y: y, h: 3, text: line2)
        y += 3

        addText(x: 2, y: y, h: 3, text: line3)
        y += 6

        // challenge button
        addChallengeButton()
        y += 10

        addRect(x: 0, y: y, w: gridCount, h: 5, color: level.color.withAlphaComponent(0.3))

        addSeparateLine(y: y)
        addSeparateLine(y: y+5)
        addText(x: 1, y: y, h: 5, text: "前回の挑戦")
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
        button.setTitle("挑　　　戦", for: .normal)
        button.backgroundColor = .red
        button.titleLabel?.font = MyFont.regular(ofSize: step * 5)
        button.titleLabel?.textColor = myLightText
        button.roundBorder(borderWidth: 1.5, cornerRadius: 5, color: UIColor.white.withAlphaComponent(0.5))

        button.addTapGestureRecognizer {
            if let vc = UIApplication.getPresentedViewController() {
                context.infiniteChallengeLevel = self.level
                launchStoryboard(vc, "MessengerGame")
            }
        }

        layout(2, 38, 44, 8, button)

        addSubview(button)
    }
}
