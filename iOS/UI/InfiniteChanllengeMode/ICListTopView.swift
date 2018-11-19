//
//  ICListTopView.swift
//  今話したい
//
//  Created by Wangchou Lu on 11/15/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import UIKit

private let context = GameContext.shared
private let i18n = I18n.shared

class ICListTopView: UIView, GridLayout, ReloadableView {
    // GridLayout
    var gridCount: Int = 48

    var axis: GridAxis = .horizontal

    var spacing: CGFloat = 0

    let animationSecs: TimeInterval = 0.5

    var percent: Float = 0

    var percentageText: String {
        if percent >= 1.0 { return "完 成" }

        return String(format: "%.1f", percent * 100) + "%"
    }

    var goalText: String {
        return "每天說\(context.gameSetting.dailySentenceGoal)句"
    }

    var sprintText: String {
        return "衝刺"
    }

    var continues: Int = 0
    var continuesText: String {
        return "\(continues)"
    }

    var dayText: String {
        return "天"
    }

    var continueSentenceCount: Int = 0
    var sentencesCountText: String {
        return "\(continueSentenceCount)"
    }

    var sentenceText: String {
        return "句"
    }

    var bestText: String {
        return "最佳"
    }
    var bestCount: Int = 0
    var bestCountText: String {
        return "\(bestCount)"
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
        removeAllSubviews()
        updateByRecords()
        updateBGColor()

        let circleFrame = getFrame(11, 3, 24, 24)

        let backCircle = CircleView(frame: circleFrame)
        backCircle.lineWidth = stepFloat * 1.3
        backCircle.color = rgb(155, 155, 155)
        addSubview(backCircle)

        let frontCircle = CircleView(frame: circleFrame)
        frontCircle.lineWidth = stepFloat * 1.3
        frontCircle.percent = percent.c
        addSubview(frontCircle)
        //frontCircle.animate(duration: animationSecs)

        let percentLabel = addText(x: 14, y: 6, w: 30, h: 8,
                                   text: percentageText,
                                   font: MyFont.bold(ofSize: getFontSize(h: 8)),
                                   color: .black)
        percentLabel.textAlignment = .center
        percentLabel.centerIn(circleFrame)

        let goalLabel = addText(x: 14, y: 28, w: 30, h: 4,
                                text: goalText,
                                font: MyFont.bold(ofSize: getFontSize(h: 4)))
        goalLabel.textAlignment = .center
        goalLabel.centerX(circleFrame)

        addSideBar()
    }

    func updateByRecords() {
        let sentenceCounts = getSentenceCountsByDays()
        percent = min(sentenceCounts[0].f / context.gameSetting.dailySentenceGoal.f, 1.0)

        continueSentenceCount = sentenceCounts[0]
        for i in 1..<sentenceCounts.count {
            if sentenceCounts[i] >= context.gameSetting.dailySentenceGoal {
                continueSentenceCount += sentenceCounts[i]
            } else {
                break
            }
        }

        continues = 0
        for i in 0..<sentenceCounts.count {
            if sentenceCounts[i] >= context.gameSetting.dailySentenceGoal {
                continues += 1
            } else if i > 0 { // skip today
                break
            }
        }

        bestCount = 0
        var currentBest = 0
        sentenceCounts.forEach { c in
            if c >= context.gameSetting.dailySentenceGoal {
                currentBest += 1
            } else {
                currentBest = 0
            }
            if currentBest > bestCount {
                bestCount = currentBest
            }
        }
    }

    func updateBGColor(animated: Bool = false) {
        let lightGray238 = rgb(238, 238, 238)
        guard percent > 0 else {
            backgroundColor = rgb(238, 238, 238)
            return
        }

        // 0%   = rgb(238, 238, 238)
        // 100% = rgb(255, 204, 0)
        let targetBGColor = rgb(255,
                                255 - (51 * percent),
                                255 * (1 - percent))

        if !animated {
            backgroundColor = targetBGColor
            return
        }

        let animation = CABasicAnimation(keyPath: "backgroundColor")
        animation.fromValue = lightGray238.cgColor
        animation.toValue = targetBGColor.cgColor

        animation.duration = animationSecs
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        layer.add(animation, forKey: "bgColor")
        layer.backgroundColor = targetBGColor.cgColor
    }

    func addSideBar() {
        let topRect = addRect(x: 38, y: 3, w: 8, h: 20, color: .white)
        topRect.roundBorder(borderWidth: 0,
                            cornerRadius: 5,
                            color: .clear)

        let xFrame = topRect.frame
        addSideBarText(sprintText, y: 4, boundFrame: xFrame, color: .darkGray)
        addSideBarText(continuesText, y: 8, isBold: true, boundFrame: xFrame)
        addSideBarText(dayText, y: 11, boundFrame: topRect.frame, color: .darkGray)
        addSideBarText(sentencesCountText, y: 16, isBold: true, boundFrame: xFrame)
        addSideBarText(sentenceText, y: 19, boundFrame: xFrame, color: .darkGray)

        let bottomRect = addRect(x: 38, y: 24, w: 8, h: 8, color: .white)
        bottomRect.roundBorder(borderWidth: 0,
                               cornerRadius: 5,
                               color: .clear)
        addSideBarText(bestText, y: 25, boundFrame: xFrame, color: .darkGray)
        addSideBarText(bestCountText, y: 28, isBold: true, boundFrame: xFrame)

        addSeparateLine(y: 7, boundFrame: getFrame(38, 3, 8, 9))
        addSeparateLine(y: 15, boundFrame: getFrame(38, 14, 8, 2))
    }

    func addSideBarText(_ text: String,
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

    func addSeparateLine(y: Int, boundFrame: CGRect) {
        let separateLine = UIView()
        layout(0, y, 6, 1, separateLine)
        separateLine.frame.size.height = 0.5
        separateLine.backgroundColor = rgb(200, 200, 200)
        addSubview(separateLine)
        separateLine.centerIn(boundFrame)
    }
}
