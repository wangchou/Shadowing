//
//  ReportBoxView.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 10/4/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import UIKit

private let context = GameContext.shared

@IBDesignable
class GameReportBoxView: UIView, ReloadableView, GridLayout {
    let gridCount = 44
    let axis: GridAxis = .horizontal
    let spacing: CGFloat = 0

    func viewWillAppear() {
        backgroundColor = UIColor.black.withAlphaComponent(0.6)
        removeAllSubviews()
        renderTopTitle()
        renderMiddleRecord()
        renderMiddleGoalBar()
        if context.isNewRecord && context.contentTab == .topics {
            renderBottomAbilityInfo()
        }
    }

    private func renderTopTitle() {
        guard let record = context.gameRecord else { return }
        roundBorder(cornerRadius: 15, color: .white)
        var tags = (datasetKeyToTags[record.dataSetKey] ?? []).joined(separator: " ")
        var title = "\(record.dataSetKey)"
        if context.contentTab == .infiniteChallenge {
            title = "無限挑戰"
            tags = "#\(record.level.title)"
        }
        addText(2, 1, 6, title, color: myLightText, strokeColor: .black)
        addText(2, 7, 6, tags, color: myOrange, strokeColor: .black)
    }

    private func renderMiddleRecord() {
        guard let record = context.gameRecord else { return }

        let y = 13
        addText(2, y, 3, "完成率")
        let progress = getAttrText([
            ( record.progress.padWidthTo(4), .white, getFontSize(h: 12)),
            ( "%", .white, getFontSize(h: 3))
            ])
        addAttrText(2, y, 12, progress)

        addText(26, y, 3, "判定")
        addText(26, y, 12, record.rank.rawValue.padWidthTo(3), color: record.rank.color)

        addText(2, y+11, 3, "正解 \(record.perfectCount) | すごい \(record.greatCount) | いいね \(record.goodCount) | ミス \(record.missedCount)")
    }

    private func renderMiddleGoalBar() {
        guard let record = context.gameRecord else { return }

        let y = 28
        addText(2, y, 3, "今日の目標")
        let goalProgressLabel = addText(31, y, 3, "200/\(context.gameSetting.dailySentenceGoal)")
        goalProgressLabel.frame = getFrame(22, y, 20, 3)
        goalProgressLabel.textAlignment = .right

        let barBox = addRect(x: 2, y: y + 3, w: 40, h: 2, color: .clear)
        barBox.roundBorder(borderWidth: 1, cornerRadius: 0, color: .lightGray)

        addRect(x: 2, y: y + 3, w: 30, h: 2)
    }

    private func renderBottomAbilityInfo() {
        let y = 36

        let lineLeft = UIView()
        let lineRight = UIView()

        layout(0, y, 15, 1, lineLeft)
        lineLeft.backgroundColor = .lightGray
        lineLeft.frame.size.height = step/4
        addSubview(lineLeft)

        layout(29, y, 15, 1, lineRight)
        lineRight.backgroundColor = .lightGray
        lineRight.frame.size.height = step/4
        addSubview(lineRight)

        addText(16, y-3, 6, "新紀錄", color: myLightText)

        let chart = AbilityChart()
        layout(1, y+3, 27, 27, chart)
        chart.wColor = rgb(150, 150, 150)
        chart.labelColor = .white
        chart.labelFont = MyFont.regular(ofSize: getFontSize(h: 3))
        chart.render()
        addSubview(chart)

        let tagPoints = getTagPoints()
        var yShift = 3
        for idx in 0...abilities.count-1 {
            let abStr = abilities[idx]
            let gameTag = datasetKeyToTags[context.dataSetKey]?[0]
            let isTargetTag = gameTag == "#\(abStr)"
            let textColor: UIColor = isTargetTag ? myOrange : myLightText
            let scoreStr = "\(tagPoints["#"+abStr] ?? 0)"
            var padStr = ""
            for _ in 0...(3 - scoreStr.count) {
                padStr += "  "
            }
            if !isTargetTag {
                addText(30, y + yShift, 3, "\(abStr)： \(padStr)\(scoreStr)", color: textColor)
                yShift += 3
            } else {
                let ty = y + yShift
                let a = abStr
                let b = padStr
                let c = scoreStr
                Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
                    self.addText(30, ty, 3, "\(a)： \(b)\(c)", color: myOrange)
                    self.addText(30, ty + 2, 3, "(+\(context.newRecordIncrease))", color: myOrange)
                }
                yShift += 5
            }
        }
    }

    @discardableResult
    func addText(
        _ x: Int, _ y: Int, _ h: Int, _ text: String,
        color: UIColor = .white, strokeColor: UIColor = .black) -> UILabel {
        let fontSize = getFontSize(h: h)
        let font = MyFont.bold(ofSize: fontSize)
        return addAttrText( x, y, h,
                     getText(text, color: color, strokeWidth: -2, strokeColor: strokeColor, font: font)
        )
    }

    @discardableResult
    func addAttrText(_ x: Int, _ y: Int, _ h: Int, _ attrText: NSAttributedString) -> UILabel {
        return addAttrText(x: x, y: y, w: gridCount - x, h: h, text: attrText)
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        viewWillAppear()
    }
}
