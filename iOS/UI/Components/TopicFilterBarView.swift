//
//  TopicFilterBarView.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 10/19/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import UIKit

let topicForAll = i18n.all
var isTopicOn: [String: Bool] = [topicForAll: true]
class TopicFilterBarView: UIScrollView, GridLayout, ReloadableView {
    var gridCount: Int = 5

    var barWidth: CGFloat {
        return max(screen.width, 15 + abilities.count.c * 55)
    }

    func viewWillAppear() {
        removeAllSubviews()

        let tagPoints = getTagPoints()
        let tagMaxPoints = getTagMaxPoints()

        for i in 0...abilities.count {
            var buttonTitle = ""
            if i == 0 {
                buttonTitle = topicForAll
            } else {
                buttonTitle = i18n.isZh ? abilities[i-1] : jaAbilities[i-1]
            }
            let zhTitle = getZhTitle(str: buttonTitle)
            addButton(title: buttonTitle,
                      index: i,
                      percent: (tagPoints["#" + zhTitle] ?? 0).c /
                               (tagMaxPoints["#"+zhTitle] ?? 100).c
            )
        }
        contentSize = CGSize(width: barWidth, height: 50)
        delaysContentTouches = true
        canCancelContentTouches = true
        addSeparateLine()
    }

    private func getZhTitle(str: String) -> String {
        if str == i18n.all { return str }
        return i18n.isZh ? str : abilities[jaAbilities.index(of: str) ?? 0]
    }

    override func touchesShouldCancel(in view: UIView) -> Bool {
        return true
    }

    func addButton(title: String, index: Int, percent: CGFloat) {
        let buttonFrame = CGRect(x: 6 + index * 50, y: 11, width: 40, height: 40)

        let backCircle = CircleView(frame: buttonFrame)
        backCircle.lineWidth = 2

        addSubview(backCircle)
        let titleLabel = addText(x: 0, y: 0, w: 5, h: 1,
                                 text: title,
                                 font: MyFont.regular(ofSize: 14))
        titleLabel.textAlignment = .center
        titleLabel.centerIn(buttonFrame)

        let zhTitle = getZhTitle(str: title)

        let button = CircleView(frame: buttonFrame)
        button.lineWidth = 2
        button.percent = percent

        if let isOn = isTopicOn[zhTitle],
            isOn {
            backCircle.lineColor = myGray
            backCircle.fillColor = myBlue.withAlphaComponent(0.3)
            button.lineColor = .black
            titleLabel.textColor = .black
        } else {
            backCircle.lineColor = myLightGray
            backCircle.fillColor = lightestGray
            button.lineColor = rgb(100, 100, 100)
            titleLabel.textColor = rgb(60, 60, 60)
        }

        button.addTapGestureRecognizer { [weak self] in

            if zhTitle == topicForAll {
                isTopicOn = [topicForAll: true]
            } else {
                isTopicOn[topicForAll] = false
                if isTopicOn[zhTitle] == true {
                    isTopicOn[zhTitle] = false
                    if !isTopicOn.values.contains(true) {
                        isTopicOn[topicForAll] = true
                    }
                } else {
                    isTopicOn[zhTitle] = true
                }
            }
            self?.viewWillAppear()
            NotificationCenter.default.post(
                name: .topicFlagChanged,
                object: nil
            )
        }

        addSubview(button)
    }

    func addSeparateLine() {
        let line = UIView()
        line.frame = self.frame
        line.frame.origin.y = frame.size.height - 0.5
        line.frame.size.width = barWidth
        line.frame.size.height = 0.5
        line.backgroundColor = rgb(240, 240, 240)
        addSubview(line)
    }
}
