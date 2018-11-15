//
//  UI.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/23.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit
import Promises

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
        layer.borderWidth = borderWidth
        layer.cornerRadius = cornerRadius
        layer.borderColor = color.cgColor
        clipsToBounds = true
    }

    func centerIn(_ boundRect: CGRect) {
        let xPadding = (boundRect.width - frame.width)/2
        let yPadding = (boundRect.height - frame.height)/2
        frame.origin.x = boundRect.origin.x + xPadding
        frame.origin.y = boundRect.origin.y + yPadding
    }

    func centerX(_ boundRect: CGRect, xShift: CGFloat = 0) {
        let xPadding = (boundRect.width - frame.width)/2
        frame.origin.x = boundRect.origin.x + xPadding + xShift
    }

    func removeAllSubviews() {
        subviews.forEach { $0.removeFromSuperview() }
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
        contentSize = CGSize(
            width: frame.size.width,
            height: max(frame.size.height, CGFloat(y))
        )
        scrollRectToVisible(CGRect(x: 5, y: y-1, width: 1, height: 1), animated: true)
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

    func addAttrText(x: Int,
                     y: Int,
                     w: Int? = nil,
                     h: Int,
                     text: NSAttributedString,
                     completion: ((UIView) -> Void)? = nil
        ) {
        let label = UILabel()
        label.attributedText = text
        layout(x, y, w ?? (gridCount - x), h, label)
        addSubview(label)
        completion?(label)
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

    func addRect(x: Int, y: Int, w: Int, h: Int,
                 color: UIColor = myBlue) -> UIView {
        let rect = UIView()
        layout(x, y, w, h, rect)
        rect.backgroundColor = color
        addSubview(rect)
        return rect
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

// modified from https://medium.com/zenchef-tech-and-product/how-to-visualize-reusable-xibs-in-storyboards-using-ibdesignable-c0488c7f525d

protocol XibView: class {
    var nibName: String { get }
    var contentView: UIView? { get set }
}

extension XibView where Self: UIView {
    func xibSetup() {
        guard let view = loadViewFromNib() else { return }
        view.frame = bounds
        view.autoresizingMask =
            [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        contentView = view
    }

    func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(
            withOwner: self,
            options: nil).first as? UIView
    }
}

// https://stackoverflow.com/questions/47572204/move-pageviewcontroller-with-button
extension UIPageViewController {
    func goToNextPage(animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
        if let currentViewController = viewControllers?[0] {
            if let nextPage = dataSource?.pageViewController(self, viewControllerAfter: currentViewController) {
                setViewControllers([nextPage], direction: .forward, animated: animated, completion: completion)
            }
        }
    }

    func goToPreviousPage(animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
        if let currentViewController = viewControllers?[0] {
            if let previousPage = dataSource?.pageViewController(self, viewControllerBefore: currentViewController) {
                setViewControllers([previousPage], direction: .reverse, animated: true, completion: completion)
            }
        }
    }
}

enum TMPError: Error {
    case alert
}
var isAlerting = fulfilledVoidPromise()
func showMessage(_ message: String, seconds: Float = 2) {
    isAlerting.then {
        isAlerting = Promise<Void>.pending()
        let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
        UIApplication.getPresentedViewController()?.present(alert, animated: true)

        let when = DispatchTime.now() + DispatchTimeInterval.milliseconds(Int(seconds*1000))
        DispatchQueue.main.asyncAfter(deadline: when) {
            alert.dismiss(animated: true) {
                isAlerting.reject(TMPError.alert) // discard all other show message
                isAlerting = fulfilledVoidPromise()
                print("alert dismissed")
            }
        }
    }
}

private var isShowingGoToSettingCenterAlert = false
func showGoToSettingCenterAlert() {
    guard !isShowingGoToSettingCenterAlert else { return }
    isShowingGoToSettingCenterAlert = true
    let i18n = I18n.shared
    let alertController = UIAlertController(title: i18n.gotoIOSCenterTitle, message: "", preferredStyle: .alert)

    // Create the actions
    let okAction = UIAlertAction(title: i18n.gotoIOSCenterOKTitle, style: UIAlertAction.Style.default) {
        UIAlertAction in
        isShowingGoToSettingCenterAlert = false
        alertController.dismiss(animated: true, completion: nil)
        goToIOSSettingCenter()
    }
    let cancelAction = UIAlertAction(title: i18n.gotoIOSCenterCancelTitle, style: UIAlertAction.Style.cancel) {
        UIAlertAction in
        isShowingGoToSettingCenterAlert = false
        alertController.dismiss(animated: true, completion: nil)
    }

    // Add the actions
    alertController.addAction(okAction)
    alertController.addAction(cancelAction)

    UIApplication.getPresentedViewController()?.present(alertController, animated: true)

}
func goToIOSSettingCenter() {
    if let url = URL(string: UIApplication.openSettingsURLString) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

//https://stackoverflow.com/questions/46317061/use-safe-area-layout-programmatically
extension UIView {

    var safeTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.topAnchor
        } else {
            return self.topAnchor
        }
    }

    var safeLeftAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *){
            return self.safeAreaLayoutGuide.leftAnchor
        }else {
            return self.leftAnchor
        }
    }

    var safeRightAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *){
            return self.safeAreaLayoutGuide.rightAnchor
        }else {
            return self.rightAnchor
        }
    }

    var safeBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.bottomAnchor
        } else {
            return self.bottomAnchor
        }
    }
}
