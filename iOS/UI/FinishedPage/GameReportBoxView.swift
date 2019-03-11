//
//  ReportBoxView.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 10/4/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import UIKit
import Promises

private let context = GameContext.shared

typealias AnimateBarContext = (progress: UILabel, bar: UIView, from: Int, to: Int, max: Int)

private func getProgressColor(percent: Float) -> UIColor {
    if percent < 0.4 {
        return myRed
    }
    if percent < 0.7 {
        return myOrange
    }

    if percent < 1 {
        return myGreen
    }

    return myBlue
}

@IBDesignable
class GameReportBoxView: UIView, ReloadableView, GridLayout {
    let gridCount = 44
    let axis: GridAxis = .horizontal
    let spacing: CGFloat = 0

    // for animate progress bar at viewDidAppear
    private var timers: [String: Timer] = [:]
    private var animateGoalBarContext: AnimateBarContext?
    private var animateTopicBarContext: AnimateBarContext?
    private var fullProgressWidth: CGFloat = 0

    private var showAbilityTargetLabelFunc: (() -> Void)?
    private var statusSpeakingPromise: Promise<Void> = fulfilledVoidPromise()

    func viewWillAppear() {
        backgroundColor = UIColor.black.withAlphaComponent(0.6)
        showAbilityTargetLabelFunc = nil
        removeAllSubviews()
        renderTopTitle()
        renderMiddleRecord()
        renderMiddleGoalBar()
    }

    private func renderTopTitle() {
        guard let record = context.gameRecord else { return }
        roundBorder(cornerRadius: 15, color: .white)
        let tags = "#\(record.level.title)"
        var title = getDataSetTitle(dataSetKey: record.dataSetKey)
        if context.contentTab == .infiniteChallenge {
            title = "無限挑戰"
        }
        addText(2, 1, 6, title, color: myLightGray, strokeColor: .black)
        addText(2, 7, 6, tags, color: myOrange, strokeColor: .black)

        let statusText = i18n.getSpeakingStatus(percent: record.progress, rank: record.rank.rawValue)
        statusSpeakingPromise = teacherSay(statusText, rate: fastRate)
    }

    private func renderMiddleRecord() {
        guard let record = context.gameRecord else { return }

        let y = 13
        addText(2, y, 3, "完成率")
        Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) {_ in
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

        // sentence numbers
        let todaySentenceCount = getTodaySentenceCount()
        let dailyGoal = context.gameSetting.dailySentenceGoal
        animateGoalBarContext = addProgressBar(y: y,
                                               title: "今日の目標",
                                               fromNumber: todaySentenceCount - record.correctCount,
                                               endNumber: todaySentenceCount,
                                               maxNumber: dailyGoal)

        if context.contentTab == .topics {
            let topic = getDataSetTopic(dataSetKey: record.dataSetKey)
            let tagPointsWithoutLast = getTagPoints(isWithoutLast: true)
            let fromTagPoint = tagPointsWithoutLast["#" + topic] ?? 0
            let tagPoints = getTagPoints()
            let toTagPoint = tagPoints["#" + topic] ?? 0
            let tagMaxPoints = getTagMaxPoints()
            let maxTagPoint = tagMaxPoints["#" + topic] ?? 1
            animateTopicBarContext = addProgressBar(y: y + 10,
                                                    title: topic,
                                                    fromNumber: fromTagPoint,
                                                    endNumber: toTagPoint,
                                                    maxNumber: maxTagPoint)
        }
    }

    private func addProgressBar(y: Int,
                                title: String,
                                fromNumber: Int,
                                endNumber: Int,
                                maxNumber: Int) -> AnimateBarContext {
        let lineHeight = 4
        addText(2, y + 1, lineHeight + 1, title, color: myLightGray)

        let text = "\(fromNumber)/\(maxNumber)"
        let progressLabel = addText(31, y + 1, lineHeight+1, text, color: myLightGray)
        progressLabel.frame = getFrame(12, y + 1, 30, lineHeight+1)
        progressLabel.textAlignment = .right
        let fontSize = getFontSize(h: lineHeight + 1)
        let font = MyFont.bold(ofSize: fontSize)
        progressLabel.attributedText = getText(text,
                                               color: myLightGray,
                                               strokeWidth: -2,
                                               strokeColor: .black, font: font)

        let barBox = addRect(x: 2, y: y + 6, w: 40, h: lineHeight, color: .clear)
        barBox.roundBorder(borderWidth: 1, cornerRadius: 0, color: .lightGray)

        // animate progress bar for one second
        let fromPercent = min(1.0, (fromNumber.f/maxNumber.f))
        fullProgressWidth = getFrame(0, 0, 40, lineHeight).width

        let bar = addRect(x: 2, y: y + 6, w: 1, h: lineHeight, color: getProgressColor(percent: fromPercent))
        bar.frame.size.width = fullProgressWidth * fromPercent.c
        bar.roundBorder(borderWidth: 1, cornerRadius: 0, color: .clear)

        return (progressLabel, bar, fromNumber, endNumber, maxNumber)
    }

    func animateProgressBar() {
        animateBarContext(context: animateGoalBarContext, key: "goal")
        animateBarContext(context: animateTopicBarContext, key: "topic" )
    }

    private func animateBarContext(context: AnimateBarContext?, key: String) {
        guard let (label, bar, fromCount, toCount, maxCount) = context else { return }
        let fontSize = getFontSize(h: 5)
        let font = MyFont.bold(ofSize: fontSize)

        var repeatCount = 0
        let targetRepeatCount = 30
        let delayCount = 20
        let interval: TimeInterval = 0.02
        let startProgress: Float = min(fromCount.f/maxCount.f, 1.0)
        let endProgress: Float = min(toCount.f/maxCount.f, 1.0)

        timers[key] = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            guard repeatCount >= delayCount else {
                repeatCount += 1
                return
            }
            let ratio: Float = (repeatCount.f - delayCount.f) / targetRepeatCount.f
            let currentProgress = (startProgress * (1 - ratio) + endProgress * ratio)
            bar.backgroundColor = getProgressColor(percent: currentProgress)
            bar.frame.size.width = self.fullProgressWidth * currentProgress.c
            let text = "\((fromCount.f * (1 - ratio) + toCount.f * ratio).i)/\(maxCount)"
            label.attributedText = getText(text,
                                           color: myLightGray,
                                           strokeWidth: -2,
                                           strokeColor: .black, font: font)
            if repeatCount >= targetRepeatCount + delayCount {
                self.showAbilityTargetLabelFunc?()
                self.timers[key]?.invalidate()
                self.timers[key] = nil
                if startProgress < 1.0 && endProgress == 1.0 {
                    _ = self.statusSpeakingPromise.then {
                        teacherSay(i18n.reachDailyGoal, rate: fastRate)
                    }
                }
            }
            repeatCount += 1
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
