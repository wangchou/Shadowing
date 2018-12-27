//
//  TopChartView+DailyChart.swift
//  今話したい
//
//  Created by Wangchou Lu on 12/23/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

private let context = GameContext.shared
private let i18n = I18n.shared

// MARK: Daily Goal Mode
extension TopChartView {
    func renderDailyGoalMode() {
        gridCount = 48
        updateDailyViewBGColor()

        circleFrame = getFrame(11, 3, 24, 24)

        // padding 5
        circleFrame = CGRect(
            x: circleFrame.origin.x + 5,
            y: circleFrame.origin.y + 5,
            width: circleFrame.size.width - 10,
            height: circleFrame.size.height - 10
        )

        let backCircle = CircleView(frame: circleFrame)
        backCircle.lineWidth = stepFloat * 1.3
        backCircle.lineColor = rgb(155, 155, 155)
        addSubview(backCircle)

        frontCircle = CircleView(frame: circleFrame)
        frontCircle!.lineWidth = stepFloat * 1.3
        frontCircle!.percent = percent >= 1.0 ? percent.c : 0
        addSubview(frontCircle!)

        percentLabel = addText(x: 14, y: 6, w: 30, h: 8,
                               text: percent >= 1.0 ? percentageText : "0.0%",
                               font: MyFont.bold(ofSize: getFontSize(h: 8)),
                               color: .black)
        percentLabel?.textAlignment = .center
        percentLabel?.centerIn(circleFrame)

        let goalLabel = addText(x: 14, y: 28, w: 30, h: 4,
                                text: goalText,
                                font: MyFont.bold(ofSize: getFontSize(h: 4)))
        goalLabel.textAlignment = .center
        goalLabel.centerX(circleFrame)

        addDailySideBar()
        addFreeVersionButton()
    }

    func animateProgress() {
        guard context.gameSetting.icTopViewMode == .dailyGoal,
            percent > 0,
            percent < 1.0 else { return }

        // background
        let animation = CABasicAnimation(keyPath: "backgroundColor")

        animation.duration = 0.5

        animation.fromValue = longTermGoalColor.withSaturation(0).cgColor
        animation.toValue = longTermGoalColor.withSaturation(percent.c).cgColor

        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)

        layer.backgroundColor = longTermGoalColor.withSaturation(percent.c).cgColor
        layer.add(animation, forKey: "animateBackground")

        // percentLabel
        guard let percentLabel = percentLabel else { return }
        var repeatCount = 0
        let targetCount = 25
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            guard repeatCount <= 25 else {
                self.timer?.invalidate()
                return
            }
            let currentPercent = self.percent * repeatCount.f/targetCount.f
            percentLabel.text = String(format: "%.1f", currentPercent * 100) + "%"
            percentLabel.centerIn(self.circleFrame)
            repeatCount += 1
        }

        // circle
        guard let circleView = frontCircle else { return }
        circleView.percent = percent.c
        circleView.animate(duration: 0.5)
    }

    func updateDailyViewBGColor() {
        // 0%   = rgb(238, 238, 238)
        // 100% = rgb(255, 204, 0)
        guard percent < 1.0 else {
            backgroundColor = longTermGoalColor.withSaturation(1.0)
            return
        }

        guard percent > 0 else {
            backgroundColor = rgb(238, 238, 238)
            return
        }

        backgroundColor = longTermGoalColor.withSaturation(0)
    }

    func addDailySideBar() {
        let topRect = addRect(x: 38, y: 3, w: 8, h: 20, color: .white)
        topRect.roundBorder(borderWidth: 0,
                            cornerRadius: 5,
                            color: .clear)

        let xFrame = topRect.frame
        addDailySideBarText(sprintText, y: 4, boundFrame: xFrame, color: .darkGray)
        addDailySideBarText(continuesText, y: 8, isBold: true, boundFrame: xFrame)
        addDailySideBarText(dayText, y: 11, boundFrame: topRect.frame, color: .darkGray)
        addDailySideBarText(sentencesCountText, y: 16, isBold: true, boundFrame: xFrame)
        addDailySideBarText(sentenceText, y: 19, boundFrame: xFrame, color: .darkGray)

        let bottomRect = addRect(x: 38, y: 24, w: 8, h: 8, color: .white)
        bottomRect.roundBorder(borderWidth: 0,
                               cornerRadius: 5,
                               color: .clear)
        addDailySideBarText(bestText, y: 25, boundFrame: xFrame, color: .darkGray)
        addDailySideBarText(bestCountText, y: 28, isBold: true, boundFrame: xFrame)

        addDailySideBarSeparateLine(y: 7, boundFrame: getFrame(38, 3, 8, 9))
        addDailySideBarSeparateLine(y: 15, boundFrame: getFrame(38, 14, 8, 2))
    }

    func addDailySideBarText(_ text: String,
                             y: Int,
                             isBold: Bool = false,
                             boundFrame: CGRect,
                             color: UIColor = .black) {
        let font = isBold ? MyFont.bold(ofSize: getFontSize(h: 3)) :
            MyFont.regular(ofSize: getFontSize(h: 3))
        let sprintLabel = addText(x: 14, y: y, w: 8, h: 3,
                                  text: text,
                                  font: font,
                                  color: color)
        sprintLabel.textAlignment = .center
        sprintLabel.centerX(boundFrame)
    }

    func addDailySideBarSeparateLine(y: Int, boundFrame: CGRect) {
        let separateLine = UIView()
        layout(0, y, 6, 1, separateLine)
        separateLine.frame.size.height = 0.5
        separateLine.backgroundColor = rgb(200, 200, 200)
        addSubview(separateLine)
        separateLine.centerIn(boundFrame)
    }

    func addFreeVersionButton() {
        guard isFreeVersion() else { return }
        let freeRect = addRect(x: 2, y: 27, w: 8, h: 5, color: .clear)
        freeRect.roundBorder(borderWidth: 1.5,
                             cornerRadius: 5,
                             color: .white)
        let freeLabel = addText(x: 14, y: 26, w: 8, h: 3,
                                text: i18n.freeVersion,
                                font: MyFont.bold(ofSize: getFontSize(h: 3)),
                                color: .white)
        freeLabel.textAlignment = .center
        freeLabel.centerIn(freeRect.frame)
        freeRect.addTapGestureRecognizer {
            IAPHelper.shared.showPurchaseView(isChallenge: false)
        }
    }
}
