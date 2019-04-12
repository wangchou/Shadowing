//
//  DailyGoalView.swift
//  今話したい
//
//  Created by Wangchou Lu on 4/12/31 H.
//  Copyright © 31 Heisei Lu, WangChou. All rights reserved.
//
import UIKit

private let context = GameContext.shared

class ProgressCircleView: UIView, GridLayout, ReloadableView {
    var gridCount: Int = 24

    var axis: GridAxis = .horizontal

    var spacing: CGFloat = 0

    var frontCircle: CircleView!
    var percentLabel: UILabel!
    var goalLabel: UILabel!

    var percent: Float = 1.0
    var lvl: Level = .lv5
    var title = "每日50文"

    var percentageText: String {
        if percent >= 1.0 { return "完 成" }

        return String(format: "%.0f", percent * 100) + "%"
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    func sharedInit() {
        viewWillAppear()
    }

    func viewWillAppear() {
        removeAllSubviews()
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }

        let path = UIBezierPath(ovalIn: bounds)
        let backgroundLayer = CAShapeLayer()
        backgroundLayer.path = path.cgPath
        backgroundLayer.fillColor = percent < 1.0 ? UIColor.clear.cgColor :
                                                    lvl.color.withSaturation(1.0).cgColor
        layer.addSublayer(backgroundLayer)

        let lineWidth = stepFloat * 2
        let backCircle = CircleView(frame: bounds)
        backCircle.lineWidth = lineWidth
        backCircle.lineColor = rgb(120, 120, 120)
        addSubview(backCircle)

        frontCircle = CircleView(frame: bounds)
        frontCircle.lineWidth = lineWidth
        frontCircle.lineColor = lvl.color.withSaturation(1.0)
        frontCircle.percent = percent.c
        addSubview(frontCircle)

        percentLabel = addText(x: 3, y: 3, w: 30, h: 9,
                               text: percent >= 0 ? percentageText : "0%",
                               font: MyFont.bold(ofSize: getFontSize(h: 9)),
                               color: .white)
        percentLabel.textAlignment = .center
        percentLabel.centerIn(bounds)

        let subLabel = addText(x: 3, y: -11, w: 50, h: 9,
                                text: title,
                                font: MyFont.regular(ofSize: getFontSize(h: 12)),
                                color: .white)
        subLabel.textAlignment = .center
        subLabel.centerX(bounds)
    }
}
