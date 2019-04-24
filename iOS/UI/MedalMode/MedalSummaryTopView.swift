//
//  MedalSummaryTopView.swift
//  今話したい
//
//  Created by Wangchou Lu on 4/22/31 H.
//  Copyright © 31 Heisei Lu, WangChou. All rights reserved.
//

import UIKit

private let context = GameContext.shared

enum DaysOption {
    case oneWeek
    case oneMonth
    case all
}

private func dayOptionString(option: DaysOption) -> String {
    switch option {
    case .oneWeek:
        return i18n.sevenDays
    case .oneMonth:
        return i18n.thirtyDays
    case .all:
        return i18n.allDays
    }
}

class MedalSummaryTopView: UIView, GridLayout, ReloadableView {
    var y: Int {
        return Int((getTopPadding() - 20)/step)
    }
    var tableData: [Summary] = []
    var totalSummary: Summary {
        var returnSummary = Summary()
        var reversedTable = Array(tableData.reversed())
        for i in 0 ..< reversedTable.count where i + displayDays >= reversedTable.count {
            let summary = reversedTable[i]
            returnSummary.duration += summary.duration
            returnSummary.sentenceCount += summary.sentenceCount
            returnSummary.perfectCount += summary.perfectCount
            returnSummary.greatCount += summary.greatCount
            returnSummary.goodCount += summary.goodCount
            returnSummary.missedCount += summary.missedCount
        }
        return returnSummary
    }

    var dataPoints: [(x: Int, y: Int)] {
        var points: [(x: Int, y: Int)] = []
        var x = 0
        var medalCount = 0
        var reversedTable = Array(tableData.reversed())
        for i in 0 ..< reversedTable.count {
            medalCount += reversedTable[i].medalCount
            if i + displayDays >= reversedTable.count {
                points.append((x: x, y: medalCount))
                x += 10
            }

        }
        return points
    }

    var daysOption: DaysOption = .oneWeek
    var displayDays: Int {
        switch daysOption {
        case .oneWeek:
            return 7
        case .oneMonth:
            return 30
        case .all:
            return 10000
        }
    }

    var axisMax: Double {
        var medalCount = 0
        var medalCountMax = 0
        let reversedTable = Array(tableData.reversed())
        for i in 0 ..< reversedTable.count {
            medalCount += reversedTable[i].medalCount
            if i + displayDays >= reversedTable.count,
                medalCount > medalCountMax {
                medalCountMax = medalCount
            }
        }
        return Double(medalCountMax - medalCountMax%50 + 50)
    }

    var axisMin: Double {
        var medalCount = 0
        var medalCountMin = 1000
        let reversedTable = Array(tableData.reversed())
        for i in 0 ..< reversedTable.count {
            medalCount += reversedTable[i].medalCount
            if i + displayDays >= reversedTable.count,
                medalCount < medalCountMin {
                medalCountMin = medalCount
            }
        }
        return Double(max(0, medalCountMin - medalCountMin%50 - 50))
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        viewWillAppear()
    }

    func viewWillAppear() {
        removeAllSubviews()
        backgroundColor = rgb(60, 60, 60)

        let totalSummary = self.totalSummary // avoid recalculation

        let subTitleGray = rgb(155, 155, 155)
        let subTitleFont = MyFont.regular(ofSize: step * 2)

        let langLabel = addText(x: 2, y: y + 3, h: 8, text: gameLang == .jp ? "日本語" : "英語", color: .white)
        langLabel.sizeToFit()

        // MARK: - Add day option button
        let daysButton = UIButton()
        daysButton.setTitle(dayOptionString(option: daysOption), for: .normal)
        daysButton.setTitleColor(.white, for: .normal)
        daysButton.titleLabel?.font = MyFont.regular(ofSize: step * 3)
        daysButton.backgroundColor = subTitleGray
        daysButton.roundBorder(borderWidth: 0.5, cornerRadius: step, color: .clear)
        daysButton.sizeToFit()
        daysButton.frame.origin.x = langLabel.frame.x +
                                    langLabel.frame.width +
                                    2 * step
        daysButton.frame.size.width += 2 * step
        daysButton.frame.size.height = 4 * step
        daysButton.centerY(langLabel.frame)

        addSubview(daysButton)
        daysButton.addTarget(self, action: #selector(onDaysButtonClicked), for: .touchUpInside)

        // MARK: - Right Summary Area
        let medalView = MedalView()
        layout(3, y + 3, 3, 3, medalView)
        addSubview(medalView)
        var label = addText(x: 36, y: y + 3, w: 10, h: 3, text: i18n.medal,
                            font: subTitleFont,
                            color: subTitleGray)
        label.textAlignment = .right

        label = addText(x: 30, y: y+5, w: 16, h: 5, text: "\(context.gameMedal.count)", color: .white)
        label.textAlignment = .right
        let originFrame = label.frame
        label.sizeToFit()
        label.centerY(originFrame)
        label.moveToRight(originFrame)
        medalView.centerY(label.frame)
        medalView.frame.origin.x = label.frame.x - medalView.frame.width - step/2

        label = addText(x: 36, y: y+12, w: 10, h: 3, text: i18n.playTime,
                        font: subTitleFont,
                        color: subTitleGray)
        label.textAlignment = .right
        let hours = totalSummary.duration/3600
        let mins = (totalSummary.duration%3600)/60
        let secs = totalSummary.duration % 60
        func padZero(_ value: Int) -> String {
            return value < 10 ? "0\(value)" : "\(value)"
        }

        label = addText(x: 26, y: y+14, w: 20, h: 5,
                        text: "\(padZero(hours)):\(padZero(mins)):\(padZero(secs))",
            color: .white)
        label.textAlignment = .right

        label = addText(x: 26, y: y+21, w: 20, h: 3, text: i18n.correctSentences,
                        font: subTitleFont,
                        color: subTitleGray)
        label.textAlignment = .right
        label = addText(x: 23, y: y+23, w: 23, h: 5, text: "\(totalSummary.sentenceCount)", color: .white)
        label.textAlignment = .right

        label = addText(x: 0, y: y+28, h: 3,
                        text: "\(i18n.excellent) \(totalSummary.perfectCount) | \(i18n.great) \(totalSummary.greatCount) | \(i18n.good) \(totalSummary.goodCount) | \(i18n.wrong) \(totalSummary.missedCount)",
            font: subTitleFont,
            color: subTitleGray)
        label.textAlignment = .center

        // MARK: - Chart
        let chart = LineChart()

        chart.circleColor = .white
        chart.lineColor = myOrange
        chart.lineWidth = 1
        chart.circleRadius = daysOption == .oneWeek ? 2 : 0
        chart.lineDashLengths = [10, 0]
        chart.leftAxis.gridColor = .white
        chart.leftAxis.labelFont = MyFont.regular(ofSize: max(step, 12))
        chart.leftAxisMaximum = axisMax
        chart.leftAxisMinimum = axisMin
        chart.leftAxis.labelTextColor = .white
        chart.xAxis.enabled = false
        chart.isDrawFill = false
        chart.setDataCount(level: Level.lv2, dataPoints: dataPoints)
        chart.viewWillAppear()
        layout(2, y+9, 29, 20, chart)
        addSubview(chart)
    }

    @objc func onDaysButtonClicked() {
        switch daysOption {
        case .oneWeek:
            daysOption = .oneMonth
        case .oneMonth:
            daysOption = .all
        case .all:
            daysOption = .oneWeek
        }
        viewWillAppear()
    }
}
