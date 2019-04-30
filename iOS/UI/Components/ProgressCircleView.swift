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

    var frontCircle: CircleView!
    var percentLabel: UILabel!
    var goalLabel: UILabel!

    var percent: Float = 1.0
    var color: UIColor {
        if percent < 0.6 { return myRed }
        if percent < 0.8 { return myOrange }
        if percent < 1.0 { return myGreen }
        return myBlue
    }

    var percentageText: String {
        if percent >= 1.0 { return i18n.done }

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
        //viewWillAppear()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        viewWillAppear()
    }

    func viewWillAppear() {
        removeAllSubviews()
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }

        let path = UIBezierPath(ovalIn: bounds)
        let backgroundLayer = CAShapeLayer()
        backgroundLayer.path = path.cgPath
        backgroundLayer.fillColor = rgb(36, 36, 36).withAlphaComponent(0.5).cgColor
        layer.addSublayer(backgroundLayer)

        let lineWidth = step * 2.2
        let backCircle = CircleView(frame: bounds)
        backCircle.lineWidth = lineWidth
        backCircle.lineColor = progressBackGray
        addSubview(backCircle)

        frontCircle = CircleView(frame: bounds)
        frontCircle.lineWidth = lineWidth
        frontCircle.lineColor = color.withSaturation(1.0)
        frontCircle.percent = percent.c
        addSubview(frontCircle)

        // fix en locale Done text will be too big
        let fontSize = (i18n.isZh || i18n.isJa || percent < 1) ? 8 * step : 6 * step
        let attrText = getStrokeText(percent >= 0 ? percentageText : "0%",
                                     .white,
                                     strokeWidth: Float(-0.3 * step),
                                     strokColor: .black,
                                     font: MyFont.bold(ofSize: fontSize))

        percentLabel = addAttrText(x: 3, y: 3, w: 30, h: 9,
                               text: attrText)
        percentLabel.textAlignment = .center
        percentLabel.centerIn(bounds)

        let subLabel = addText(x: 3, y: 25, w: 50, h: 9,
                               text: i18n.simpleGoalText,
                               font: MyFont.regular(ofSize: 6 * step),
                               color: minorTextColor)

        subLabel.textAlignment = .center
        subLabel.centerX(bounds)
    }
}
