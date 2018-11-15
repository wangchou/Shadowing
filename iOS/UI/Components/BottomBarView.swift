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

private let context = GameContext.shared

@IBDesignable
class BottomBarView: UIView, XibView {
    var contentView: UIView?
    var contentTab: ContentTab = .topics {
        didSet {
            updateContentTab()
        }
    }
    var nibName: String = "BottomBarView"
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        sharedSetup()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        contentView?.prepareForInterfaceBuilder()
        sharedSetup()
    }

    func sharedSetup() {
        xibSetup()
        contentView?.backgroundColor = rgb(250, 250, 250)
        updateContentTab()
        backgroundColor = rgb(250, 250, 250)
    }
    private func updateContentTab() {
        var leftColor: UIColor = UIColor(white: 0, alpha: 0.66)
        var rightColor: UIColor = UIColor(white: 0, alpha: 0.66)
        var leftImgName: String = "outline_featured_play_list_black_48pt"
        switch contentTab {
        case .topics:
            leftColor = tintColor
            leftImgName = "baseline_featured_play_list_black_48pt"
        case .infiniteChallenge:
            rightColor = tintColor
        }
        leftButton.setIconImage(named: leftImgName, tintColor: leftColor)
        rightButton.setIconImage(named: "outline_timeline_black_48pt", tintColor: rightColor)
    }
    @IBAction func onLeftButtonClicked(_ sender: Any) {
        context.contentTab = .topics
        rootViewController.showMainPage()
    }
    @IBAction func onRightButtonClicked(_ sender: Any) {
        context.contentTab = .infiniteChallenge
        rootViewController.showInfiniteChallengePage()
    }
}
