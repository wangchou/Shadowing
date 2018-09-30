//
//  ViewController.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/04/14.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import UIKit
import Charts
import Foundation

private let context = GameContext.shared
private let engine = SpeechEngine.shared
private let activities = ["旅遊", "日常", "雜談", "戀愛", "論述", "敬語", "互動", "表達"]

private let fontSize = screen.width * 12 / 320
class ShadowingListPage: UIViewController {
    @IBOutlet weak var sentencesTableView: UITableView!
    @IBOutlet weak var timeline: TimelineView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topBarView: TopBarView!
    @IBOutlet weak var radarChartView: RadarChartView!

    var timelineSubviews: [String: UIView] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        engine.start()
        addSentences()
        loadGameHistory()
        loadGameSetting()
        loadUserSaidSentencesAndScore()

        topBarView.rightButton.isHidden = true
    }

    @objc func injected() {
        #if DEBUG
        viewWillAppear(false)
        #endif
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCharacterProfile()
        let height = screen.width * 130/320
        topView.frame.size.height = height
        timeline.frame.size.height = height * 120 / 130
        timeline.frame.size.width = height * 200 / 130

        sentencesTableView.reloadData()
        timeline.viewWillAppear()
        setChartData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addGradientSeparatorLine()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func addGradientSeparatorLine() {
        let lightRGBs = [myRed, myOrange, myGreen, myBlue].map { $0.cgColor }
        let layer = CAGradientLayer()
        layer.frame = topView.frame
        layer.frame.origin.y = topView.frame.height - 1.5
        layer.frame.size.height = 1.5
        layer.frame.size.width = screen.size.width
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1.0, y: 0)
        layer.colors = lightRGBs
        topView.layer.insertSublayer(layer, at: 0)
    }
}

extension ShadowingListPage: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allSentences.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SentencesCell", for: indexPath)
        guard let contentCell = cell as? ContentCell else { print("convert content cell error"); return cell }

        let dataSetKey = allSentencesKeys[indexPath.row]
        let attrStr = NSMutableAttributedString()
        attrStr.append(rubyAttrStr(dataSetKey, fontSize: 16))
        if let tags = datasetKeyToTags[dataSetKey],
           !tags.isEmpty {
            attrStr.append(
                rubyAttrStr("\n"+tags.joined(separator: " "), fontSize: 14, color: hashtagColor, isWithStroke: false)
            )
        }

        contentCell.titleLabel.attributedText = attrStr
        let record = findBestRecord(key: dataSetKey)
        contentCell.strockedProgressText = record?.progress
        contentCell.strockedRankText = record?.rank.rawValue

        return contentCell
    }
}

extension ShadowingListPage: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        context.dataSetKey = allSentencesKeys[indexPath.row]
        context.loadLearningSentences(isShuffle: false)
        (UIApplication.getPresentedViewController() as? UIPageViewController)?.goToNextPage()
    }
}

extension ShadowingListPage: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return activities[Int(value) % activities.count]
    }
}

extension ShadowingListPage: ChartViewDelegate {
    func setChartData() {
        radarChartView.delegate = self

        radarChartView.chartDescription?.enabled = false
        radarChartView.webLineWidth = 0.5
        radarChartView.innerWebLineWidth = 0.5
        radarChartView.webColor = myGray.withAlphaComponent(0.7)
        radarChartView.innerWebColor = myGray.withAlphaComponent(0.7)
        radarChartView.webAlpha = 1

        let xAxis = radarChartView.xAxis
        xAxis.labelFont = MyFont.thin(ofSize: fontSize)
        xAxis.xOffset = 0
        xAxis.yOffset = 0
        xAxis.valueFormatter = self
        xAxis.labelTextColor = hashtagColor

        let yAxis = radarChartView.yAxis
        yAxis.labelFont = MyFont.thin(ofSize: fontSize)
        yAxis.labelCount = 3
        yAxis.axisMinimum = 0
        yAxis.axisMaximum = 500
        yAxis.drawLabelsEnabled = false

        let l = radarChartView.legend
        l.horizontalAlignment = .center
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        l.drawInside = true
        l.font = MyFont.thin(ofSize: fontSize)
        l.xEntrySpace = 7
        l.yEntrySpace = 5
        l.textColor = .black
        l.form = .none

        radarChartView.animate(xAxisDuration: 1.4, yAxisDuration: 1.4, easingOption: .easeOutBack)

        let tagScores = getTagScores()
        let entries1 = activities.map { tag -> RadarChartDataEntry in
            if let score = tagScores["#\(tag)"],
               score > 10 {
                return RadarChartDataEntry(value: Double(score))
            }
            return RadarChartDataEntry(value: 40)
        }

        let set1 = RadarChartDataSet(values: entries1, label: "")
        set1.setColor(myOrange)
        set1.fillColor = myOrange.withAlphaComponent(0.3)
        set1.drawFilledEnabled = true
        set1.fillAlpha = 0.5
        set1.lineWidth = 1
        set1.drawHighlightCircleEnabled = false
        set1.setDrawHighlightIndicators(false)

        let data = RadarChartData(dataSets: [set1])
        data.setValueFont(MyFont.thin(ofSize: 8))
        data.setDrawValues(false)
        data.setValueTextColor(.black)

        radarChartView.data = data
    }
}
