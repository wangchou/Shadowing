//
//  AbilityChart.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 10/1/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import UIKit
import Charts

let abilities = ["旅遊", "日常", "雜談", "戀愛", "論述", "敬語", "互動", "表達"]
private let fontSize = screen.width * 12 / 320

@IBDesignable
class AbilityChart: RadarChartView, ChartViewDelegate {
    var wColor: UIColor = myGray.withAlphaComponent(0.7)
    var labelColor: UIColor = hashtagColor
    var labelFont: UIFont = MyFont.thin(ofSize: fontSize)

    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        sharedInit()
    }

    private func sharedInit() {
        backgroundColor = .clear
        isUserInteractionEnabled = false
        delegate = self
        render()
    }

    func render() {
        chartDescription?.enabled = false
        webLineWidth = 0.5
        innerWebLineWidth = 0.5
        webColor = wColor
        innerWebColor = wColor
        webAlpha = 1

        xAxis.labelFont = labelFont
        xAxis.valueFormatter = self
        xAxis.labelTextColor = labelColor

        yAxis.labelFont = labelFont
        yAxis.labelCount = 3
        yAxis.axisMinimum = 0
        yAxis.axisMaximum = 500
        yAxis.drawLabelsEnabled = false

        legend.drawInside = true
        legend.form = .none

        animate(xAxisDuration: 0.5, yAxisDuration: 1.0, easingOption: .easeOutBack)

        let tagPoints = getTagPoints()
        let entries1 = abilities.map { tag -> RadarChartDataEntry in
            if let points = tagPoints["#\(tag)"],
                points > 10 {
                return RadarChartDataEntry(value: Double(points))
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

        data = RadarChartData(dataSets: [set1])
        data?.setDrawValues(false)
    }
}

extension AbilityChart: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return abilities[Int(value) % abilities.count]
    }
}

extension AbilityChart: ReloadableView {
    func viewWillAppear() {
        render()
    }
}
