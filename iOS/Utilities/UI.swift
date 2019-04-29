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

    var x0: CGFloat {
        return frame.x
    }
    var x1: CGFloat {
        return frame.x + frame.width
    }
    var y0: CGFloat {
        return frame.y
    }
    var y1: CGFloat {
        return frame.y + frame.height
    }

    func roundBorder(borderWidth: CGFloat = 1.5, cornerRadius: CGFloat = 15, color: UIColor = .black) {
        layer.borderWidth = borderWidth
        layer.cornerRadius = cornerRadius
        layer.borderColor = color.cgColor
        clipsToBounds = true
    }

    func centerIn(_ boundRect: CGRect) {
        let xPadding = (boundRect.width - frame.width)/2
        let yPadding = (boundRect.height - frame.height)/2
        frame.origin.x = boundRect.x + xPadding
        frame.origin.y = boundRect.y + yPadding
    }

    func centerX(_ boundRect: CGRect, xShift: CGFloat = 0) {
        let xPadding = (boundRect.width - frame.width)/2
        frame.origin.x = boundRect.x + xPadding + xShift
    }

    func centerY(_ boundRect: CGRect, yShift: CGFloat = 0) {
        let yPadding = (boundRect.height - frame.height)/2
        frame.origin.y = boundRect.y + yPadding + yShift
    }

    func moveToBottom(_ boundRect: CGRect, yShift: CGFloat = 0) {
        frame.origin.y = boundRect.y + boundRect.height - frame.height + yShift
    }

    func moveToRight(_ boundRect: CGRect, xShift: CGFloat = 0) {
        frame.origin.x = boundRect.x + boundRect.width - frame.size.width + xShift
    }
    func moveToLeft(_ boundRect: CGRect, xShift: CGFloat = 0) {
        frame.origin.x = boundRect.x + xShift
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

    // MARK: Add onClick event
    // from https://medium.com/@sdrzn/adding-gesture-recognizers-with-closures-instead-of-selectors-9fb3e09a8f0b

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
        if let button = self as? UIButton {
            button.addTarget(self, action: #selector(handleTapGesture), for: .touchUpInside)
        } else {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
            self.addGestureRecognizer(tapGestureRecognizer)
        }
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

    // https://stackoverflow.com/questions/30696307/how-to-convert-a-uiview-to-an-image
    // Using a function since `var image` might conflict with an existing variable
    // (like on `UIImageView`)
    func asImage() -> UIImage {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image { rendererContext in
                layer.render(in: rendererContext.cgContext)
            }
        } else {
            UIGraphicsBeginImageContext(self.frame.size)
            self.layer.render(in: UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return UIImage(cgImage: image!.cgImage!)
        }
    }
}

extension CGRect {
    func padding(_ pad: CGFloat) -> CGRect {
        return CGRect(x: x + pad,
                      y: y + pad,
                      width: width - 2 * pad,
                      height: height - 2 * pad)
    }

    var y: CGFloat {
        return origin.y
    }

    var x: CGFloat {
        return origin.x
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

enum ButtonStyle {
    case darkOption
}

extension UIButton {
    func setStyle(style: ButtonStyle, step: CGFloat) {
        switch style {
        case .darkOption:
            self.roundBorder(borderWidth: 0.5, cornerRadius: step, color: .clear)
            self.tintColor = buttonForegroundGray
            self.setTitleColor(buttonForegroundGray, for: .normal)
            self.backgroundColor = buttonBackgroundGray
            self.showsTouchWhenHighlighted = true
            self.titleLabel?.textAlignment = .center
        }
    }
}

// dismiss presented vc
func dismissVC(animated: Bool = true, completion: (() -> Void)? = nil) {
    guard let vc = UIApplication.getPresentedViewController() else { return }
    vc.dismiss(animated: animated) {
        completion?()
    }
}

// dismiss two layer of presented vc
func dismissTwoVC(animated: Bool = true, completion: (() -> Void)? = nil) {
    dismissVC(animated: false) {
        dismissVC(animated: animated) {
            completion?()
        }
    }
}

// MARK: XibView
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

// MARK: Alerts
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

private var isShowingGoToPermissionSettingAlert = false

func showGoToPermissionSettingAlert() {
    guard !isShowingGoToPermissionSettingAlert else { return }
    isShowingGoToPermissionSettingAlert = true
    let i18n = I18n.shared
    let alertController = UIAlertController(title: i18n.gotoIOSCenterTitle, message: "", preferredStyle: .alert)

    // Create the actions
    let okAction = UIAlertAction(title: i18n.gotoIOSCenterOKTitle, style: .default) { _ in
        isShowingGoToPermissionSettingAlert = false
        alertController.dismiss(animated: true, completion: nil)
        goToIOSSettingCenter()
    }
    let cancelAction = UIAlertAction(title: i18n.gotoIOSCenterCancelTitle, style: .cancel) { _ in
        isShowingGoToPermissionSettingAlert = false
        alertController.dismiss(animated: true, completion: nil)
    }

    // Add the actions
    alertController.addAction(okAction)
    alertController.addAction(cancelAction)

    UIApplication.getPresentedViewController()?.present(alertController, animated: true)
}

func showOkAlert(title: String?, message: String? = nil, okTitle: String = I18n.shared.iGotIt) {
    let alert = UIAlertController(
        title: title,
        message: message,
        preferredStyle: .alert)
    let okAction = UIAlertAction(title: okTitle, style: .default) { _ in
        alert.dismiss(animated: true, completion: nil)
    }
    alert.addAction(okAction)
    UIApplication.getPresentedViewController()?.present(alert, animated: true)
}

func showProcessingAlert() -> UIAlertController {
    let alert = UIAlertController(
        title: I18n.shared.processing,
        message: "",
        preferredStyle: .alert)
    UIApplication.getPresentedViewController()?.present(alert, animated: true)
    return alert
}

// MARK: - launch storyboard
func getVC(_ name: String) -> UIViewController {
    switch name {
    case MedalGameFinishedPage.id:
        return MedalGameFinishedPage()
    case MedalPage.id:
        return MedalPage()
    case MedalSummaryPage.id:
        return MedalSummaryPage()
    case MedalCorrectionPage.id:
        return MedalCorrectionPage()
    default:
        return UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: name)
    }
}

func launchVC(
    _ vcName: String,
    _ originVC: UIViewController? = nil,
    isOverCurrent: Bool = false,
    animated: Bool = false,
    completion: ((UIViewController) -> Void)? = nil
    ) {
    let vc = getVC(vcName)
    if isOverCurrent {
        vc.modalPresentationStyle = .overCurrentContext
    } else {
        vc.modalTransitionStyle = .crossDissolve
    }

    (originVC ?? UIApplication.getPresentedViewController())?
        .present(vc, animated: animated) {
        completion?(vc)
    }
}

func goToIOSSettingCenter() {
    if let url = URL(string: UIApplication.openSettingsURLString) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
