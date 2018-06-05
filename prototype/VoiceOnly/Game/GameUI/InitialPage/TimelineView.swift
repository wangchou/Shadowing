//
//  Timeline.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/23.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

private let context = GameContext.shared

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

class TimelineView: UIView, ReloadableView {
    var boxWidth = 12
    var boxSpacing = 2
    var yPadding = 2

    let dateFormatter = DateFormatter()

    func viewWillAppear() {
        boxWidth = Int((self.frame.height - boxSpacing.c * 9) / 8)
        dateFormatter.dateFormat = "yyyy MM dd"

        self.removeAllSubviews()

        let today = Date()
        let weekday = Calendar.current.component(.weekday, from: today)
        var timelineBox = TimelineBox(date: today, row: weekday, column: 1)
        let columnCount = Int(self.frame.width)/(boxWidth + boxSpacing)
        let recordsByDate = getRecordsByDate()
        while timelineBox.column < columnCount {
            let dateString = dateFormatter.string(from: timelineBox.date)
            let color = getColorFrom(records: recordsByDate[dateString])
            addBox(row: timelineBox.row, column: timelineBox.column, color: color)
            timelineBox.toYesterday()
            if timelineBox.day == 1 {
                addTextLabel(row: 0, column: timelineBox.column, text: "\(timelineBox.month)月")
            }
        }
        addTextLabel(row: 2, column: 0, text: "月")
        addTextLabel(row: 4, column: 0, text: "水")
        addTextLabel(row: 6, column: 0, text: "金")
    }

    func getColorFrom(records: [GameRecord]?) -> UIColor {
        guard let records = records, !records.isEmpty else { return myLightText }
        var sumRed = 0.c
        var sumGreen = 0.c
        var sumBlue = 0.c
        var sumAlpha: CGFloat = 0.33
        for record in records {
            let color = record.level.color
            var red = 0.c
            var green = 0.c
            var blue = 0.c
            var alpha = 0.c
            color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            sumRed += red
            sumGreen += green
            sumBlue += blue
        }
        sumRed *= 255 / records.count.c
        sumGreen *= 255 / records.count.c
        sumBlue *= 255 / records.count.c
        if records.count >= 3 { sumAlpha = 0.66 }
        if records.count >= 7 { sumAlpha = 1.0 }
        return rgb(sumRed.f, sumGreen.f, sumBlue.f, sumAlpha.f)
    }

    func getRecordsByDate() -> [String: [GameRecord]] {
        var recordsByDate: [String: [GameRecord]] = [:]
        context.gameHistory.forEach {
            let dateString = dateFormatter.string(from: $0.startedTime)
            if recordsByDate[dateString] != nil {
                recordsByDate[dateString]?.append($0)
            } else {
                recordsByDate[dateString] = [$0]
            }
        }
        return recordsByDate
    }

    func addTextLabel(row: Int, column: Int, text: String) {
        let label = UILabel()
        label.frame = getFrame(row: row, column: column)
        label.frame.size.width = CGFloat(boxWidth * 3)
        label.text = text
        label.font = MyFont.thin(ofSize: CGFloat(boxWidth))
        self.addSubview(label)
    }

    func addBox(row: Int, column: Int, color: UIColor = myLightText) {
        let box = UIView()
        box.backgroundColor = color
        box.frame = getFrame(row: row, column: column)
        box.layer.cornerRadius = 1.5
        self.addSubview(box)
    }

    // column from left to right
    // row from top to down
    func getFrame(row: Int, column: Int) -> CGRect {
        return CGRect(
            x: Int(self.frame.width) - (boxWidth + boxSpacing) * (column + 1),
            y: (boxWidth + boxSpacing) * row + yPadding,
            width: boxWidth,
            height: boxWidth
        )
    }
}
