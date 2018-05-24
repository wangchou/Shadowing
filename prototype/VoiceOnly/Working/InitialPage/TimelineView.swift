//
//  Timeline.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/23.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

struct TimelineBox {
    var date: Date
    var row: Int
    var column: Int
    var day: Int {
        return Calendar.current.component(.day, from: date)
    }
    var month: Int {
        return Calendar.current.component(.month, from: date)
    }

    mutating func toYesterday() {
        row -= 1
        if row == 0 {
            row = 7
            column += 1
        }
        var dateComponent = DateComponents()
        dateComponent.day = -1
        if let newDate = Calendar.current.date(byAdding: dateComponent, to: date) {
            date = newDate
        }
    }
}

class TimelineView: UIView {
    let boxWidth = 12
    let boxSpacing = 2
    let yPadding = 2

    func viewWillAppear() {
        self.frame.size.height = CGFloat(yPadding * 2 + (boxWidth + boxSpacing) * 8)

        self.subviews.forEach { $0.removeFromSuperview() }

        let today = Date()
        let weekday = Calendar.current.component(.weekday, from: today)
        var timelineBox = TimelineBox(date: today, row: weekday, column: 1)
        let columnCount = Int(screen.width)/(boxWidth + boxSpacing)
        while timelineBox.column < columnCount {
            addBox(row: timelineBox.row, column: timelineBox.column)
            timelineBox.toYesterday()
            if timelineBox.day == 1 {
                addTextLabel(row: 0, column: timelineBox.column, text: "\(timelineBox.month)月")
            }
        }
        addTextLabel(row: 2, column: 0, text: "月")
        addTextLabel(row: 4, column: 0, text: "水")
        addTextLabel(row: 6, column: 0, text: "金")
    }

    func addTextLabel(row: Int, column: Int, text: String) {
        let label = UILabel()
        label.frame = getFrame(row: row, column: column)
        label.frame.size.width = CGFloat(boxWidth * 3)
        label.text = text
        label.font = MyFont.thinSystemFont(ofSize: CGFloat(boxWidth))
        self.addSubview(label)
    }

    func addBox(row: Int, column: Int, color: UIColor = rgb(224, 224, 224)) {
        let box = UIView()
        box.backgroundColor = rgb(224, 224, 224)
        box.frame = getFrame(row: row, column: column)
        self.addSubview(box)
    }

    // column from left to right
    // row from top to down
    func getFrame(row: Int, column: Int) -> CGRect {
        return CGRect(
            x: Int(screen.width) - (boxWidth + boxSpacing) * (column + 1),
            y: (boxWidth + boxSpacing) * row + yPadding,
            width: boxWidth,
            height: boxWidth
        )
    }
}
