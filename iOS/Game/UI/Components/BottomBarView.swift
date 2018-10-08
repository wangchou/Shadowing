//
//  BottomBar.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 10/8/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation

import Foundation
import UIKit
import SwiftIconFont

private let context = GameContext.shared

@IBDesignable
class BottomBarView: UIView, XibView {
    var contentView: UIView?
    var nibName: String = "BottomBarView"
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        xibSetup()
        sharedSetup()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        xibSetup()
        contentView?.prepareForInterfaceBuilder()
        sharedSetup()
    }

    func sharedSetup() {
        var leftColor: UIColor = UIColor(white: 0, alpha: 0.66)
        var rightColor: UIColor = UIColor(white: 0, alpha: 0.66)
        switch context.contentTab {
        case .topics:
            leftColor = tintColor
        case .infiniteChallenge:
            rightColor = tintColor
        }
        leftButton.setIconImage(named: "round_list_black_48pt", tintColor: leftColor)
        rightButton.setIconImage(named: "round_all_inclusive_black_48pt", tintColor: rightColor)
        backgroundColor = rgb(250, 250, 250)
    }
    @IBAction func onLeftButtonClicked(_ sender: Any) {
        context.contentTab = .topics
        sharedSetup()
        guard let vc = UIApplication.getPresentedViewController() else { return }
        launchStoryboard(vc, "MainSwipablePage")
    }
    @IBAction func onRightButtonClicked(_ sender: Any) {
        context.contentTab = .infiniteChallenge
        sharedSetup()
        guard let vc = UIApplication.getPresentedViewController() else { return }
        launchStoryboard(vc, "InfiniteChallengeSwipablePage")
    }
}
