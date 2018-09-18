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

// from https://medium.com/@sdrzn/adding-gesture-recognizers-with-closures-instead-of-selectors-9fb3e09a8f0b
extension UIView {

    // In order to create computed properties for extensions, we need a key to
    // store and access the stored property
    fileprivate struct AssociatedObjectKeys {
        static var tapGestureRecognizer = "MediaViewerAssociatedObjectKey_mediaViewer"
    }

    fileprivate typealias Action = (() -> Void)?

    // Set our computed property type to a closure
    fileprivate var tapGestureRecognizerAction: Action? {
        set {
            if let newValue = newValue {
                // Computed properties get stored as associated objects
                objc_setAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
        }
        get {
            let tapGestureRecognizerActionInstance = objc_getAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer) as? Action
            return tapGestureRecognizerActionInstance
        }
    }

    // This is the meat of the sauce, here we create the tap gesture recognizer and
    // store the closure the user passed to us in the associated object we declared above
    public func addTapGestureRecognizer(action: (() -> Void)?) {
        self.isUserInteractionEnabled = true
        self.tapGestureRecognizerAction = action
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        self.addGestureRecognizer(tapGestureRecognizer)
    }

    // Every time the user taps on the UIImageView, this function gets called,
    // which triggers the closure we stored
    @objc fileprivate func handleTapGesture(sender: UITapGestureRecognizer) {
        if let action = self.tapGestureRecognizerAction {
            action?()
        } else {
            print("no action")
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
        return floor((axisBound - spacing)*2 / gridCount.c)/2
    }

    var stepFloat: CGFloat {
        return (axisBound - spacing)*2 / gridCount.c / 2
    }

    func addText(x: Int, y: Int, w: Int, h: Int, text: String, font: UIFont, color: UIColor, completion: ((UILabel) -> Void)? = nil) {
        let label = UILabel()
        label.font = font
        label.textColor = color
        label.text = text
        layout(x, y, w, h, label)
        self.addSubview(label)

        completion?(label)
    }

    func addAttrText(x: Int, y: Int, w: Int, h: Int, text: NSAttributedString, completion: ((UIView) -> Void)? = nil) {
        let label = UILabel()
        label.attributedText = text
        layout(x, y, w, h, label)
        self.addSubview(label)
        completion?(label)
    }

    func addRoundRect(x: Int, y: Int, w: Int, h: Int,
                      borderColor: UIColor, radius: CGFloat? = nil, backgroundColor: UIColor? = nil) {
        let roundRect = UIView()
        layout(x, y, w, h, roundRect)
        let radius = radius ?? h.c * step / 2
        roundRect.roundBorder(borderWidth: 1.5, cornerRadius: radius, color: borderColor)
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
        view.frame = getFrame(x, y, w, h)
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
            x: x.c * stepFloat,
            y: y.c * stepFloat,
            width: w.c * stepFloat,
            height: h.c * stepFloat
        )
    }
}
