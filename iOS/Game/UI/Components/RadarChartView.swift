//
//  RadarChartView.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 9/30/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit
import Charts

class RadarChartViewController: UIViewController, ChartViewDelegate {

    var chartView: RadarChartView {
        return self.view as! RadarChartView
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Radar Chart"

        chartView.delegate = self

        chartView.chartDescription?.enabled = false
        chartView.webLineWidth = 1
        chartView.innerWebLineWidth = 1
        chartView.webColor = .lightGray
        chartView.innerWebColor = .lightGray
        chartView.webAlpha = 1

//        let marker = RadarMarkerView.viewFromXib()!
//        marker.chartView = chartView
//        chartView.marker = marker

        let xAxis = chartView.xAxis
        xAxis.labelFont = .systemFont(ofSize: 9, weight: .light)
        xAxis.xOffset = 0
        xAxis.yOffset = 0
        xAxis.valueFormatter = self
        xAxis.labelTextColor = .white

        let yAxis = chartView.yAxis
        yAxis.labelFont = .systemFont(ofSize: 9, weight: .light)
        yAxis.labelCount = 5
        yAxis.axisMinimum = 0
        yAxis.axisMaximum = 80
        yAxis.drawLabelsEnabled = false

        let l = chartView.legend
        l.horizontalAlignment = .center
        l.verticalAlignment = .top
        l.orientation = .horizontal
        l.drawInside = false
        l.font = .systemFont(ofSize: 10, weight: .light)
        l.xEntrySpace = 7
        l.yEntrySpace = 5
        l.textColor = .white
        setChartData()

        chartView.animate(xAxisDuration: 1.4, yAxisDuration: 1.4, easingOption: .easeOutBack)
    }

    func setChartData() {
        chartView.delegate = self

        chartView.chartDescription?.enabled = false
        chartView.webLineWidth = 1
        chartView.innerWebLineWidth = 1
        chartView.webColor = .lightGray
        chartView.innerWebColor = .lightGray
        chartView.webAlpha = 1

        //        let marker = RadarMarkerView.viewFromXib()!
        //        marker.chartView = chartView
        //        chartView.marker = marker

        let xAxis = chartView.xAxis
        xAxis.labelFont = .systemFont(ofSize: 9, weight: .light)
        xAxis.xOffset = 0
        xAxis.yOffset = 0
        xAxis.valueFormatter = self
        xAxis.labelTextColor = .white

        let yAxis = chartView.yAxis
        yAxis.labelFont = .systemFont(ofSize: 9, weight: .light)
        yAxis.labelCount = 5
        yAxis.axisMinimum = 0
        yAxis.axisMaximum = 80
        yAxis.drawLabelsEnabled = false

        let l = chartView.legend
        l.horizontalAlignment = .center
        l.verticalAlignment = .top
        l.orientation = .horizontal
        l.drawInside = false
        l.font = .systemFont(ofSize: 10, weight: .light)
        l.xEntrySpace = 7
        l.yEntrySpace = 5
        l.textColor = .white

        chartView.animate(xAxisDuration: 1.4, yAxisDuration: 1.4, easingOption: .easeOutBack)
        let mult: UInt32 = 80
        let min: UInt32 = 20
        let cnt = 5

        let block: (Int) -> RadarChartDataEntry = { _ in return RadarChartDataEntry(value: Double(arc4random_uniform(mult) + min))}
        let entries1 = (0..<cnt).map(block)
        let entries2 = (0..<cnt).map(block)

        let set1 = RadarChartDataSet(values: entries1, label: "Last Week")
        set1.setColor(UIColor(red: 103/255, green: 110/255, blue: 129/255, alpha: 1))
        set1.fillColor = UIColor(red: 103/255, green: 110/255, blue: 129/255, alpha: 1)
        set1.drawFilledEnabled = true
        set1.fillAlpha = 0.7
        set1.lineWidth = 2
        set1.drawHighlightCircleEnabled = true
        set1.setDrawHighlightIndicators(false)

        let set2 = RadarChartDataSet(values: entries2, label: "This Week")
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

        chartView.data = data
    }
}

extension RadarChartViewController: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let activities = ["Burger", "Steak", "Salad", "Pasta", "Pizza"]
        return activities[Int(value) % activities.count]
    }
}
