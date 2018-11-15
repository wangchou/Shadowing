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
        let c = myBlue

        backgroundColor = c.withAlphaComponent(0.07)

        //var y = 1

        let topCircle = addRect(x: 6, y: 3, w: 30, h: 30, color: .white)
        topCircle.roundBorder(borderWidth: 2, cornerRadius: topCircle.frame.width/2, color: c)
        topCircle.centerX(getFrame(0, 3, gridCount, 30))

        let dayLabel = addText(x: 14, y: 6, w: 30, h: 20, text: "10")
        dayLabel.textAlignment = .center
        dayLabel.centerIn(getFrame(0, 2, gridCount, 30))

        let y = 25
        var dot: UIView
        let colors = [myRed, myOrange, myGreen, myBlue, .purple]
        for i in 0...4 {
            dot = addRect(x: 14, y: y, w: 3, h: 3, color: colors[i] == c ? colors[i] : .white)
            dot.roundBorder(borderWidth: 0.5, cornerRadius: dot.frame.width/2, color: colors[i])
            dot.centerX(frame, xShift: 4 * (i.c - 2) * step)
        }

        let strengthLabel = addText(x: 14, y: 28, w: 20, h: 4, text: "最低強度", color: c)
        strengthLabel.textAlignment = .center
        strengthLabel.centerX(frame)

        let timeLabel = addText(x: 14, y: 5, w: 20, h: 4, text: "連續天數", color: .darkGray)
        timeLabel.textAlignment = .center
        timeLabel.centerX(frame)

        addText(x: 3, y: 35, w: 25, h: 4, text: "本次衝刺")
        addText(x: 3, y: 39, w: 25, h: 4, text: "句數：15302句")
        addText(x: 3, y: 43, w: 25, h: 4, text: "時間：30天")
        addText(x: 3, y: 47, w: 25, h: 4, text: "強度：15句/天")

        addText(x: 27, y: 35, w: 25, h: 4, text: "最佳紀錄")
        addText(x: 27, y: 39, w: 25, h: 4, text: "句數：15302句")
        addText(x: 27, y: 43, w: 25, h: 4, text: "時間：23天")
        addText(x: 27, y: 47, w: 25, h: 4, text: "強度：199句/天")
    }
}
