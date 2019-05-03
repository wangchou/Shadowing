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
    if percent < 0.4 { return myRed }
    if percent < 0.7 { return myOrange }
    if percent < 1.0 { return myGreen }

    return myBlue
}

@IBDesignable
class GameReportBoxView: UIView, ReloadableView, GridLayout {
    let gridCount = 44
    let axis: GridAxis = .horizontal

    // for animate progress bar at viewDidAppear
    private var timers: [String: Timer] = [:]
    private var animateGoalBarContext: AnimateBarContext?
    private var animateTopicBarContext: AnimateBarContext?
    private var fullProgressWidth: CGFloat = 0

    private var showAbilityTargetLabelFunc: (() -> Void)?
    private var statusSpeakingPromise: Promise<Void> = fulfilledVoidPromise()

    func render() {
        backgroundColor = UIColor.black.withAlphaComponent(0.6)
        roundBorder(width: 1.5, radius: 2 * step, color: .white)
        showAbilityTargetLabelFunc = nil
        removeAllSubviews()
        renderTopTitle()
        renderMiddleRecord()
        renderMiddleGoalBar()
    }

    private func renderTopTitle() {
        guard let record = context.gameRecord else { return }
        let tags = "#\(record.level.title)"
        var title = ""
        switch context.gameMode {
        case .topicMode:
            title = getDataSetTitle(dataSetKey: record.dataSetKey)
        case .infiniteChallengeMode:
            title = i18n.infiniteChallengeTitle
        default:
            ()
        }
        addText(2, 1, 6, title, color: myLightGray, strokeColor: .black)
        addText(2, 6, 6, tags, color: record.level.color, strokeColor: .black)

        let statusText = i18n.getSpeakingStatus(percent: record.progress, rank: record.rank.rawValue, reward: record.medalReward)
        statusSpeakingPromise = teacherSay(statusText, rate: fastRate)
    }

    private func renderMiddleRecord() {
        guard let record = context.gameRecord else { return }
        let y = 13
        addText(2, y, 3, i18n.completeness, color: minorTextColor)

        let progress = getAttrText([
            ( record.progress.padWidthTo(4), .white, getFontSize(h: 12)),
            ( "%", .white, self.getFontSize(h: 3))
            ])

        var label = self.addAttrText(2, y+1, 12, progress)
        label.slideIn(duration: 0.3)

        addText(26, y, 3, i18n.rank, color: minorTextColor)

        let rankText = getStrokeText(record.rank.rawValue.padWidthTo(3),
                                     record.rank.color,
                                     strokeWidth: -1,
                                     strokColor: .black,
                                     font: MyFont.bold(ofSize: getFontSize(h: 12)))
        label = addAttrText(x: 27, y: y+1, h: 12,
                         text: rankText)
        label.slideIn(duration: 0.5)

        let detailText = "\(i18n.excellent) \(record.perfectCount) | \(i18n.great) \(record.greatCount) | \(i18n.good) \(record.goodCount) | \(i18n.wrong) \(record.missedCount)"
        label = addText(x: 0, y: y+12, w: gridCount, h: 3,
                            text: detailText,
                            color: minorTextColor)
        label.textAlignment = .center
    }

    private func renderMiddleGoalBar() {
        guard let record = context.gameRecord else { return }
        let y = 29
        let line = UIView()
        layout(0, y, 44, 1, line)
        line.backgroundColor = rgb(150, 150, 150)
        line.frame.size.height = 0.5
        addSubview(line)

        // sentence numbers
        let todaySentenceCount = getTodaySentenceCount()
        let dailyGoal = context.gameSetting.dailySentenceGoal
        animateGoalBarContext = addProgressBar(y: y,
                                               title: i18n.todayGoal,
                                               fromNumber: todaySentenceCount - record.correctCount,
                                               endNumber: todaySentenceCount,
                                               maxNumber: dailyGoal,
                                               color: record.level.color)

        if context.gameMode == .topicMode {
            let topic = getDataSetTopic(dataSetKey: record.dataSetKey)
            let tagPointsWithoutLast = getTagPoints(isWithoutLast: true)
            let fromTagPoint = tagPointsWithoutLast["#" + topic] ?? 0
            let tagPoints = getTagPoints()
            let toTagPoint = tagPoints["#" + topic] ?? 0
            let tagMaxPoints = getTagMaxPoints()
            let maxTagPoint = tagMaxPoints["#" + topic] ?? 1
            animateTopicBarContext = addProgressBar(y: y + 8,
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
                                maxNumber: Int,
                                color: UIColor? = nil) -> AnimateBarContext {
        let lineHeight = 3
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

        let barBox = addRect(x: 2, y: y + 5, w: 40, h: lineHeight,
                             color: progressBackGray)
        barBox.roundBorder(radius: step/2, color: .lightGray)

        // animate progress bar for one second
        let fromPercent = min(1.0, (fromNumber.f/maxNumber.f))
        fullProgressWidth = getFrame(0, 0, 40, lineHeight).width

        let bar = addRect(x: 2, y: y + 5, w: 1, h: lineHeight,
                          color: color ?? getProgressColor(percent: fromPercent))
        bar.frame.size.width = fullProgressWidth * fromPercent.c
        bar.roundBorder(radius: step/2)

        return (progressLabel, bar, fromNumber, endNumber, maxNumber)
    }

    func animateProgressBar() {
        animateBarContext(context: animateGoalBarContext, key: "goal")
        animateBarContext(context: animateTopicBarContext, key: "topic" )
    }

    private func animateBarContext(context: AnimateBarContext?, key: String) {
        guard let (label, bar, fromCount, toCount, maxCount) = context else { return }
        let fontSize = getFontSize(h: 4)
        let font = MyFont.bold(ofSize: fontSize)

        var repeatCount = 0
        let targetRepeatCount = 30
        let delayCount = 20
        let interval: TimeInterval = 0.02
        let startProgress: Float = min(fromCount.f/maxCount.f, 1.0)
        let endProgress: Float = min(toCount.f/maxCount.f, 1.0)

        timers[key]?.invalidate()
        timers[key] = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            guard repeatCount >= delayCount else {
                repeatCount += 1
                return
            }
            let ratio: Float = (repeatCount.f - delayCount.f) / targetRepeatCount.f
            let currentProgress = (startProgress * (1 - ratio) + endProgress * ratio)
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
        render()
    }
}
