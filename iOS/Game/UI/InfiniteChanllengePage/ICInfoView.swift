//
//  ICInfoView.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 10/10/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import UIKit

private enum Texts: String {
    case precision = "完成率"
    case numOfSentence = "句子數"
}

class ICInfoView: UIView, GridLayout, ReloadableView {
    // GridLayout
    var gridCount: Int = 48

    var axis: GridAxis = .horizontal

    var spacing: CGFloat = 0

    var line1 = "難度：入門"
    var line2 = "假名數：1〜10"
    var line3 = "總句數：50000"

    var bestRank: String? = "SS"
    var bestProgress: String? = "100"
    var progressAttrText: NSAttributedString {
        let attrText = NSMutableAttributedString()
        let font = MyFont.bold(ofSize: getFontSize(h: 11))
        if let string = bestProgress {
            attrText.append(getStrokeText(string.padWidthTo(3), .darkGray, font: font))
            attrText.append(getStrokeText("%", .darkGray, strokeWidth: 0, strokColor: .black, font: UIFont.boldSystemFont(ofSize: 12)))
            return attrText
        } else {
            attrText.append(getStrokeText("??", .lightText, font: font))
            attrText.append(getStrokeText("%", .darkGray, strokeWidth: 0, strokColor: .black, font: UIFont.boldSystemFont(ofSize: 12)))
            return attrText
        }
    }
    var rankAttrText: NSAttributedString {
        let font = MyFont.bold(ofSize: getFontSize(h: 11))
        if  let bestRank = bestRank,
            let rank = Rank(rawValue: bestRank) {
            return getStrokeText(bestRank.padWidthTo(2), rank.color, font: font)
        } else {
            return getStrokeText("?", .lightText, font: font)
        }
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
        frame.size.height = screen.width
        removeAllSubviews()

        var y = 1
        addText(x: 1, y: y, h: 2, text: Texts.precision.rawValue)
        y += 2

        let chart = LineChart()
        layout(1, y, 46, 23, chart)
        addSubview(chart)
        y += 19

        addText(x: 42, y: y, h: 2, text: Texts.numOfSentence.rawValue)
        y += 3

        addRoundRect(x: 2, y: y, w: 44, h: 11, borderColor: .black, radius: 5, backgroundColor: .clear)
        y += 1

        addAttrText(x: 18, y: y, h: 11, text: progressAttrText)
        addAttrText(x: 35, y: y, h: 11, text: rankAttrText)

        addText(x: 3, y: y, h: 3, text: line1)
        addText(x: 19, y: y, h: 3, text: "完成率")
        addText(x: 35, y: y, h: 3, text: "Rank")

        y += 3

        addText(x: 3, y: y, h: 3, text: line2)
        y += 3

        addText(x: 3, y: y, h: 3, text: line3)
        y += 6

        addChallengeButton()
    }

    func addChallengeButton() {
        let button = UIButton()
        button.setTitle("挑      戰", for: .normal)
        button.backgroundColor = .red
        button.titleLabel?.font = MyFont.regular(ofSize: step * 5)
        button.titleLabel?.textColor = myLightText
        button.roundBorder(borderWidth: 1.5, cornerRadius: 5, color: UIColor.white.withAlphaComponent(0.5))

        button.addTapGestureRecognizer {
            if let vc = UIApplication.getPresentedViewController() {
                launchStoryboard(vc, "MessengerGame")
            }
        }

        layout(2, 38, 44, 8, button)

        addSubview(button)
    }
}
