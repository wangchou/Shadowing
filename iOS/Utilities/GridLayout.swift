//
//  GridLayout.swift
//  今話したい
//
//  Created by Wangchou Lu on 12/23/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

enum GridAxis {
    case horizontal
    case vertical
}

protocol GridLayout: class {
    var gridCount: Int { get }
    var axis: GridAxis { get }
    var spacing: CGFloat { get }
}

extension GridLayout where Self: UIView {
    var axisBound: CGFloat {
        return axis == GridAxis.horizontal ? frame.width : frame.height
    }

    var anotherAxisGridCount: CGFloat {
        return (axis == GridAxis.horizontal ? frame.height : frame.width) /
            (axisBound / gridCount.c)
    }

    var fontSize: CGFloat {
        return step - spacing
    }

    var step: CGFloat { // is multiple of retina pixel width 0.5, ex 18, 19.5...
        return floor((axisBound - spacing) * 2 / gridCount.c)/2
    }

    var stepFloat: CGFloat {
        return (axisBound - spacing) * 2 / gridCount.c / 2
    }

    func getFontSize(h: Int) -> CGFloat {
        return h.c * step * 0.7
    }

    @discardableResult
    func addText(x: Int,
                 y: Int,
                 w: Int? = nil,
                 h: Int,
                 text: String,
                 font: UIFont? = nil,
                 color: UIColor? = nil,
                 completion: ((UILabel) -> Void)? = nil
        ) -> UILabel {
        let label = UILabel()
        label.font = font ?? MyFont.regular(ofSize: getFontSize(h: h))
        label.textColor = color ?? .black
        label.text = text
        layout(x, y, w ?? (gridCount - x), h, label)
        addSubview(label)

        completion?(label)
        return label
    }

    @discardableResult
    func addAttrText(x: Int,
                     y: Int,
                     w: Int? = nil,
                     h: Int,
                     text: NSAttributedString,
                     completion: ((UIView) -> Void)? = nil
        ) -> UILabel {
        let label = UILabel()
        label.attributedText = text
        layout(x, y, w ?? (gridCount - x), h, label)
        addSubview(label)
        completion?(label)
        return label
    }

    func addRoundRect(x: Int, y: Int, w: Int, h: Int,
                      borderColor: UIColor,
                      radius: CGFloat? = nil,
                      backgroundColor: UIColor? = nil
        ) {
        let roundRect = UIView()
        layout(x, y, w, h, roundRect)
        let radius = radius ?? h.c * step / 2
        roundRect.roundBorder(borderWidth: 1.5, cornerRadius: radius, color: borderColor)
        if let backgroundColor = backgroundColor {
            roundRect.backgroundColor = backgroundColor
        }
        addSubview(roundRect)
    }

    @discardableResult
    func addRect(x: Int, y: Int, w: Int, h: Int,
                 color: UIColor = myBlue) -> UIView {
        let rect = UIView()
        layout(x, y, w, h, rect)
        rect.backgroundColor = color
        addSubview(rect)
        return rect
    }

    func layout(anchor: CGPoint = CGPoint(x: 0, y: 0), _ x: Int, _ y: Int, _ w: Int, _ h: Int, _ view: UIView) {
        view.frame = getFrame(anchor: anchor, x, y, w, h)
    }

    func getFrame(anchor: CGPoint = CGPoint(x: 0, y: 0), _ x: Int, _ y: Int, _ w: Int, _ h: Int) -> CGRect {
        var x = x
        var y = y
        if axis == GridAxis.horizontal {
            x = (x + gridCount) % gridCount
        } else {
            y = (y + gridCount) % gridCount
        }

        return CGRect(
            x: anchor.x + x.c * stepFloat,
            y: anchor.y + y.c * stepFloat,
            width: w.c * stepFloat,
            height: h.c * stepFloat
        )
    }
}
