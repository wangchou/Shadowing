//
//  TopicFilterBarView.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 10/19/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import UIKit

var titleForAll = "全部"
var topicFilterFlag: [String: Bool] = [titleForAll: true]
class TopicFilterBarView: UIView, GridLayout, ReloadableView {
    var gridCount: Int = 5

    var axis: GridAxis = .vertical

    var spacing: CGFloat = 0

    func viewWillAppear() {
        removeAllSubviews()

        for i in 0...abilities.count {
            var buttonTitle = ""
            if i == 0 {
                buttonTitle = titleForAll
            } else {
                buttonTitle = abilities[i-1]
            }
            addButton(title: buttonTitle, index: i)
        }
        addSeparateLine()
    }

    func addButton(title: String, index: Int) {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.backgroundColor = .lightGray
        button.titleLabel?.font = MyFont.regular(ofSize: 12)
        button.setTitleColor(.white, for: .normal)
        button.roundBorder(borderWidth: 0, cornerRadius: 20, color: .clear)

        if let isOn = topicFilterFlag[title],
            isOn {
            button.backgroundColor = myBlue.withAlphaComponent(0.5)
            button.roundBorder(borderWidth: 1.5, cornerRadius: 20, color: myBlue)
            button.setTitleColor(.black, for: .normal)
        }

        button.addTapGestureRecognizer {
            if title == titleForAll {
                topicFilterFlag = [titleForAll: true]
            } else {
                topicFilterFlag[titleForAll] = false
                if topicFilterFlag[title] == true {
                    topicFilterFlag[title] = false
                    if !topicFilterFlag.values.contains(true) {
                        topicFilterFlag[titleForAll] = true
                    }
                } else {
                    topicFilterFlag[title] = true
                }
            }
            self.viewWillAppear()
            NotificationCenter.default.post(
                name: .topicFlagChanged,
                object: nil
            )
        }

        button.frame = CGRect(x: 5 + index * 45, y: 5, width: 40, height: 40)

        addSubview(button)
    }

    func addSeparateLine() {
        let line = UIView()
        line.frame = self.frame
        line.frame.origin.y = frame.size.height - 0.5
        line.frame.size.width = screen.size.width
        line.frame.size.height = 0.5
        line.backgroundColor = .lightGray
        addSubview(line)
    }
}
