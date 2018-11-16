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

        let topCircle = addRect(x: 6, y: 2, w: 24, h: 24, color: .clear)
        topCircle.roundBorder(borderWidth: stepFloat,
                              cornerRadius: topCircle.frame.width/2,
                              color: .lightGray)
        topCircle.centerX(getFrame(0, 2, gridCount, 24))

        let percentLabel = addText(x: 14, y: 4, w: 30, h: 9,
                                   text: "10.5%",
                                   font: MyFont.bold(ofSize: getFontSize(h: 9)))
        percentLabel.textAlignment = .center
        percentLabel.centerIn(getFrame(0, 2, gridCount, 24))

        let streaksLabel = addText(x: 14, y: 20, w: 30, h: 5,
                                   text: "7",
                                   font: MyFont.bold(ofSize: getFontSize(h: 5)),
                                   color: .lightGray)
        streaksLabel.textAlignment = .center
        streaksLabel.centerX(frame)

        let goalLabel = addText(x: 14, y: 27, w: 30, h: 5,
                                text: "唸對50句日文",
                                font: MyFont.bold(ofSize: getFontSize(h: 5)))
        goalLabel.textAlignment = .center
        goalLabel.centerX(frame)
    }
}
