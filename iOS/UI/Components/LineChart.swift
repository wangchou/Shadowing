//
//  AbilityChart.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 10/1/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Charts
import UIKit

@IBDesignable
class LineChart: LineChartView, ChartViewDelegate, ReloadableView {
    var lineColor: UIColor = .black
    var circleColor: UIColor = .black
    var circleRadius: CGFloat = 2
    var lineWidth: CGFloat = 0.5
    var lineDashLengths: [CGFloat] = [5, 2.5]
    var highlightLineDashLengths: [CGFloat] = [5, 2.5]
    var leftAxisMinimum: Double = 0
    var leftAxisMaximum: Double = 100
    var isDrawFill: Bool = true
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
        dragEnabled = true
        setScaleEnabled(false)
        pinchZoomEnabled = false

        xAxis.gridLineDashLengths = [0.5, 2]
        xAxis.gridLineDashPhase = 10

        leftAxis.axisMaximum = leftAxisMaximum
        leftAxis.axisMinimum = leftAxisMinimum
        leftAxis.gridLineDashLengths = [0.5, 2]

        xAxis.labelPosition = .bottom

        rightAxis.enabled = false
        leftAxis.enabled = true

        legend.form = .none

        animate(xAxisDuration: 0.5)
    }

    func setDataCount(level: Level, dataPoints: [(x: Int, y: Int)]) {
        let values = dataPoints.map { p in
            ChartDataEntry(x: Double(p.x), y: Double(p.y))
        }

        let set1 = LineChartDataSet(values: values, label: "")
        set1.drawIconsEnabled = false

        set1.lineDashLengths = lineDashLengths
        set1.highlightLineDashLengths = highlightLineDashLengths
        set1.setColor(lineColor)
        set1.setCircleColor(circleColor)
        set1.lineWidth = lineWidth
        set1.circleRadius = circleRadius
        set1.drawValuesEnabled = false
        set1.drawCircleHoleEnabled = false

        let gradientColors = [level.color.withAlphaComponent(0.1).cgColor, level.color.cgColor]
        let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!

        set1.fillAlpha = 1
        set1.fill = Fill(linearGradient: gradient, angle: 90)
        set1.drawFilledEnabled = isDrawFill

        let data = LineChartData(dataSet: set1)

        self.data = data
    }
}
