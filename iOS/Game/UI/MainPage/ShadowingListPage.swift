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

        let height = screen.width * 120/320
        topView.frame.size.height = height + 5
        timeline.frame.size.height = height
        radarChartView.frame.size.height = height - 10
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
        let activities = ["旅遊", "日常一", "日常二", "戀愛", "敬語", "互動", "論述", "雜談"]
        return activities[Int(value) % activities.count]
    }
}

extension ShadowingListPage: ChartViewDelegate {
    func setChartData() {
        radarChartView.backgroundColor = .darkGray
        radarChartView.delegate = self

        radarChartView.chartDescription?.enabled = false
        radarChartView.webLineWidth = 1
        radarChartView.innerWebLineWidth = 1
        radarChartView.webColor = .lightGray
        radarChartView.innerWebColor = .lightGray
        radarChartView.webAlpha = 1

        let xAxis = radarChartView.xAxis
        xAxis.labelFont = .systemFont(ofSize: 9, weight: .light)
        xAxis.xOffset = 0
        xAxis.yOffset = 0
        xAxis.valueFormatter = self
        xAxis.labelTextColor = .white

        let yAxis = radarChartView.yAxis
        yAxis.labelFont = .systemFont(ofSize: 9, weight: .light)
        yAxis.labelCount = 5
        yAxis.axisMinimum = 0
        yAxis.axisMaximum = 80
        yAxis.drawLabelsEnabled = false

        let l = radarChartView.legend
        l.horizontalAlignment = .center
        l.verticalAlignment = .top
        l.orientation = .horizontal
        l.drawInside = true
        l.font = .systemFont(ofSize: 10, weight: .light)
        l.xEntrySpace = 7
        l.yEntrySpace = 5
        l.textColor = .white

        radarChartView.animate(xAxisDuration: 1.4, yAxisDuration: 1.4, easingOption: .easeOutBack)
        let mult: UInt32 = 80
        let min: UInt32 = 20
        let cnt = 8

        let block: (Int) -> RadarChartDataEntry = { _ in return RadarChartDataEntry(value: Double(arc4random_uniform(mult) + min))}
        let entries1 = (0..<cnt).map(block)
        let entries2 = (0..<cnt).map(block)

        let set1 = RadarChartDataSet(values: entries1, label: "上週")
        set1.setColor(UIColor(red: 103/255, green: 110/255, blue: 129/255, alpha: 1))
        set1.fillColor = UIColor(red: 103/255, green: 110/255, blue: 129/255, alpha: 1)
        set1.drawFilledEnabled = true
        set1.fillAlpha = 0.7
        set1.lineWidth = 2
        set1.drawHighlightCircleEnabled = true
        set1.setDrawHighlightIndicators(false)

        let set2 = RadarChartDataSet(values: entries2, label: "本週")
        set2.setColor(UIColor(red: 121/255, green: 162/255, blue: 175/255, alpha: 1))
        set2.fillColor = UIColor(red: 121/255, green: 162/255, blue: 175/255, alpha: 1)
        set2.drawFilledEnabled = true
        set2.fillAlpha = 0.7
        set2.lineWidth = 2
        set2.drawHighlightCircleEnabled = true
        set2.setDrawHighlightIndicators(false)

        let data = RadarChartData(dataSets: [set1, set2])
        data.setValueFont(.systemFont(ofSize: 8, weight: .light))
        data.setDrawValues(false)
        data.setValueTextColor(.white)

        radarChartView.data = data
    }
}
