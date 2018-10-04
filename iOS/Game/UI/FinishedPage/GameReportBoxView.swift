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
        if context.isNewRecord {
            renderBottomAbilityInfo()
        }
    }

    private func renderTopTitle() {
        guard let record = context.gameRecord else { return }
        roundBorder(cornerRadius: 15, color: myLightText)
        let tags = (datasetKeyToTags[record.dataSetKey] ?? []).joined(separator: " ")
        let title = "\(record.dataSetKey)"
        addText(2, 1, 6, title, color: myLightText, strokeColor: .black)
        addText(2, 7, 6, tags, color: myOrange, strokeColor: .black)
    }

    private func renderMiddleRecord() {
        guard let record = context.gameRecord else { return }

        let y = 13
        addText(2, y, 3, "達成率")
        let progress = getAttrText([
            ( record.progress.padWidthTo(4), .white, getFontSize(h: 12)),
            ( "%", .lightGray, getFontSize(h: 4))
            ])
        addAttrText(2, y, 12, progress)

        addText(26, y, 3, "Rank")
        addText(26, y, 12, record.rank.rawValue.padWidthTo(3), color: record.rank.color)

        addText(2, y+11, 3, "正解 \(record.perfectCount) | すごい \(record.greatCount) | いいね \(record.goodCount) | ミス \(record.missedCount)")
    }

    private func renderBottomAbilityInfo() {
        let y = 30

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

    func addRoundRect(_ x: Int, _ y: Int, _ w: Int, _ h: Int,
                      color: UIColor, radius: CGFloat? = nil, backgroundColor: UIColor? = nil) {
        addRoundRect(x: x, y: y, w: w, h: h, borderColor: color, radius: radius, backgroundColor: backgroundColor)
    }

    func addText(
        _ x: Int, _ y: Int, _ h: Int, _ text: String, color: UIColor = .white, strokeColor: UIColor = .black) {
        let fontSize = getFontSize(h: h)
        let font = MyFont.bold(ofSize: fontSize)
        addAttrText( x, y, h,
                     getText(text, color: color, strokeWidth: -2, strokeColor: strokeColor, font: font)
        )
    }

    func addAttrText(_ x: Int, _ y: Int, _ h: Int, _ attrText: NSAttributedString) {
        addAttrText(x: x, y: y, w: gridCount - x, h: h, text: attrText)
    }

    func getFontSize(h: Int) -> CGFloat {
        return h.c * step * 0.7
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        viewWillAppear()
    }
}
