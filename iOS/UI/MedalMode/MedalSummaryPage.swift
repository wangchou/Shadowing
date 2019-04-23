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
    var tableData: [Summary] = []
    var topView: MedalSummaryTopView!
    var tableTitleBar: UIView!
    var topSubviews: [UIView] = []
    var y: Int {
        return Int((getTopPadding() - 20)/step)
    }
    var tableView: UITableView!

    func viewWillAppear() {
        tableData = getSummaryByDays()
        removeAllSubviews()
        addTopView()
        addTableTitleBar()
        addBottomTable()
        addCloseButton()
    }

    private func addTopView() {
        topView = MedalSummaryTopView()
        topView.tableData = tableData
        layout(0, 0, 48, 32+y, topView)
        addSubview(topView)
    }

    private func addTableTitleBar() {
        tableTitleBar = addRect(x: 0, y: y+32, w: 48, h: 6, color: rgb(228, 182, 107))
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
    }

    private func addBottomTable() {
        tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: SummaryTableCell.id)

        tableView.rowHeight = step * 6
        tableView.dataSource = self
        tableView.frame = CGRect(x: 0,
                                 y: tableTitleBar.frame.y + tableTitleBar.frame.height,
                                 width: screen.width,
                                 height: screen.height -
                                         topView.frame.height -
                                         tableTitleBar.frame.height -
                                         step * 7)
        addSubview(tableView)
    }

    private func addCloseButton() {
        let button = UIButton()
        button.frame = CGRect(x: 0,
                              y: tableView.frame.origin.y + tableView.frame.height,
                              width: screen.width,
                              height: step * 7)
        button.backgroundColor = rgb(74, 74, 74)
        button.setTitle("x", for: .normal)
        button.titleLabel?.font = MyFont.regular(ofSize: step * 4)
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
        let cell: SummaryTableCell = {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SummaryTableCell.id) as? SummaryTableCell else {
                return SummaryTableCell(style: .default, reuseIdentifier: SummaryTableCell.id)
            }
            return cell
        }()

        let data = tableData[indexPath.row]
        cell.timeString = getDateString(date: data.date)
        cell.medalCount = data.medalCount
        cell.goalPercent = data.sentenceCount.f / context.gameSetting.dailySentenceGoal.f
        cell.playTime = data.duration

        //cell.textLabel?.text = dateString + medalString + senteneCountString + durationstring

        return cell
    }
}

class SummaryTableCell: UITableViewCell, GridLayout, ReloadableView {
    static let id = "SummaryTableCell"

    var timeLabel = UILabel()
    var medalCountLabel = UILabel()
    var goalPercentLabel = UILabel()
    var playTimeLabel = UILabel()

    var timeString: String = "11/11 日" {
        didSet {
            timeLabel.text = timeString
            timeLabel.frame.size.height = frame.height
        }
    }
    var medalCount: Int = 10 {
        didSet {
            let medalCountText = "\(medalCount >= 0 ? "+" : "")\(medalCount)"
            medalCountLabel.attributedText = getStrokeText(medalCountText,
                                                           .red,//medalCount > 0 ? myGreen :
                                                           //(medalCount == 0 ? .white : myRed),
                                                           strokeWidth: Float(step/4),
                                                           strokColor: .black,
                                                           font: MyFont.heavyDigit(ofSize: step * 4))
        }
    }
    var goalPercent: Float = 0.3 {
        didSet {
            let percentText = goalPercent >= 1 ? "完成" :"\(String(format: "%.0f", goalPercent * 100))%"
            let color = goalPercent > 1 ? myBlue :
                       (goalPercent >= 0.8 ? myGreen :
                       (goalPercent >= 0.6 ? myOrange: myRed))
            goalPercentLabel.text = percentText
            goalPercentLabel.textColor = color
        }
    }
    var playTime: Int = 1000 {
        didSet {
            let playTimeText = String(format: "%.1fm", playTime.f/60.0)
            playTimeLabel.text = playTimeText
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        frame.size.width = screen.width
        frame.size.height = step * 6
        addSubview(timeLabel)
        timeLabel.textAlignment = .center
        timeLabel.font = MyFont.regular(ofSize: step * 3)
        timeLabel.backgroundColor = rgb(155, 155, 155)
        addSubview(medalCountLabel)
        medalCountLabel.textAlignment = .center
        addSubview(goalPercentLabel)
        goalPercentLabel.textAlignment = .center
        goalPercentLabel.font = MyFont.regular(ofSize: step * 3)
        addSubview(playTimeLabel)
        playTimeLabel.textAlignment = .center
        playTimeLabel.font = MyFont.regular(ofSize: step * 3)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layout(0, 0, 15, 6, timeLabel)
        layout(15, 0, 11, 6, medalCountLabel)
        layout(26, 0, 11, 6, goalPercentLabel)
        layout(37, 0, 11, 6, playTimeLabel)
    }
    func viewWillAppear() {
    }
}
