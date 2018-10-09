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
        sharedInit()
    }

    private func sharedInit() {
        backgroundColor = .clear
        //isUserInteractionEnabled = false
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

        setDataCount(20, range: 50)
        animate(xAxisDuration: 1.5)
    }

    func setDataCount(_ count: Int, range: UInt32) {
        let values = (0..<count).map { (i) -> ChartDataEntry in
            let val = Double(arc4random_uniform(range) + 3)
            return ChartDataEntry(x: Double(i * 10), y: val)
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

        let gradientColors = [ChartColorTemplates.colorFromString("#00ff0000").cgColor,
                              ChartColorTemplates.colorFromString("#ffff0000").cgColor]
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
