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

        drawGradientCircle(rect: bounds, padding: 0, startColor: brassLight, endColor: brassDark)
        drawGradientCircle(rect: bounds, padding: 3, startColor: goldLight, endColor: goldDark)
        drawGradientCircle(rect: bounds, padding: 10, startColor: goldDark, endColor: goldLight)
        drawGradientCircle(rect: bounds, padding: 13, startColor: goldLight, endColor: goldDark)

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
