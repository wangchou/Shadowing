//
//  TopicFilterBarView.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 10/19/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import UIKit

let topicForAll = "全部"
var isTopicOn: [String: Bool] = [topicForAll: true]
class TopicFilterBarView: UIScrollView, GridLayout, ReloadableView {
    var gridCount: Int = 5

    var axis: GridAxis = .vertical

    var spacing: CGFloat = 0

    var barWidth: CGFloat {
        return max(screen.width, 15 + abilities.count.c * 50)
    }

    func viewWillAppear() {
//        backgroundColor = lightestGray
        removeAllSubviews()

        let tagPoints = getTagPoints()
        let tagMaxPoints = getTagMaxPoints()

        for i in 0...abilities.count {
            var buttonTitle = ""
            if i == 0 {
                buttonTitle = topicForAll
            } else {
                buttonTitle = abilities[i-1]
            }
            addButton(title: buttonTitle,
                      index: i,
                      percent: (tagPoints["#" + buttonTitle] ?? 0).c /
                               (tagMaxPoints["#"+buttonTitle] ?? 100).c
            )
        }
        contentSize = CGSize(width: barWidth, height: 40)
        delaysContentTouches = true
        canCancelContentTouches = true
        addSeparateLine()
    }

    override func touchesShouldCancel(in view: UIView) -> Bool {
        return true
    }

    func addButton(title: String, index: Int, percent: CGFloat) {
        let buttonFrame = CGRect(x: 8 + index * 45, y: 8, width: 35, height: 35)

        let backCircle = CircleView(frame: buttonFrame)
        backCircle.lineWidth = 1.5

        addSubview(backCircle)
        let titleLabel = addText(x: 0, y: 0, w: 5, h: 1,
                                 text: title,
                                 font: MyFont.regular(ofSize: 12))
        titleLabel.textAlignment = .center
        titleLabel.centerIn(buttonFrame)

        let button = CircleView(frame: buttonFrame)
        button.lineWidth = 1.5
        button.percent = percent

        if let isOn = isTopicOn[title],
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

        button.addTapGestureRecognizer {
            if title == topicForAll {
                isTopicOn = [topicForAll: true]
            } else {
                isTopicOn[topicForAll] = false
                if isTopicOn[title] == true {
                    isTopicOn[title] = false
                    if !isTopicOn.values.contains(true) {
                        isTopicOn[topicForAll] = true
                    }
                } else {
                    isTopicOn[title] = true
                }
            }
            self.viewWillAppear()
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
