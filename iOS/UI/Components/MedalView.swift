//
//  MedalView.swift
//  今話したい
//
//  Created by Wangchou Lu on 4/5/31 H.
//  Copyright © 31 Heisei Lu, WangChou. All rights reserved.
//

// https://www.raywenderlich.com/409-core-graphics-tutorial-part-3-patterns-and-playgrounds
// https://stackoverflow.com/questions/37038055/angled-gradient-layer

import UIKit

class MedalView: UIView, ReloadableView {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func viewWillAppear() {
        backgroundColor = .clear

        layer.sublayers?.forEach { $0.removeFromSuperlayer() }

        let brassLight = rgb(196, 177, 71)
        let brassDark = rgb(148, 97, 33)
        let goldLight = rgb(255, 223, 55)
        let goldDark = rgb(179, 111, 29)
        let w = bounds.width

        drawGradientCircle(rect: bounds, padding: 0, startColor: brassLight, endColor: brassDark)
        drawGradientCircle(rect: bounds, padding: w * 0.015, startColor: goldLight, endColor: goldDark)
        drawGradientCircle(rect: bounds, padding: w * 0.055, startColor: goldDark, endColor: goldLight)
        drawGradientCircle(rect: bounds, padding: w * 0.065, startColor: goldLight, endColor: goldDark)

        drawStar()
    }

    private func drawStar() {

        let goldMiddle = rgb(198, 139, 33)
        let gradientLayer = CAGradientLayer()
        gradientLayer.startPoint = CGPoint(x: 1, y: 0.2)
        gradientLayer.endPoint = CGPoint(x: 0.2, y: 1)
        gradientLayer.frame = bounds
        gradientLayer.colors = [
            goldMiddle.cgColor, UIColor.black.cgColor
        ]

        let path = UIBezierPath()
        let r = bounds.width * 0.30
        let o = CGPoint(x: bounds.width/2, y: bounds.width/2)

        func getP(_ idx: CGFloat) -> CGPoint {
            return CGPoint(x: o.x + r * sin(.pi * idx * 0.4), y: o.y - r * cos(.pi * idx * 0.4))
        }

        path.move(to: getP(0))
        path.addLine(to: getP(3))
        path.addLine(to: getP(1))
        path.addLine(to: getP(4))
        path.addLine(to: getP(2))
        path.close()

        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.fillColor = UIColor.white.cgColor
        shapeLayer.lineWidth = bounds.width/30
        shapeLayer.lineCap = .round
        shapeLayer.lineJoin = .round
        shapeLayer.path = path.cgPath
        gradientLayer.mask = shapeLayer
        layer.addSublayer(gradientLayer)
    }

    private func drawGradientCircle(rect: CGRect, padding: CGFloat = 0, startColor: UIColor, endColor: UIColor) {

        let gradientLayer = CAGradientLayer()
        gradientLayer.startPoint = CGPoint(x: 1, y: 0.2)
        gradientLayer.endPoint = CGPoint(x: 0.2, y: 1)
        gradientLayer.frame = rect
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]

        var pathRect = rect
        pathRect.origin.x += padding
        pathRect.origin.y += padding
        pathRect.size.width -= padding * 2
        pathRect.size.height -= padding * 2
        let path = UIBezierPath(ovalIn: pathRect)

        let shapeMask = CAShapeLayer()
        shapeMask.path = path.cgPath
        gradientLayer.mask = shapeMask
        layer.addSublayer(gradientLayer)
    }
}
