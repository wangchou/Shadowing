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
    var topView: MedalSummaryTopView!
    var topSubviews: [UIView] = []
    var y: Int {
        return Int((getTopPadding() - 20)/step)
    }
    var tableView: UITableView!

    func viewWillAppear() {
        tableData = getSummaryByDays()
        removeAllSubviews()
        addTopView()
        addBottomTable()
        addCloseButton()
    }

    private func addTopView() {
        topView = MedalSummaryTopView()
        topView.tableData = tableData
        layout(0, 0, 48, 32+y, topView)
        addSubview(topView)
    }

    private func addBottomTable() {
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
