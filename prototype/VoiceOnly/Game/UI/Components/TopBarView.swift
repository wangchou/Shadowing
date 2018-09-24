//
//  TopBarView.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 9/21/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit
import SwiftIconFont

@IBDesignable
class TopBarView: UIView, XibView {
    var contentView: UIView?
    var nibName: String = "TopBarView"

    @IBOutlet weak var bottomSeparator: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    var customOnleftButtonClicked: (() -> Void)?
    var customOnRightButtonClicked: (() -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        xibSetup()
        leftButton.setIconImage(named: "ic_settings_48pt")
        rightButton.setIconImage(named: "ic_keyboard_arrow_right_48pt")
        titleLabel.textColor = UIColor(white: 0, alpha: 0.66)
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        xibSetup()
        contentView?.prepareForInterfaceBuilder()
        leftButton.setIconImage(named: "ic_settings_48pt")
        rightButton.setIconImage(named: "ic_keyboard_arrow_right_48pt")
        titleLabel.textColor = UIColor(white: 0, alpha: 0.66)
    }

    @IBAction func leftButtonClicked(_ sender: Any) {
        if let onClick = customOnleftButtonClicked {
            onClick()
        } else {
            (UIApplication.getPresentedViewController() as? UIPageViewController)?.goToPreviousPage()
        }
    }

    @IBAction func rightButtonClicked(_ sender: Any) {
        if let onClick = customOnRightButtonClicked {
            onClick()
        } else {
         (UIApplication.getPresentedViewController() as? UIPageViewController)?.goToNextPage()
        }
    }
}

extension UIButton {
    func setIconImage(named: String, tintColor: UIColor = UIColor(white: 0, alpha: 0.66)) {
        let closeImage = UIImage(named: named)?.withRenderingMode(
            UIImage.RenderingMode.alwaysTemplate)
        self.tintColor = tintColor
        self.setImage(closeImage, for: .normal)
        self.imageView?.contentMode = .scaleAspectFit
        self.setTitle("", for: .normal)
    }
}