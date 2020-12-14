//
//  TopicFilterBarView.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 10/19/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import UIKit

var isTopicOn: [String: Bool] = [abilities[0]: true]
class TopicFilterBarView: UIScrollView, GridLayout, ReloadableView {
    var gridCount: Int = 5

    var barWidth: CGFloat {
        return max(screen.width, 15 + (abilities.count.c - 1) * 55)
    }

    func render() {
        removeAllSubviews()

        let tagPoints = getTagPoints()
        let tagMaxPoints = getTagMaxPoints()

        for i in 0 ..< abilities.count {
            let buttonTitle = i18n.isZh ? abilities[i] : jaAbilities[i]
            let zhTitle = getZhTitle(str: buttonTitle)
            addButton(title: buttonTitle,
                      index: i,
                      percent: (tagPoints["#" + zhTitle] ?? 0).c /
                          (tagMaxPoints["#" + zhTitle] ?? 100).c)
        }
        contentSize = CGSize(width: barWidth, height: 50)
        delaysContentTouches = true
        canCancelContentTouches = true
        addSeparateLine()
    }

    private func getZhTitle(str: String) -> String {
        if str == i18n.all { return str }
        return i18n.isZh ? str : abilities[jaAbilities.firstIndex(of: str) ?? 0]
    }

    override func touchesShouldCancel(in _: UIView) -> Bool {
        return true
    }

    func addButton(title: String, index: Int, percent: CGFloat) {
        let buttonFrame = CGRect(x: 6 + index * 50, y: 11, width: 40, height: 40)

        let backCircle = CircleView(frame: buttonFrame)
        backCircle.lineWidth = 3

        addSubview(backCircle)
        let titleLabel = addText(x: 0, y: 0, w: 5, h: 1,
                                 text: title,
                                 font: MyFont.regular(ofSize: 14))
        titleLabel.textAlignment = .center
        titleLabel.centerIn(buttonFrame)

        let zhTitle = getZhTitle(str: title)

        let button = CircleView(frame: buttonFrame)
        button.lineWidth = 3
        button.percent = percent

        var percentColor = UIColor.black
        if  percent < 0.02 {
            percentColor = .black
        } else if percent < 0.3 {
            percentColor = myRed
        } else if percent < 0.6 {
            percentColor = myOrange
        } else if percent < 0.8 {
            percentColor = myGreen
        } else {
            percentColor = myBlue
        }

        if let isOn = isTopicOn[zhTitle],
           isOn {
            backCircle.lineColor = percentColor.whiteBlend(0.3)
            backCircle.fillColor = percentColor.whiteBlend(0.1)
            button.lineColor = percentColor
            titleLabel.textColor = darkBackground
        } else {
            backCircle.lineColor = myLightGray
            backCircle.fillColor = lightestGray
            button.lineColor = percentColor
            titleLabel.textColor = darkBackground
        }

        button.addTapGestureRecognizer { [weak self] in
            for i in 0 ..< abilities.count {
                let buttonTitle = i18n.isZh ? abilities[i] : jaAbilities[i]
                if let title = self?.getZhTitle(str: buttonTitle) {
                    isTopicOn[title] = zhTitle == title
                }
            }
            self?.render()
            NotificationCenter.default.post(
                name: .topicFlagChanged,
                object: nil
            )
        }

        addSubview(button)
    }

    func addSeparateLine() {
        let line = UIView()
        line.frame = frame
        line.frame.origin.y = frame.size.height - 0.5
        line.frame.size.width = barWidth
        line.frame.size.height = 0.5
        line.backgroundColor = rgb(240, 240, 240)
        addSubview(line)
    }
}
