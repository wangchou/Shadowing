//
//  MedalSummaryPage.swift
//  今話したい
//
//  Created by Wangchou Lu on 4/19/31 H.
//  Copyright © 31 Heisei Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

private let context = GameContext.shared

class MedalSummaryPage: UIViewController {
    static let id = "MedalSummaryPage"
    var medalSummaryPageView: MedalSummaryPageView? {
        return (view as? MedalSummaryPageView)
    }

    override func loadView() {
        view = MedalSummaryPageView()
        view.frame = CGRect(x: 0, y: 0, width: screen.width, height: screen.height)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        medalSummaryPageView?.viewWillAppear()
    }
}

enum DaysOption: String {
    case oneWeek = "7日"
    case oneMonth = "30日"
    case all = "全部"
}

class MedalSummaryPageView: UIView, GridLayout, ReloadableView {
    var gridCount: Int = 48
    var axis: GridAxis = .horizontal
    var spacing: CGFloat = 0
    var tableData: [Summary] = []
    var topView: UIView!
    var y: Int {
        return Int((getTopPadding() - 20)/stepFloat)
    }

    var totalSummary: Summary {
        var returnSummary = Summary()
        var reversedTable = Array(tableData.reversed())
        for i in 0 ..< reversedTable.count {
            if i + displayDays >= reversedTable.count {
                let summary = reversedTable[i]
                returnSummary.duration += summary.duration
                returnSummary.sentenceCount += summary.sentenceCount
                returnSummary.perfectCount += summary.perfectCount
                returnSummary.greatCount += summary.greatCount
                returnSummary.goodCount += summary.goodCount
                returnSummary.missedCount += summary.missedCount
            }
        }
        return returnSummary
    }

    var dataPoints: [(x: Int, y: Int)] {
        var points: [(x: Int, y: Int)] = []
        var x = 0
        var medalCount = 0
        var reversedTable = Array(tableData.reversed())
        for i in 0 ..< reversedTable.count {
            if i + displayDays >= reversedTable.count {
                points.append((x: x, y: medalCount))
                x += 10
            }
            medalCount += reversedTable[i].medalCount
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

    var tableView: UITableView!

    func viewWillAppear() {
        removeAllSubviews()
        renderTop()
        renderBottomTable()
    }

    private func renderTop() {
        print(getTopPadding())
        backgroundColor = myRed
        tableData = getSummaryByDays()
        
        let totalSummary = self.totalSummary // avoid recalculation

        let subTitleGray = rgb(155, 155, 155)
        let subTitleFont = MyFont.regular(ofSize: stepFloat * 2)

        // MARK: - TOP Area
        topView = addRect(x: 0, y: 0, w: 48, h: 32 + y, color: rgb(60, 60, 60))

        let langLabel = addText(x: 2, y: y + 3, h: 8, text: gameLang == .jp ? "日本語" : "英語", color: .white)
        langLabel.sizeToFit()

        let daysButton = UIButton()
        daysButton.setTitle(daysOption.rawValue, for: .normal)
        daysButton.setTitleColor(.white, for: .normal)
        daysButton.titleLabel?.font = MyFont.regular(ofSize: stepFloat * 2)
        daysButton.backgroundColor = subTitleGray
        daysButton.roundBorder(borderWidth: 0.5, cornerRadius: stepFloat, color: .clear)
        daysButton.sizeToFit()
        daysButton.frame.origin.x = langLabel.frame.origin.x +
                                    langLabel.frame.width +
                                    2 * stepFloat
        daysButton.frame.origin.y = langLabel.frame.origin.y +
                                    langLabel.frame.height -
                                    daysButton.frame.height
        daysButton.frame.size.width += stepFloat
        addSubview(daysButton)
        daysButton.addTarget(self, action: #selector(onDaysButtonClicked), for: .touchUpInside)

        // MARK: - Right Summary Area
        let medalView = MedalView()
        layout(3, y + 3, 3, 3, medalView)
        addSubview(medalView)
        var label = addText(x: 36, y: y + 3, w: 10, h: 3, text: "メダル",
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
        medalView.frame.origin.x = label.frame.origin.x - medalView.frame.width - stepFloat/2

        label = addText(x: 36, y: y+12, w: 10, h: 3, text: "遊びの時間",
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

        label = addText(x: 36, y: y+21, w: 10, h: 3, text: "正しい文",
                        font: subTitleFont,
                        color: subTitleGray)
        label.textAlignment = .right
        label = addText(x: 26, y: y+23, w: 20, h: 5, text: "\(totalSummary.sentenceCount)", color: .white)
        label.textAlignment = .right

        label = addText(x: 0, y: y+28, h: 3,
                        text: "正解 \(totalSummary.perfectCount) | すごい \(totalSummary.greatCount) | いいね \(totalSummary.goodCount) | ミス \(totalSummary.missedCount)",
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
        chart.leftAxisMaximum = axisMax
        chart.leftAxisMinimum = axisMin
        chart.leftAxis.labelTextColor = subTitleGray
        chart.xAxis.enabled = false
        chart.isDrawFill = false
        chart.setDataCount(level: Level.lv2, dataPoints: dataPoints)
        chart.viewWillAppear()
        layout(2, y+9, 29, 20, chart)
        addSubview(chart)

    }

    private func renderBottomTable() {
        // MARK: - Add Bottom TableView
        let tableTitleBar = addRect(x: 0, y: y+32, w: 48, h: 6, color: rgb(228, 182, 107))
        var label = addText(x: 0, y: y+32, w: 15, h: 5, text: i18n.date)
        label.textAlignment = .center
        label.centerY(tableTitleBar.frame)

        label = addText(x: 15, y: y+32, w: 11, h: 5, text: i18n.medal)
        label.textAlignment = .center
        label.centerY(tableTitleBar.frame)

        label = addText(x: 26, y: y+32, w: 11, h: 5, text: i18n.simpleGoalText)
        label.textAlignment = .center
        label.centerY(tableTitleBar.frame)

        label = addText(x: 37, y: y+32, w: 11, h: 5, text: i18n.time)
        label.textAlignment = .center
        label.centerY(tableTitleBar.frame)

        tableView = UITableView()
        tableView.dataSource = self
        tableView.frame = CGRect(x: 0,
                                 y: tableTitleBar.frame.origin.y + tableTitleBar.frame.height,
                                 width: screen.width,
                                 height: screen.height -
                                         topView.frame.height -
                                         tableTitleBar.frame.height -
                                         stepFloat * 7)
        addSubview(tableView)

        // close button
        let button = UIButton()
        button.frame = CGRect(x: 0,
                              y: tableView.frame.origin.y + tableView.frame.height,
                              width: screen.width,
                              height: stepFloat * 7)
        button.backgroundColor = rgb(74, 74, 74)
        button.setTitle("x", for: .normal)
        button.titleLabel?.font = MyFont.regular(ofSize: stepFloat * 4)
        button.setTitleColor(.white, for: .normal)
        button.addTapGestureRecognizer {
            dismissVC()
        }
        addSubview(button)
    }

    private func getDateString(date: Date) -> String {
        let weekdayLabels = ["日", "月", "火", "水", "木", "金", "土"]
        let month = Calendar.current.component(.month, from: date)
        let day = Calendar.current.component(.day, from: date)
        let weekdayIdx = Calendar.current.component(.weekday, from: date) - 1

        return "\(month)/\(day) \(weekdayLabels[weekdayIdx])"
    }

}

extension MedalSummaryPageView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {
                return UITableViewCell(style: .default, reuseIdentifier: "cell")
            }
            return cell
        }()

        let data = tableData[indexPath.row]
        let dateString = getDateString(date: data.date).padWidthTo(12, isBothSide: true)
        let medalString = "\(data.medalCount)".padWidthTo(8)
        let senteneCountString = "\(data.sentenceCount)".padWidthTo(12)
        let durationstring = String(format: "%.1fm", data.duration.f/60).padWidthTo(12)
        cell.textLabel?.text = dateString + medalString + senteneCountString + durationstring

        return cell
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
