//
//  UI.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/23.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

// https://medium.com/@robnorback/the-secret-to-1-second-compile-times-in-xcode-9de4ec8345a1

protocol ReloadableView {
    func viewWillAppear()
}

extension UIView {

    #if DEBUG
    @objc func injected() {
        (self as? ReloadableView)?.viewWillAppear()
    }
    #endif

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

    func addReloadableSubview(_ view: UIView) {
        addSubview(view)
        if let view = view as? ReloadableView {
            view.viewWillAppear()
        }
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

protocol GridLayout: class {
    var gridCount: Int { get }
    var axis: GridAxis { get }
}

extension GridLayout where Self: UIView {
    var axisBound: CGFloat {
        return axis == GridAxis.horizontal ? frame.width : frame.height
    }

    var step: CGFloat {
        return axisBound / gridCount.c
    }

    func addText(x: Int, y: Int, w: Int, h: Int, text: String, font: UIFont, color: UIColor) {
        let label = UILabel()
        label.font = font
        label.textColor = color
        label.text = text
        layout(x, y, w, h, label)
        self.addSubview(label)
    }

    func addAttrText(x: Int, y: Int, w: Int, h: Int, text: NSAttributedString) {
        let label = UILabel()
        label.attributedText = text
        layout(x, y, w, h, label)
        self.addSubview(label)
    }

    func addRoundRect(x: Int, y: Int, w: Int, h: Int,
                      borderColor: UIColor, radius: CGFloat? = nil, backgroundColor: UIColor? = nil) {
        let roundRect = UIView()
        layout(x, y, w, h, roundRect)
        let radius = radius ?? h.c * step / 2
        roundRect.roundBorder(borderWidth: 3, cornerRadius: radius, color: borderColor)
        if let backgroundColor = backgroundColor {
            roundRect.backgroundColor = backgroundColor
        }
        self.addSubview(roundRect)
    }

    func addRect(x: Int, y: Int, w: Int, h: Int,
                 color: UIColor = myBlue) {
        let rect = UIView()
        layout(x, y, w, h, rect)
        rect.backgroundColor = color
        self.addSubview(rect)
    }

    func layout(_ x: Int, _ y: Int, _ w: Int, _ h: Int, _ view: UIView) {
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

struct GridSystem {
    var view: UIView?
    var axis: GridAxis
    var gridCount: Int
    var axisBound: CGFloat
    var step: CGFloat {
        return axisBound / gridCount.c
    }

    init(gridCount: Int, axis: GridAxis = .horizontal, axisBound: CGFloat = screen.width, view: UIView? = nil) {
        self.axis = axis
        self.gridCount = gridCount
        self.axisBound = axisBound
        self.view = view
    }

    func addText(x: Int, y: Int, w: Int, h: Int, text: String, font: UIFont, color: UIColor) {
        guard let view = self.view else { print("no view to addText in grid system"); return }
        let label = UILabel()
        label.font = font
        label.textColor = color
        label.text = text
        frame(x, y, w, h, label)
        view.addSubview(label)
    }

    func addAttrText(x: Int, y: Int, w: Int, h: Int, text: NSAttributedString) {
        guard let view = self.view else { print("no view to addText in grid system"); return }
        let label = UILabel()
        label.attributedText = text
        frame(x, y, w, h, label)
        view.addSubview(label)
    }

    func addRoundRect(x: Int, y: Int, w: Int, h: Int,
                      borderColor: UIColor, radius: CGFloat? = nil, backgroundColor: UIColor? = nil) {
        guard let view = self.view else { print("no view to addRoundRect in grid system"); return }
        let roundRect = UIView()
        frame(x, y, w, h, roundRect)
        let radius = radius ?? h.c * step / 2
        roundRect.roundBorder(borderWidth: 3, cornerRadius: radius, color: borderColor)
        if let backgroundColor = backgroundColor {
            roundRect.backgroundColor = backgroundColor
        }
        view.addSubview(roundRect)
    }

    func addRect(x: Int, y: Int, w: Int, h: Int,
                 color: UIColor = myBlue) {
        guard let view = self.view else { print("no view to addRect in grid system"); return }
        let rect = UIView()
        frame(x, y, w, h, rect)
        rect.backgroundColor = color
        view.addSubview(rect)
    }

    func frame(_ x: Int, _ y: Int, _ w: Int, _ h: Int, _ view: UIView) {
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
