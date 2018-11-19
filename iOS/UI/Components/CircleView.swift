//
//  CircleView.swift
//  今話したい
//
//  Created by Wangchou Lu on 11/19/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

// updated from https://stackoverflow.com/questions/26578023/animate-drawing-of-a-circle
import UIKit

class CircleView: UIView {
    var circleLayer: CAShapeLayer!
    var color: UIColor = .black {
        willSet {
            circleLayer.strokeColor = newValue.cgColor
        }
    }
    var lineWidth: CGFloat = 0.75 {
        willSet {
            circleLayer.lineWidth = newValue
        }
    }
    var percent: CGFloat = 0.75

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear

        // Use UIBezierPath as an easy way to create the CGPath for the layer.
        // The path should be the entire circle.
        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x: frame.width / 2.0, y: frame.height / 2.0),
            radius: (frame.width - 10)/2,
            startAngle: CGFloat(.pi * -0.5),
            endAngle: CGFloat(.pi * 1.5),
            clockwise: true)

        // Setup the CAShapeLayer with the path, colors, and line width
        circleLayer = CAShapeLayer()
        circleLayer.path = circlePath.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = color.cgColor
        circleLayer.lineWidth = lineWidth

        // Don't draw the circle initially
        circleLayer.strokeEnd = 1.0

        // Add the circleLayer to the view's layer's sublayers
        layer.addSublayer(circleLayer)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func animateCircle(duration: TimeInterval) {
        // We want to animate the strokeEnd property of the circleLayer
        let animation = CABasicAnimation(keyPath: "strokeEnd")

        // Set the animation duration appropriately
        animation.duration = duration

        // Animate from 0 (no circle) to 1 (full circle)
        animation.fromValue = 0
        animation.toValue = percent

        // Do a linear animation (i.e. the speed of the animation stays the same)
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)

        // Set the circleLayer's strokeEnd property to 1.0 now so that it's the
        // right value when the animation ends.
        circleLayer.strokeEnd = percent

        // Do the actual animation
        circleLayer.add(animation, forKey: "animateCircle")
    }
}
