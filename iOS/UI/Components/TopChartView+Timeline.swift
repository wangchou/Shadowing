//
//  TopChartView+Timeline.swift
//  今話したい
//
//  Created by Wangchou Lu on 12/23/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

private let context = GameContext.shared
private let i18n = I18n.shared

struct TimelineBox {
    var date: Date
    var row: Int
    var column: Int // right to left
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

// MARK: Timeline Mode
extension TopChartView {
    func renderTimelineMode() {
        gridCount = 16
        backgroundColor = longTermGoalColor.withSaturation(0.3)
        addTimeline()
        addTimelineBottomBar()
    }

    func addTimeline() {
        let dailyGoal = context.gameSetting.dailySentenceGoal
        let today = Date()
        let weekday = Calendar.current.component(.weekday, from: today)
        var timelineBox = TimelineBox(date: today, row: weekday, column: 1)
        //let recordsByDate = getRecordsByDate()
        var index = 0
        let sentencesCounts = getSentenceCountsByDays()
        while timelineBox.column < timelineColumnCount {
            //let dateString = getDateKey(date: timelineBox.date)
            //let color = getColorFrom(records: recordsByDate[dateString])
            let isGoalCompleted = (index < sentencesCounts.count && sentencesCounts[index] >= dailyGoal)
            addTimelineBox(
                row: timelineBox.row,
                column: timelineBox.column,
                color: isGoalCompleted ? .black : .clear
            )
            timelineBox.toYesterday()
            if timelineBox.day == 1 {
                addTimelineTextLabel(row: 0, column: timelineBox.column, text: "\(timelineBox.month)月")
            }
            index += 1
        }
        let weekdayLabels = ["日", "月", "火", "水", "木", "金", "土"]
        for i in 0..<weekdayLabels.count {
            addTimelineTextLabel(row: i + 1, column: 0, text: weekdayLabels[i], color: (i == 0 || i == 6) ? .red : .black)
        }
    }

    func addTimelineBottomBar() {
        let sevenDaysPercentText = String(format: "%d", (100 * sevenDaysCount.f / 7).i)
        let thirtyDaysPercentText = String(format: "%d", (100 * thirtyDaysCount.f / 30).i)

        let topTexts = ["\(continues)", "\(bestCount)", "\(sevenDaysPercentText)%", "\(thirtyDaysPercentText)%", "\(allSentenceCount)"]
        let bottomTexts = [i18n.continues, i18n.best, i18n.last7Days, i18n.last30Days, i18n.sentence]
        for boxIndex in 0..<5 {
            let box = addRect(x: 1 + boxIndex * 3, y: 8, w: 3, h: 2)
            addTimelinePadding(box)
            box.frame.size.width -= stepFloat * 0.3
            box.frame.size.height += stepFloat * 0.2
            box.frame.origin.y += stepFloat * 0.3
            box.roundBorder(borderWidth: 0, cornerRadius: 5, color: .clear)
            box.backgroundColor = .white

            let topText = addText(
                x: 1 + boxIndex * 3, y: 8, w: 4, h: 2,
                text: topTexts[boxIndex],
                font: MyFont.bold(ofSize: stepFloat * 0.7),
                color: rgb(74, 74, 74)
            )
            topText.textAlignment = .center
            topText.centerX(box.frame)
            topText.frame.origin.y += stepFloat * 0.4

            let bottomText = addText(
                x: 1 + boxIndex * 3, y: 9, w: 4, h: 2,
                text: bottomTexts[boxIndex],
                font: MyFont.regular(ofSize: stepFloat * 0.5),
                color: .lightGray
            )
            bottomText.textAlignment = .center
            bottomText.centerX(box.frame)
            bottomText.frame.origin.y += stepFloat * 0.25
        }
    }

    func addTimelineBox(row: Int, column: Int, color: UIColor = myLightText) {
        let width = stepFloat * 0.7
        let box = UIView()
        box.backgroundColor = color
        layout(timelineColumnCount - column, row, 1, 1, box)
        box.frame.size.width = width
        box.frame.size.height = width
        box.roundBorder(borderWidth: 1, cornerRadius: width/2, color: .black)
        addSubview(box)

        addTimelinePadding(box)
    }

    func addTimelineTextLabel(row: Int, column: Int, text: String, color: UIColor = .black) {
        let label = addText(
            x: timelineColumnCount - column,
            y: row,
            w: 3, h: 1,
            text: text,
            font: MyFont.thin(ofSize: stepFloat * 0.7),
            color: color
        )
        if row == 0 { // month labels
            label.frame.origin.y += stepFloat * (-0.1 + timelineYPadding)
        } else {
            label.frame.origin.y += stepFloat * (-0.2 + timelineYPadding)
        }
        label.frame.origin.x += stepFloat * timelineXPadding
    }

    func addTimelinePadding(_ view: UIView) {
        view.frame.origin.y += stepFloat * timelineYPadding
        view.frame.origin.x += stepFloat * timelineXPadding
    }
}
