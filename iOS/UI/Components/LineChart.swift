//
//  AbilityChart.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 10/1/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import UIKit
import Charts

private let fontSize = screen.width * 12 / 320

@IBDesignable
class LineChart: LineChartView, ChartViewDelegate {

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

        leftAxis.axisMaximum = 100
        leftAxis.axisMinimum = 0
        leftAxis.gridLineDashLengths = [0.5, 2]

        xAxis.labelPosition = .bottom

        rightAxis.enabled = false
        leftAxis.enabled = true

        legend.form = .none

        animate(xAxisDuration: 0.8)
    }

    func setDataCount(level: Level, dataPoints: [(x: Int, y: Int)]) {
        let values = dataPoints.map { p in
            return ChartDataEntry(x: Double(p.x), y: Double(p.y))
        }

        let set1 = LineChartDataSet(values: values, label: "")
        set1.drawIconsEnabled = false

        set1.lineDashLengths = [5, 2.5]
        set1.highlightLineDashLengths = [5, 2.5]
        set1.setColor(.black)
        set1.setCircleColor(.black)
        set1.lineWidth = 0.5
        set1.circleRadius = 2
        set1.drawValuesEnabled = false
        set1.drawCircleHoleEnabled = false

        let gradientColors = [level.color.withAlphaComponent(0.1).cgColor, level.color.cgColor]
        let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!

        set1.fillAlpha = 1
        set1.fill = Fill(linearGradient: gradient, angle: 90)
        set1.drawFilledEnabled = true

        let data = LineChartData(dataSet: set1)

        self.data = data
    }
}

extension LineChart: ReloadableView {
    func viewWillAppear() {
        render()
    }
}
