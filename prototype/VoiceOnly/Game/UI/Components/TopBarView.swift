//
//  TopBarView.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 9/21/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

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
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        xibSetup()
        contentView?.prepareForInterfaceBuilder()
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
