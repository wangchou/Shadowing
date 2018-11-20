//
//  ReportView.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 6/7/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

private let context = GameContext.shared

@IBDesignable
class GameReportView: UIView, ReloadableView, GridLayout {
    let gridCount = 48
    let axis: GridAxis = .horizontal
    let spacing: CGFloat = 0

    func viewWillAppear() {
        removeAllSubviews()
        backgroundColor = UIColor.black.withAlphaComponent(0.6)
        let reportBox = GameReportBoxView()

        if context.isNewRecord && context.contentTab == .topics {
            frame = CGRect(x: 0, y: 0, width: screen.width, height: screen.width * 1.73)
            layout(2, 4, 44, 67, reportBox)
        } else {
            frame = CGRect(x: 0, y: 0, width: screen.width, height: screen.width * 1.06)
            layout(2, 4, 44, 35, reportBox)
        }
        addReloadableSubview(reportBox)
        addBackButton()
    }

    func addBackButton() {
        let backButton = UIButton()
        backButton.setTitle("戻   る", for: .normal)
        backButton.backgroundColor = .red
        backButton.titleLabel?.font = MyFont.regular(ofSize: step * 4)
        backButton.titleLabel?.textColor = myLightText
        backButton.roundBorder(borderWidth: 1, cornerRadius: 5, color: .clear)

        backButton.addTapGestureRecognizer {
            if let vc = UIApplication.getPresentedViewController() {
                if context.contentTab == .infiniteChallenge {

                    vc.dismiss(animated: false) {
                        UIApplication.getPresentedViewController()?.dismiss(animated: true, completion: nil)
                    }

                    if let icwPage = rootViewController.current as? InfiniteChallengeSwipablePage {
                        (icwPage.pages[2] as? InfiniteChallengePage)?.tableView.reloadData()
                    }
                } else {
                    vc.dismiss(animated: false) {
                        UIApplication.getPresentedViewController()?.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
        if context.isNewRecord && context.contentTab == .topics {
            layout(2, 73, 44, 8, backButton)
        } else {
            layout(2, 41, 44, 8, backButton)
        }

        addSubview(backButton)
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        viewWillAppear()
    }
}
