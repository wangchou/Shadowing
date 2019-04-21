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

class MedalSummaryPageView: UIView, GridLayout, ReloadableView {
    var gridCount: Int = 48
    var axis: GridAxis = .horizontal
    var spacing: CGFloat = 0
    var tableData: [Summary] = []

    var dataPoints: [(x: Int, y: Int)] {
        var points: [(x: Int, y: Int)] = []
        var x = 0
        var medalCount = 0
        for summary in tableData {
            points.append((x: x, y: medalCount))
            x += 10
            medalCount += summary.medalCount
        }
        return points
    }

    var tableView: UITableView!

    func viewWillAppear() {
        removeAllSubviews()
        backgroundColor = myRed
        tableData = getSummaryByDays()

        let subTitleGray = rgb(155, 155, 155)
        let subTitleFont = MyFont.regular(ofSize: stepFloat * 2)
        var totalSummary = tableData.reduce(Summary()) { (result, summary) in
            var totalSummary = result
            totalSummary.duration += summary.duration
            totalSummary.sentenceCount += summary.sentenceCount
            totalSummary.perfectCount += summary.perfectCount
            totalSummary.greatCount += summary.greatCount
            totalSummary.goodCount += summary.goodCount
            totalSummary.missedCount += summary.missedCount
            return totalSummary
        }

        // Top Area
        let topView = addRect(x: 0, y: 0, w: 48, h: 32, color: rgb(74, 74, 74))
        addText(x: 2, y: 3, h: 8, text: i18n.language, color: .white)
        let medalView = MedalView()
        layout(3, 3, 3, 3, medalView)
        addSubview(medalView)
        var label = addText(x: 36, y: 4, w: 10, h: 3, text: "メダル",
                            font: subTitleFont,
                            color: subTitleGray)
        label.textAlignment = .right

        label = addText(x: 30, y: 6, w: 16, h: 5, text: "\(context.gameMedal.count)", color: .white)
        label.textAlignment = .right
        let originFrame = label.frame
        label.sizeToFit()
        label.centerY(originFrame)
        label.moveToRight(originFrame)
        medalView.centerY(label.frame)
        medalView.frame.origin.x = label.frame.origin.x - medalView.frame.width - stepFloat/2

        label = addText(x: 36, y: 12, w: 10, h: 3, text: "遊びの時間",
                        font: subTitleFont,
                        color: subTitleGray)
        label.textAlignment = .right
        let hours = totalSummary.duration/3600
        let mins = (totalSummary.duration%3600)/60
        let secs = totalSummary.duration % 60
        func padZero(_ value: Int) -> String {
            return value < 10 ? "0\(value)" : "\(value)"
        }

        label = addText(x: 26, y: 14, w: 20, h: 5,
                        text: "\(padZero(hours)):\(padZero(mins)):\(padZero(secs))",
                        color: .white)
        label.textAlignment = .right

        label = addText(x: 36, y: 20, w: 10, h: 3, text: "正しい文",
                        font: subTitleFont,
                        color: subTitleGray)
        label.textAlignment = .right
        label = addText(x: 26, y: 22, w: 20, h: 5, text: "\(totalSummary.sentenceCount)", color: .white)
        label.textAlignment = .right

        label = addText(x: 0, y: 28, h: 3,
                        text: "正解 \(totalSummary.perfectCount) | すごい \(totalSummary.greatCount) | いいね \(totalSummary.goodCount) | ミス \(totalSummary.missedCount)",
                        font: subTitleFont,
                        color: subTitleGray)
        label.textAlignment = .center

        // Chart
        let chart = LineChart()
        chart.color = .white
        chart.lineColor = .white
        chart.leftAxisMaximum = 500
        chart.leftAxisMinimum = 0
        chart.xAxis.enabled = false
        chart.setDataCount(level: Level.lv2, dataPoints: dataPoints)
        chart.viewWillAppear()
        layout(2, 10, 28, 20, chart)
        addSubview(chart)

        // tableView
        let tableTitleBar = addRect(x: 0, y: 32, w: 48, h: 6, color: rgb(228, 182, 107))
        label = addText(x: 0, y: 32, w: 15, h: 5, text: i18n.date)
        label.textAlignment = .center
        label.centerY(tableTitleBar.frame)

        label = addText(x: 15, y: 32, w: 11, h: 5, text: i18n.medal)
        label.textAlignment = .center
        label.centerY(tableTitleBar.frame)

        label = addText(x: 26, y: 32, w: 11, h: 5, text: i18n.simpleGoalText)
        label.textAlignment = .center
        label.centerY(tableTitleBar.frame)

        label = addText(x: 37, y: 32, w: 11, h: 5, text: i18n.time)
        label.textAlignment = .center
        label.centerY(tableTitleBar.frame)

        tableView = UITableView()
        tableView.dataSource = self
        tableView.frame = CGRect(x: 0,
                                 y: tableTitleBar.frame.origin.y + tableTitleBar.frame.height,
                                 width: screen.width,
                                 height: screen.height - topView.frame.height - tableTitleBar.frame.height - stepFloat * 6)
        addSubview(tableView)

        // close button
        let button = UIButton()
        button.frame = CGRect(x: 0,
                              y: tableView.frame.origin.y + tableView.frame.height,
                              width: screen.width,
                              height: stepFloat * 6)
        button.backgroundColor = rgb(74, 74, 74)
        button.setTitle("x", for: .normal)
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
}
