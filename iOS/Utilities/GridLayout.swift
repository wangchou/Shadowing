//
//  GridLayout.swift
//  今話したい
//
//  Created by Wangchou Lu on 12/23/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

class GridUIView: UIView, GridLayout {}

enum GridAxis {
    case horizontal
    case vertical
}

protocol GridLayout: class {
    var gridCount: Int { get }
    var axis: GridAxis { get }
}

extension GridLayout where Self: UIView {
    var gridCount: Int {
        return 48
    }

    var axis: GridAxis {
        return .horizontal
    }

    var step: CGFloat {
        return (axis == GridAxis.horizontal ? frame.width : frame.height) / gridCount.c
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
                 color: UIColor? = nil
        ) -> UILabel {
        let label = UILabel()
        label.font = font ?? MyFont.regular(ofSize: getFontSize(h: h))
        label.textColor = color ?? .black
        label.text = text
        layout(x, y, w, h, label)
        addSubview(label)
        return label
    }

    @discardableResult
    func addAttrText(x: Int,
                     y: Int,
                     w: Int? = nil,
                     h: Int,
                     text: NSAttributedString
        ) -> UILabel {
        let label = UILabel()
        label.attributedText = text
        layout(x, y, w, h, label)
        addSubview(label)
        return label
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

    func layout(_ x: Int, _ y: Int, _ w: Int? = nil, _ h: Int, _ view: UIView) {
        view.frame = getFrame(x, y, w ?? (gridCount - x), h)
    }

    func getFrame(_ x: Int, _ y: Int, _ w: Int, _ h: Int) -> CGRect {
        var x = x
        var y = y
        if axis == GridAxis.horizontal {
            x = (x + gridCount) % gridCount
        } else {
            y = (y + gridCount) % gridCount
        }

        return CGRect(
            x: x.c * step,
            y: y.c * step,
            width: w.c * step,
            height: h.c * step
        )
    }

    var bottomButtonHeight: CGFloat {
        return max(6 * step, getBottomPadding() + 4 * step)
    }
    var bottomButtonFont: UIFont {
        return MyFont.regular(ofSize: step * 3)
    }
}
