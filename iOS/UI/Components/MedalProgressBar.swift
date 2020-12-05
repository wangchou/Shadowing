//
//  MedalProgressBar.swift
//  今話したい
//
//  Created by Wangchou Lu on 4/11/31 H.
//  Copyright © 31 Heisei Lu, WangChou. All rights reserved.
//

import UIKit

class MedalProgressBar: UIView, GridLayout, ReloadableView {
    var gridCount = 34

    var medalCount = 0

    var isFinishedPageMode = false

    var timer: Timer?

    var lvlLabel: UILabel!
    var medalView: MedalView!
    var medalCountLabel: UILabel!
    var progressBarBack: UIView!
    var progressBarMid: UIView!
    var progressBarFront: UIView!
    var lvlStartLabel: UILabel!
    var lvlEndLabel: UILabel!

    override func layoutSubviews() {
        super.layoutSubviews()
        render()
    }

    func animateIn(delay: TimeInterval, duration: TimeInterval) {
        fadeIn(delay: delay, duration: duration)
    }

    func animateMedalProgress(to medalTo: Int) {
        timer?.invalidate()
        var times = 0
        let medalFrom = medalCount
        let maxTimes = 20
        timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { [weak self] _ in
            self?.medalCount = ((maxTimes - times) * medalFrom + (times * medalTo)) / maxTimes
            self?.render()
            times += 1
            if times > maxTimes {
                self?.timer?.invalidate()
                self?.fadeIn(delay: 0.3, duration: 1.0, fromAlpha: 1.0, toAlpha: 0.9)
                return
            }
        }
    }

    func render() {
        let lowLevel = Level(medalCount: medalCount)
        var majorSize: CGFloat = 4

        if isFinishedPageMode {
            majorSize = lowLevel.rawValue < 8 ? 5 : 4
        }

        // lvl text
        let lvTitle = lowLevel.shortTitle
        lvlLabel.attributedText = getStrokeText(lvTitle,
                                                .white,
                                                strokeWidth: Float(-0.3 * step),
                                                strokColor: .black,
                                                font: MyFont.bold(ofSize: majorSize * step))

        // medal count
        medalCountLabel.attributedText = getStrokeText("\(medalCount)",
                                                       myOrange,
                                                       strokeWidth: Float(-0.6 * step), strokColor: .black,
                                                       font: MyFont.heavyDigit(ofSize: (majorSize + 1) * step))
        let rect = medalCountLabel.frame
        medalCountLabel.sizeToFit()
        medalCountLabel.moveToRight(rect)

        medalView.frame.size.width = majorSize * step * 0.9
        medalView.frame.size.height = majorSize * step * 0.9
        medalCountLabel.centerY(medalView.frame)
        lvlLabel.centerY(medalView.frame)

        // medal position
        medalView.frame.origin.x = medalCountLabel.x0 -
            medalView.frame.width -
            step / 2

        // medal higher bound
        lvlEndLabel.text = "\((lowLevel.rawValue + 1) * medalsPerLevel)"

        // medal lower bound
        lvlStartLabel.text = "\(lowLevel.rawValue * medalsPerLevel)"

        if isFinishedPageMode {
            lvlEndLabel.isHidden = true
            lvlStartLabel.isHidden = true
        }

        // bar
        progressBarMid.backgroundColor = lowLevel.color.withSaturation(1)
        let percentage = medalCount > 500 ?
            1.0 : CGFloat(medalCount % 50) / 50.0
        progressBarMid.frame.size.width = frame.width * percentage

        var barHeight: CGFloat = 1
        if isFinishedPageMode { barHeight = 4 }
        progressBarBack.frame.size.height = barHeight * step
        progressBarMid.frame.size.height = barHeight * step
        progressBarFront.frame.size.height = barHeight * step

        if isFinishedPageMode { progressBarBack.alpha = 0.7 }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }

    private func sharedInit() {
        frame.size.width = screen.width * 34 / 48
        let lowLevel = Level(medalCount: medalCount)
        // lvl text
        let attrText = getStrokeText(lowLevel.lvlTitle,
                                     isFinishedPageMode ? minorTextColor : .white,
                                     strokeWidth: Float(-0.3 * step),
                                     strokColor: .black,
                                     font: MyFont.bold(ofSize: 4 * step))

        lvlLabel = addAttrText(x: 0, y: 0, h: 6,
                               text: attrText)
        lvlLabel.textAlignment = .left

        drawMedal(medalCount, x: 17, y: 1)

        // medal higher bound
        var medalText = "\((lowLevel.rawValue + 1) * medalsPerLevel)"
        lvlEndLabel = addText(x: 24, y: 7, w: 10, h: 3,
                              text: medalText, color: minorTextColor)
        lvlEndLabel.textAlignment = .right

        // medal lower bound
        medalText = "\(lowLevel.rawValue * medalsPerLevel)"
        lvlStartLabel = addText(x: 0, y: 7, w: 10, h: 3,
                                text: medalText, color: minorTextColor)
        lvlStartLabel.textAlignment = .left

        // bar
        progressBarBack = UIView()
        progressBarBack.backgroundColor = progressBackGray
        layout(0, 6, 34, 1, progressBarBack)
        progressBarBack.roundBorder(radius: step / 2)
        addSubview(progressBarBack)

        progressBarMid = UIView()
        progressBarMid.backgroundColor = lowLevel.color.withSaturation(1)
        progressBarMid.roundBorder(radius: step / 2)
        progressBarMid.frame = progressBarBack.frame
        let percentage = medalCount > 500 ?
            1.0 : CGFloat(medalCount % 50) / 50.0
        progressBarMid.frame.size.width = progressBarBack.frame.width * percentage
        addSubview(progressBarMid)

        progressBarFront = UIView()
        progressBarFront.backgroundColor = .clear
        progressBarFront.roundBorder(width: 0.5, radius: step / 2, color: .black)
        progressBarFront.frame = progressBarBack.frame
        addSubview(progressBarFront)
    }

    private func drawMedal(_ medalCount: Int, x: Int, y: Int) {
        let h = 6
        let textSize = 5 * step
        let medalW = 4

        // medal
        medalView = MedalView()
        layout(x + 1, y, medalW, medalW, medalView)
        addSubview(medalView)

        // medal count
        let attrTitle = getStrokeText(
            "\(medalCount)",
            myOrange,
            strokeWidth: Float(-0.6 * step), strokColor: .black,
            font: MyFont.heavyDigit(ofSize: textSize)
        )
        let label = addAttrText(x: x + medalW + 2, y: y, w: 11, h: h, text: attrTitle)

        let rect = label.frame
        label.sizeToFit()
        label.moveToRight(rect)
        label.centerY(medalView.frame)
        medalView.frame.origin.x = label.x0 -
            medalView.frame.width -
            step / 2
        medalCountLabel = label
    }
}
