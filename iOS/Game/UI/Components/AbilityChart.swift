//
//  AbilityChart.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 10/1/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import UIKit
import Charts

private let abilities = ["旅遊", "日常", "雜談", "戀愛", "論述", "敬語", "互動", "表達"]
private let fontSize = screen.width * 12 / 320

@IBDesignable
class AbilityChart: UIView {
    var radarChartView: RadarChartView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }

    override func prepareForInterfaceBuilder() {
        sharedInit()
    }

    func sharedInit() {
        radarChartView = RadarChartView()
        self.backgroundColor = .clear
        self.addSubview(radarChartView)
        radarChartView.frame = self.frame
        setChartData()
    }
}

extension AbilityChart: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return abilities[Int(value) % abilities.count]
    }
}

extension AbilityChart: ChartViewDelegate {
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
        let entries1 = abilities.map { tag -> RadarChartDataEntry in
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
