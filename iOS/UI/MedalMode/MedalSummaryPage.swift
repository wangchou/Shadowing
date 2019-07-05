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
        medalSummaryPageView?.render()
    }
}

class MedalSummaryPageView: UIView, GridLayout, ReloadableView {
    var tableData: [Summary] = []
    var tableHeaderView: GridUIView!
    var topView: MedalSummaryTopView!
    var tableTitleBar: UIView!
    var topSubviews: [UIView] = []

    var tableView: UITableView!

    var safeAreaDiffY: Int {
        return getTopPadding() > 20 ? 1 : 0
    }

    func render() {
        backgroundColor = darkBackground
        tableData = getSummaryByDays()
        removeAllSubviews()
        tableHeaderView = GridUIView()
        layout(0, 0, gridCount, 36 - safeAreaDiffY, tableHeaderView)
        addTopView()
        addTableTitleBar()
        addBottomTable()
        addCloseButton()
    }

    private func addTopView() {
        topView = MedalSummaryTopView()
        topView.tableData = tableData
        layout(0, 0, gridCount, 34 - safeAreaDiffY, topView)
        tableHeaderView.addSubview(topView)
    }

    private func addTableTitleBar() {
        let barY = 30 - safeAreaDiffY
        tableTitleBar = tableHeaderView.addRect(x: 0, y: barY, w: gridCount, h: 6, color: rgb(228, 182, 107))

        var label = tableHeaderView.addText(x: 0, y: barY, w: 15, h: 4, text: i18n.date)
        label.textAlignment = .center
        label.centerY(tableTitleBar.frame)

        label = tableHeaderView.addText(x: 15, y: barY, w: 11, h: 4, text: i18n.medal)
        label.textAlignment = .center
        label.centerY(tableTitleBar.frame)

        label = tableHeaderView.addText(x: 26, y: barY, w: 11, h: 4, text: i18n.simpleGoalText)
        label.textAlignment = .center
        label.centerY(tableTitleBar.frame)

        label = tableHeaderView.addText(x: 37, y: barY, w: 11, h: 4, text: i18n.time)
        label.textAlignment = .center
        label.centerY(tableTitleBar.frame)

        var line = tableHeaderView.addRect(x: 0, y: 0, w: gridCount, h: 1, color: .black)
        line.frame.size.height = 0.5
        line.frame.origin.y = tableTitleBar.y0

        line = tableHeaderView.addRect(x: 0, y: 0, w: gridCount, h: 1, color: .darkGray)
        line.frame.size.height = 0.5
        line.frame.origin.y = tableTitleBar.y1 - 0.5
    }

    private func addBottomTable() {
        let bottomButtonHeight = getBottomButtonHeight()
        tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: MedalSummaryTableCell.id)
        tableView.tableHeaderView = tableHeaderView

        tableView.rowHeight = step * 6
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.separatorColor = rgb(200, 200, 200)
        tableView.dataSource = self
        tableView.delegate = self

        let height = screen.height - bottomButtonHeight - getTopPadding()
        tableView.frame = CGRect(x: 0,
                                 y: getTopPadding(),
                                 width: screen.width,
                                 height: height)
        addSubview(tableView)
    }

    private func addCloseButton() {
        let bgRect = UIView()
        bgRect.frame = CGRect(x: 0,
                              y: tableView.y1,
                              width: screen.width,
                              height: getBottomButtonHeight())
        bgRect.backgroundColor = rgb(180, 180, 180)
        addSubview(bgRect)
        let button = UIButton()
        button.frame = bgRect.frame
        button.frame.size.height = getBottomButtonTextAreaHeight()
        button.backgroundColor = rgb(180, 180, 180)
        button.setTitle("X", for: .normal)
        button.setTitleColor(.lightGray, for: .highlighted)
        button.titleLabel?.font = getBottomButtonFont()
        button.setTitleColor(.black, for: .normal)
        button.addTapGestureRecognizer {
            dismissVC()
        }
        addSubview(button)

        let line = addRect(x: 0, y: 0, w: gridCount, h: 1, color: .darkGray)
        line.frame.size.height = 0.5
        line.frame.origin.y = button.y0
    }

    private func getDateString(date: Date) -> String {
        let weekdayLabels = i18n.isZh ? ["日", "一", "二", "三", "四", "五", "六"] :
            (i18n.isJa ? ["日", "月", "火", "水", "木", "金", "土"] :
                ["S", "M", "T", "W", "T", "F", "S"])
        // let monthLabels = ["Jan.", "Feb.", "Mar.", "Apr.", "May", "Jun.", "Jul.", "Aug.", "Sep.", "Oct.", "Nov.", "Dec."]
        let month = Calendar.current.component(.month, from: date)
        let day = Calendar.current.component(.day, from: date)
        let weekdayIdx = Calendar.current.component(.weekday, from: date) - 1

        return "\(month)/\(day) \(weekdayLabels[weekdayIdx])"
    }
}

extension MedalSummaryPageView: UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return tableData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MedalSummaryTableCell = {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MedalSummaryTableCell.id) as? MedalSummaryTableCell else {
                return MedalSummaryTableCell(style: .default, reuseIdentifier: MedalSummaryTableCell.id)
            }
            cell.selectionStyle = .none
            return cell
        }()

        let data = tableData[indexPath.row]
        cell.timeString = getDateString(date: data.date)
        cell.medalCount = data.medalCount
        cell.goalPercent = data.sentenceCount.f / context.gameSetting.dailySentenceGoal.f
        cell.playTime = data.duration

        return cell
    }
}

extension MedalSummaryPageView: UITableViewDelegate {
    func tableView(_: UITableView, willSelectRowAt _: IndexPath) -> IndexPath? {
        return nil
    }
}

class MedalSummaryTableCell: UITableViewCell, GridLayout {
    static let id = "MedalSummaryTableCell"

    var timeRect = UIView()
    var timeLabel = UILabel()
    var weekLabel = UILabel()
    var medalCountLabel = UILabel()
    var goalPercentLabel = UILabel()
    var playTimeLabel = UILabel()

    var red = UIColor.red.withSaturation(1)
    var green = myGreen.withSaturation(1)
    var orange = myOrange.withSaturation(1)
    var blue = myBlue.withSaturation(1)

    var timeString: String = "11/11 日" {
        didSet {
            let monthAndDay = timeString.split(separator: " ")[0].s
            let weekDay = timeString.split(separator: " ")[1].s
            let isWeekend = weekDay == "日" || weekDay == "六" || weekDay == "土" || weekDay == "S"

            timeLabel.text = monthAndDay
            timeLabel.frame.size.height = frame.height

            weekLabel.text = weekDay
            weekLabel.textColor = isWeekend ? UIColor.red.withBrightness(0.8) : .black

            timeRect.backgroundColor = isWeekend ? rgb(255, 230, 230) : rgb(240, 240, 240)
        }
    }

    var medalCount: Int = 10 {
        didSet {
            let medalCountText = "\(medalCount >= 0 ? "+" : "")\(medalCount)"
            medalCountLabel.attributedText = getStrokeText(medalCountText,
                                                           medalCount > 0 ? green :
                                                               (medalCount == 0 ? .white : red),
                                                           strokeWidth: -1 * Float(step / 3),
                                                           strokColor: .black,
                                                           font: MyFont.heavyDigit(ofSize: step * 3))
        }
    }

    var goalPercent: Float = 0.3 {
        didSet {
            let percentText = goalPercent >= 1 ? i18n.done : "\(String(format: "%.0f", goalPercent * 100))%"
            var color = goalPercent >= 1 ? myBlue :
                (goalPercent >= 0.8 ? green :
                    (goalPercent >= 0.6 ? orange : red))

            if goalPercent == 0 {
                color = .black
            }

            goalPercentLabel.text = percentText
            goalPercentLabel.textColor = color
        }
    }

    var playTime: Int = 1000 {
        didSet {
            if playTime < 3600 {
                playTimeLabel.text = String(format: "%.1fm", playTime.f / 60.0)
            } else {
                playTimeLabel.text = String(format: "%dh%dm", playTime / 3600, (playTime % 3600) / 60)
            }
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        frame.size.width = screen.width
        frame.size.height = step * 6

        addSubview(timeRect)
        timeRect.backgroundColor = rgb(216, 216, 216)

        addSubview(timeLabel)
        timeLabel.textAlignment = .right
        timeLabel.font = MyFont.regular(ofSize: step * 2.5)

        addSubview(weekLabel)
        weekLabel.textAlignment = .center
        weekLabel.font = MyFont.regular(ofSize: step * 2.5)

        addSubview(medalCountLabel)
        medalCountLabel.textAlignment = .right

        addSubview(goalPercentLabel)
        goalPercentLabel.textAlignment = .right
        goalPercentLabel.font = MyFont.regular(ofSize: step * 2.5)

        addSubview(playTimeLabel)
        playTimeLabel.textAlignment = .right
        playTimeLabel.font = MyFont.regular(ofSize: step * 2.5)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layout(0, 0, 14, 6, timeRect)
        layout(0, 0, 8, 6, timeLabel)
        layout(8, 0, 5, 6, weekLabel)
        layout(14, 0, 9, 6, medalCountLabel)
        layout(26, 0, 8, 6, goalPercentLabel)
        layout(37, 0, 9, 6, playTimeLabel)
    }
}
