//
//  ReportBoxView.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 10/4/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import UIKit

private let context = GameContext.shared
private let i18n = I18n.shared

@IBDesignable
class GameReportBoxView: UIView, ReloadableView, GridLayout {
    let gridCount = 44
    let axis: GridAxis = .horizontal
    let spacing: CGFloat = 0

    // for animate progress bar at viewDidAppear
    private var animateTimer: Timer?
    private var progressBar: UIView?
    private var goalProgressLabel: UILabel?
    private var startProgress: Float = 0
    private var endProgress: Float = 0
    private var fullProgressWidth: CGFloat = 0

    private var showAbilityTargetLabelFunc: (() -> Void)?

    func viewWillAppear() {
        backgroundColor = UIColor.black.withAlphaComponent(0.6)
        showAbilityTargetLabelFunc = nil
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
        Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { _ in
            let progress = getAttrText([
                ( record.progress.padWidthTo(4), .white, self.getFontSize(h: 12)),
                ( "%", .white, self.getFontSize(h: 3))
                ])

            self.addAttrText(2, y, 12, progress)
        }

        addText(26, y, 3, "判定")
        Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { _ in
            self.addText(26, y, 12, record.rank.rawValue.padWidthTo(3), color: record.rank.color)
        }

        addText(2, y+11, 3, "正解 \(record.perfectCount) | すごい \(record.greatCount) | いいね \(record.goodCount) | ミス \(record.missedCount)")
    }

    private func renderMiddleGoalBar() {
        guard let record = context.gameRecord else { return }
        let y = 28
        let line = UIView()
        layout(0, y, 44, 1, line)
        line.backgroundColor = .lightGray
        line.frame.size.height = 1.5
        addSubview(line)

        let todaySentenceCount = getTodaySentenceCount()
        let dailyGoal = context.gameSetting.dailySentenceGoal
        addText(2, y + 1, 6, "今日の目標", color: myLightText)
        goalProgressLabel = addText(31, y + 1, 6, "\(todaySentenceCount - record.correctCount)/\(dailyGoal)", color: myLightText)
        goalProgressLabel?.frame = getFrame(12, y + 1, 30, 6)
        goalProgressLabel?.textAlignment = .right
        let fontSize = getFontSize(h: 6)
        let font = MyFont.bold(ofSize: fontSize)

        let barBox = addRect(x: 2, y: y + 7, w: 40, h: 4, color: .clear)
        barBox.roundBorder(borderWidth: 1, cornerRadius: 0, color: .lightGray)

        // animate progress bar for one second
        startProgress = min(1.0, ((todaySentenceCount - record.correctCount).f/dailyGoal.f))
        endProgress = min(1.0, (todaySentenceCount.f/dailyGoal.f))
        fullProgressWidth = getFrame(0, 0, 40, 4).width
        progressBar = addRect(x: 2, y: y + 7, w: 1, h: 4)
        guard let progressBar = progressBar else { return }
        progressBar.frame.size.width = fullProgressWidth * startProgress.c
        progressBar.roundBorder(borderWidth: 1, cornerRadius: 0, color: .clear)

        let text = "\(todaySentenceCount - record.correctCount)/\(dailyGoal)"
        goalProgressLabel?.attributedText = getText(text,
                                                   color: myLightText,
                                                   strokeWidth: -2,
                                                   strokeColor: .black, font: font)
    }

    func animateProgressBar() {
        guard let record = context.gameRecord,
              let progressBar = progressBar,
              let goalProgressLabel = goalProgressLabel else { return }

        let todaySentenceCount = getTodaySentenceCount()
        let dailyGoal = context.gameSetting.dailySentenceGoal
        let fontSize = getFontSize(h: 6)
        let font = MyFont.bold(ofSize: fontSize)

        var repeatCount = 0
        let targetRepeatCount = 30
        let delayCount = 20
        let interval: TimeInterval = 0.02

        animateTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            guard repeatCount >= delayCount else {
                repeatCount += 1
                return
            }
            let ratio: Float = (repeatCount.f - delayCount.f) / targetRepeatCount.f
            progressBar.frame.size.width = self.fullProgressWidth * (self.startProgress * (1 - ratio) + self.endProgress * ratio).c
            let text = "\(todaySentenceCount - record.correctCount + (record.correctCount.f * ratio).i)/\(dailyGoal)"
            goalProgressLabel.attributedText = getText(text,
                                                       color: myLightText,
                                                       strokeWidth: -2,
                                                       strokeColor: .black, font: font)
            if repeatCount >= targetRepeatCount + delayCount {
                self.showAbilityTargetLabelFunc?()
                self.animateTimer?.invalidate()
                if self.startProgress < 1.0 && self.endProgress == 1.0 {
                    _ = teacherSay(i18n.reachDailyGoal, rate: normalRate)
                }
            }
            repeatCount += 1
        }
    }

    private func renderBottomAbilityInfo() {
        let y = 42

        let lineLeft = UIView()
        let lineRight = UIView()

        layout(0, y, 15, 1, lineLeft)
        lineLeft.backgroundColor = .lightGray
        lineLeft.frame.size.height = 1.5
        addSubview(lineLeft)

        layout(29, y, 15, 1, lineRight)
        lineRight.backgroundColor = .lightGray
        lineRight.frame.size.height = 1.5
        addSubview(lineRight)

        addText(16, y-3, 6, "新紀錄", color: myLightText)

        let chart = AbilityChart()
        layout(1, y+2, 28, 27, chart)
        chart.wColor = rgb(150, 150, 150)
        chart.labelColor = .white
        chart.labelFont = MyFont.regular(ofSize: getFontSize(h: 3))
        chart.render()
        addSubview(chart)

        let tagPoints = getTagPoints()
        var yShift = 3
        for idx in 0..<abilities.count {
            let abilityStr = abilities[idx]
            let gameTag = datasetKeyToTags[context.dataSetKey]?[0]
            let isTargetTag = gameTag == "#\(abilityStr)"
            let textColor: UIColor = isTargetTag ? myOrange : myLightText
            let scoreStr = "\(tagPoints["#"+abilityStr] ?? 0)"
            var padStr = ""
            for _ in 0...(5 - scoreStr.count - abilityStr.count) {
                padStr += "  "
            }
            if !isTargetTag {
                addText(30, y + yShift - 1, 3, "\(abilityStr)： \(padStr)\(scoreStr)", color: textColor)
                yShift += 3
            } else {
                let ty = y + yShift - 1
                let a = abilityStr
                let b = padStr
                let c = scoreStr
                showAbilityTargetLabelFunc = { [weak self] in
                    Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
                        self?.addText(30, ty, 3, "\(a)： \(b)\(c)", color: myOrange)
                        self?.addText(30, ty + 2, 3, "(+\(context.newRecordIncrease))", color: myOrange)
                    }
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
