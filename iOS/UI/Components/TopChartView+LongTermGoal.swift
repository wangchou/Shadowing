//
//  TopChartView+LongTermGoal.swift
//  今話したい
//
//  Created by Wangchou Lu on 12/23/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

private let context = GameContext.shared

// MARK: LongTermGoalMode
extension TopChartView {
    func renderLongTermGoalMode() {
        gridCount = 50
        backgroundColor = rgb(28, 28, 28)

        addLongTermTitle()
        addLongTermGoalDesc()
        addLongTermGoalBottomBar()
    }

    func addLongTermTitle() {
        let boxFrame = getFrame(0, 0, gridCount, 20)
        if isGameClear {
            var descAttrText = NSMutableAttributedString()
            func addWord(_ word: String, _ level: Level) {
                descAttrText.append(getText(word,
                                            color: level.color.withSaturation(1.0),
                                            font: MyFont.bold(ofSize: stepFloat * 8)))
            }
            addWord("今", Level.lv0)
            addWord("話", Level.lv2)
            addWord("し", Level.lv4)
            addWord("た", Level.lv6)
            addWord("い", Level.lv8)
            let gameClearLabel = addAttrText(x: 5, y: 7, h: 14, text: descAttrText)
            gameClearLabel.textAlignment = .center
            gameClearLabel.centerX(boxFrame)
        } else {
            let currentLvlColor = longTermGoalColor
            let goalLabel = addText(x: 5, y: 7, w: 50, h: 14, text: longTermGoalText, color: currentLvlColor)
            goalLabel.textAlignment = .center
            goalLabel.centerX(boxFrame)
        }
    }
    func addLongTermGoalBottomBar() {
        let lvlColors = [Level.lv0.color.withSaturation(1.0),
                         Level.lv2.color.withSaturation(1.0),
                         Level.lv4.color.withSaturation(1.0),
                         Level.lv6.color.withSaturation(1.0)]

        var levelSentenceCounts = [1000, 3000, 6000, 10000]
        var wPoints = [0, 5, 15, 30, 50]
        var t: UILabel
        var bar: UIView
        for i in 0..<levelSentenceCounts.count {
            let w = wPoints[i+1] - wPoints[i]
            let c = lvlColors[i]
            bar = addRect(x: wPoints[i], y: 30, w: w, h: 1, color: c)
            bar.moveToBottom(frame)
            t = addText(x: 0, y: 20, w: 8, h: 3, text: "\(levelSentenceCounts[i])", color: c)
            t.textAlignment = .right
            t.moveToRight(bar.frame)
            t.moveToBottom(frame, yShift: -1 * stepFloat)
        }
    }

    func addLongTermGoalDesc() {
        let boxFrame = getFrame(0, 0, gridCount, 20)
        let percentText = String(format: "%.1f", 100 * allSentenceCount.f/longTermGoal.f)
        let remainingDays = String(format: "%.1f", max(0, longTermGoal - allSentenceCount).f/context.gameSetting.dailySentenceGoal.f)
        let gray = rgb(155, 155, 155)
        var descAttrText = NSMutableAttributedString()
        func addWhiteText(_ text: String) {
            descAttrText.append(getText(text, color: .white,
                                        font: MyFont.bold(ofSize: stepFloat * 2.5)
            ))
        }
        func addGrayText(_ text: String) {
            descAttrText.append(getText(text, color: gray,
                                        font: MyFont.regular(ofSize: stepFloat * 2.5)
            ))
        }
        func addBoldGrayText(_ text: String) {
            descAttrText.append(getText(text, color: gray,
                                        font: MyFont.bold(ofSize: stepFloat * 2.5)
            ))
        }
        if isGameClear {
            addWhiteText("100 ")
            addGrayText("% を話した、")
            addWhiteText("\(clearDurationInDays) ")
            addGrayText("日間で。")
        } else {
            addWhiteText("\(percentText) ")
            addGrayText(i18n.longTermGoalMiddleText)
            addWhiteText(" \(remainingDays) ")
            addGrayText("\(i18n.dayRange)。")
        }

        let y = isGameClear ? 20 : 23
        var descLabel = addAttrText(x: 5, y: y, h: 5, text: descAttrText)
        descLabel.textAlignment = .center
        descLabel.centerX(boxFrame)

        if isGameClear {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            dateFormatter.locale = Locale(identifier: Locale.current.identifier)
            descAttrText = NSMutableAttributedString()
            addBoldGrayText(dateFormatter.string(from: clearDate))
            descLabel = addAttrText(x: 5, y: 25, h: 5, text: descAttrText)
            descLabel.textAlignment = .center
            descLabel.centerX(boxFrame)
        }
    }
}
