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

    var percentageText: String {
        return "57.5%"
    }

    var goalText: String {
        return "每天說50句"
    }

    var sprintText: String {
        return "衝刺"
    }

    var continuesText: String {
        return "6"
    }

    var dayText: String {
        return "天"
    }

    var sentencesCountText: String {
        return "1800"
    }

    var sentenceText: String {
        return "句"
    }

    var bestText: String {
        return "最佳"
    }
    var bestCountText: String {
        return "7"
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

        backgroundColor = rgb(255, 240, 182)

        //var y = 1
        let topCircle = addRect(x: 6, y: 3, w: 24, h: 24, color: .clear)
        topCircle.roundBorder(borderWidth: stepFloat*1.3,
                              cornerRadius: topCircle.frame.width/2,
                              color: rgb(155, 155, 155))
        topCircle.centerX(getFrame(0, 2, gridCount-2, 24))

        let percentLabel = addText(x: 14, y: 6, w: 30, h: 8,
                                   text: percentageText,
                                   font: MyFont.bold(ofSize: getFontSize(h: 8)),
                                   color: .black)
        percentLabel.textAlignment = .center
        percentLabel.centerIn(topCircle.frame)

        let goalLabel = addText(x: 14, y: 28, w: 30, h: 4,
                                text: goalText,
                                font: MyFont.bold(ofSize: getFontSize(h: 4)))
        goalLabel.textAlignment = .center
        goalLabel.centerX(getFrame(0, 2, gridCount-2, 24))

        addSideBar()
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
