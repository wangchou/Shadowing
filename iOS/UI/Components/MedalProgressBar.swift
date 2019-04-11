//
//  MedalProgressBar.swift
//  今話したい
//
//  Created by Wangchou Lu on 4/11/31 H.
//  Copyright © 31 Heisei Lu, WangChou. All rights reserved.
//

import UIKit

private let context = GameContext.shared

class MedalProgressBar: UIView, GridLayout, ReloadableView {
    var gridCount: Int = 34

    var axis: GridAxis = .horizontal

    var spacing: CGFloat = 0

    var medalCount: Int = 0

    var timer: Timer?

    var lvlLabel: UILabel!
    var medalView: MedalView!
    var medalCountLabel: UILabel!
    var progressBarMid: UIView!
    var lvlStartLabel: UILabel!
    var lvlEndLabel: UILabel!

    func viewWillAppear() {
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
                return
            }
        }
    }

    func render() {
        let lowLevel = getMedalLevel(medalCount: medalCount)
        // lvl text
        lvlLabel.attributedText = getStrokeText(lowLevel.lvlTitle,
                                                .white,
                                                strokeWidth: Float(-0.3 * stepFloat),
                                                strokColor: .black,
                                                font: MyFont.bold(ofSize: 4 * stepFloat))

        // medal count
        medalCountLabel.attributedText = getStrokeText("\(medalCount)",
            myOrange,
            strokeWidth: Float(-0.6 * stepFloat), strokColor: .black,
            font: MyFont.heavyDigit(ofSize: 5 * stepFloat))
        let rect = medalCountLabel.frame
        medalCountLabel.sizeToFit()
        medalCountLabel.moveToRight(rect)

        // medal position
        medalView.frame.origin.x = medalCountLabel.frame.origin.x -
                                    medalView.frame.width -
                                    stepFloat/2

        // medal higher bound
        lvlEndLabel.text = "\((lowLevel.rawValue + 1) * medalsPerLevel)"

        // medal lower bound
        lvlStartLabel.text = "\(lowLevel.rawValue * medalsPerLevel)"

        // bar
        progressBarMid.backgroundColor = lowLevel.color.withSaturation(1)
        let percentage = medalCount > 500 ?
            1.0 : CGFloat(medalCount % 50)/50.0
        progressBarMid.frame.size.width = frame.width * percentage
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
        frame.size.width = screen.width*34/48
        let lowLevel = getMedalLevel(medalCount: medalCount)
        // lvl text
        let attrText = getStrokeText(lowLevel.lvlTitle,
                                     .white,
                                     strokeWidth: Float(-0.3 * stepFloat),
                                     strokColor: .black,
                                     font: MyFont.bold(ofSize: 4 * stepFloat))

        lvlLabel = addAttrText(x: 0, y: 0, h: 6,
                               text: attrText)
        lvlLabel.textAlignment = .left

        drawMedal(medalCount, x: 17, y: 1)

        // medal higher bound
        let lightTextColor = rgb(200, 200, 200)
        var medalText = "\((lowLevel.rawValue + 1) * medalsPerLevel)"
        lvlEndLabel = addText(x: 24, y: 7, w: 10, h: 3,
                                text: medalText, color: lightTextColor)
        lvlEndLabel.textAlignment = .right

        // medal lower bound
        medalText = "\(lowLevel.rawValue * medalsPerLevel)"
        lvlStartLabel = addText(x: 0, y: 7, w: 10, h: 3,
                                text: medalText, color: lightTextColor)
        lvlStartLabel.textAlignment = .left

        // bar
        let progressBarBack = UIView()
        progressBarBack.backgroundColor = .white
        layout(0, 6, 34, 1, progressBarBack)
        progressBarBack.roundBorder(cornerRadius: stepFloat/2, color: .clear)
        addSubview(progressBarBack)

        progressBarMid = UIView()
        progressBarMid.backgroundColor = lowLevel.color.withSaturation(1)
        progressBarMid.roundBorder(cornerRadius: stepFloat/2, color: .clear)
        progressBarMid.frame = progressBarBack.frame
        let percentage = medalCount > 500 ?
            1.0 : CGFloat(medalCount % 50)/50.0
        progressBarMid.frame.size.width = progressBarBack.frame.width * percentage
        addSubview(progressBarMid)

        let progressBarFront = UIView()
        progressBarFront.backgroundColor = .clear
        progressBarFront.roundBorder(borderWidth: 0.5, cornerRadius: stepFloat/2, color: .black)
        progressBarFront.frame = progressBarBack.frame
        addSubview(progressBarFront)
    }

    private func drawMedal(_ medalCount: Int, x: Int, y: Int) {
        let h = 6
        let textSize = 5 * stepFloat
        let medalW = 4

        // medal
        medalView = MedalView()
        layout(x + 1, y, medalW, medalW, medalView)
        addSubview(medalView)
        medalView.viewWillAppear()

        // medal count
        let attrTitle = getStrokeText(
            "\(medalCount)",
            myOrange,
            strokeWidth: Float(-0.6 * stepFloat), strokColor: .black,
            font: MyFont.heavyDigit(ofSize: textSize))
        let label = addAttrText(x: x + medalW + 2, y: y, w: 11, h: h, text: attrTitle)

        let rect = label.frame
        label.sizeToFit()
        label.moveToRight(rect)
        label.centerY(medalView.frame)
        medalView.frame.origin.x = label.frame.origin.x -
            medalView.frame.width -
            stepFloat/2
        medalCountLabel = label
    }
}
