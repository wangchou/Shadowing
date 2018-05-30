//
//  UI.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/23.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func roundBorder(borderWidth: CGFloat = 1.5, cornerRadius: CGFloat = 15, color: UIColor = .black) {
        self.layer.borderWidth = borderWidth
        self.layer.cornerRadius = cornerRadius
        self.layer.borderColor = color.cgColor
        self.clipsToBounds = true
    }

    func centerIn(_ boundRect: CGRect) {
        let xPadding = (boundRect.width - self.frame.width)/2
        let yPadding = (boundRect.height - self.frame.height)/2
        self.frame.origin.x = boundRect.origin.x + xPadding
        self.frame.origin.y = boundRect.origin.y + yPadding
    }

    func removeAllSubviews() {
        self.subviews.forEach { $0.removeFromSuperview() }
    }
}

extension UIScrollView {
    func scrollTo(_ y: Int) {
        self.contentSize = CGSize(
            width: self.frame.size.width,
            height: max(self.frame.size.height, CGFloat(y))
        )
        self.scrollRectToVisible(CGRect(x: 5, y: y-1, width: 1, height: 1), animated: true)
    }
}

extension UIApplication {
    class func getPresentedViewController() -> UIViewController? {
        var presentViewController = UIApplication.shared.keyWindow?.rootViewController
        while let pVC = presentViewController?.presentedViewController {
            presentViewController = pVC
        }

        return presentViewController
    }
}

enum GridAxis {
    case horizontal
    case vertical
}

let emptyCGRect = CGRect(x: 0, y: 0, width: 5, height: 5)

struct GridSystem {
    var axis: GridAxis
    var gridCount: Int
    var bounds: CGRect
    var step: CGFloat {
        let axisBound = axis == GridAxis.horizontal ? bounds.width : bounds.height
        return axisBound / gridCount.c
    }

    init(axis: GridAxis = .horizontal, gridCount: Int = 1, bounds: CGRect? = nil) {
        self.axis = axis
        self.gridCount = gridCount
        self.bounds = bounds ?? emptyCGRect
    }

    func frame(_ view: UIView, x: Int, y: Int, w: Int, h: Int) {
        var x = x
        var y = y
        if axis == GridAxis.horizontal {
            x = (x + gridCount) % gridCount
        } else {
            y = (y + gridCount) % gridCount
        }

        view.frame = CGRect(
            x: x.c * step,
            y: y.c * step,
            width: w.c * step,
            height: h.c * step
        )
    }
}
