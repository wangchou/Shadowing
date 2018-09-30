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

        let height = screen.width / 2
        topView.frame.size.height = height
        timeline.frame.size.height = height - 20
        radarChartView.frame.size.height = height + 10
    }

    @objc func injected() {
        #if DEBUG
        viewWillAppear(false)
        #endif
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCharacterProfile()
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
        let activities = ["旅遊", "戀愛", "敬語", "互動", "論述", "雜談", "日常一", "日常二"]
        return activities[Int(value) % activities.count]
    }
}

extension ShadowingListPage: ChartViewDelegate {
    func setChartData() {
        radarChartView.delegate = self

        radarChartView.chartDescription?.enabled = false
        radarChartView.webLineWidth = 0.5
        radarChartView.innerWebLineWidth = 0.5
        radarChartView.webColor = myGray
        radarChartView.innerWebColor = myGray
        radarChartView.webAlpha = 1

        let xAxis = radarChartView.xAxis
        xAxis.labelFont = MyFont.thin(ofSize: 10)
        xAxis.xOffset = 0
        xAxis.yOffset = 0
        xAxis.valueFormatter = self
        xAxis.labelTextColor = hashtagColor

        let yAxis = radarChartView.yAxis
        yAxis.labelFont = MyFont.thin(ofSize: 10)
        yAxis.labelCount = 4
        yAxis.axisMinimum = 0
        yAxis.axisMaximum = 80
        yAxis.drawLabelsEnabled = false

        let l = radarChartView.legend
        l.horizontalAlignment = .center
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        l.drawInside = true
        l.font = MyFont.thin(ofSize: 12)
        l.xEntrySpace = 10
        l.yEntrySpace = 5
        l.textColor = .black

        radarChartView.animate(xAxisDuration: 1.4, yAxisDuration: 1.4, easingOption: .easeOutBack)
        let mult: UInt32 = 80
        let min: UInt32 = 20
        let cnt = 8

        let block: (Int) -> RadarChartDataEntry = { _ in return RadarChartDataEntry(value: Double(arc4random_uniform(mult) + min))}
        let entries1 = (0..<cnt).map(block)
        let entries2 = (0..<cnt).map(block)

        let set1 = RadarChartDataSet(values: entries1, label: "七天前")
        set1.setColor(myOrange)
        set1.fillColor = myOrange.withAlphaComponent(0.5)
        set1.drawFilledEnabled = true
        set1.fillAlpha = 0.7
        set1.lineWidth = 0.5
        set1.drawHighlightCircleEnabled = false
        set1.setDrawHighlightIndicators(false)

        let set2 = RadarChartDataSet(values: entries2, label: "現在")
        set2.setColor(myRed)
        set2.fillColor = myRed.withAlphaComponent(0.5)
        set2.drawFilledEnabled = true
        set2.fillAlpha = 0.7
        set2.lineWidth = 0.5
        set2.drawHighlightCircleEnabled = true
        set2.setDrawHighlightIndicators(true)

        let data = RadarChartData(dataSets: [set1, set2])
        data.setValueFont(MyFont.thin(ofSize: 8))
        data.setDrawValues(false)
        data.setValueTextColor(.black)

        radarChartView.data = data
    }
}
