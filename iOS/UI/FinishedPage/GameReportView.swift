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

var countDownTimer: Timer?
var nextGameButton: UIButton?

func stopCountDown() {
    countDownTimer?.invalidate()
    nextGameButton?.setTitle("次の挑戦", for: .normal)
    nextGameButton = nil
}

@IBDesignable
class GameReportView: UIView, ReloadableView, GridLayout {
    let gridCount = 48
    let axis: GridAxis = .horizontal
    let spacing: CGFloat = 0
    var reportBox: GameReportBoxView?

    func viewWillAppear() {
        removeAllSubviews()
        backgroundColor = UIColor.black.withAlphaComponent(0.6)
        reportBox = GameReportBoxView()

        if context.contentTab == .topics {
            frame = CGRect(x: 0, y: 0, width: screen.width, height: screen.width * 1.58)
            layout(2, 4, 44, 50, reportBox!)
        } else {
            frame = CGRect(x: 0, y: 0, width: screen.width, height: screen.width * 1.37)
            layout(2, 4, 44, 40, reportBox!)
        }

        addReloadableSubview(reportBox!)
        nextGameButton = addNextGameButton()
        addBackButton()
    }

    func viewDidAppear() {
        reportBox?.animateProgressBar()
    }

    func viewDidDisappear() {
        countDownTimer?.invalidate()
        nextGameButton = nil
    }

    func createButton(title: String, bgColor: UIColor) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.6), for: .highlighted)
        button.backgroundColor = bgColor
        button.titleLabel?.font = MyFont.regular(ofSize: step * 4)
        button.titleLabel?.textColor = myLightGray
        button.roundBorder(borderWidth: 1, cornerRadius: 5, color: .clear)
        return button
    }

    func addNextGameButton() -> UIButton {
        let nextGameButton = createButton(title: "次の挑戦 ( 5 秒)", bgColor: .red)

        nextGameButton.addTapGestureRecognizer {
            stopCountDown()
            dismissTwoVC(animated: false) {
                launchNextGame()
            }
        }

        if context.contentTab == .topics {
            layout(2, 56, 44, 8, nextGameButton)
        } else {
            layout(2, 46, 44, 8, nextGameButton)
        }

        addSubview(nextGameButton)
        var leftSeconds = 5
        countDownTimer = Timer.scheduledTimer(withTimeInterval: 1.00, repeats: true) { _ in
            leftSeconds -= 1
            nextGameButton.setTitle("次の挑戦 ( \(leftSeconds) 秒)", for: .normal)

            guard leftSeconds > 0 else {
                countDownTimer?.invalidate()
                dismissTwoVC(animated: false) {
                    launchNextGame()
                }
                return
            }
        }

        return nextGameButton
    }

    func addBackButton() {
        let backButton = createButton(title: "戻   る", bgColor: .darkGray)

        backButton.addTapGestureRecognizer {
            stopCountDown()
            dismissTwoVC()
            if context.contentTab == .infiniteChallenge {
                if let icwPage = rootViewController.current as? InfiniteChallengeSwipablePage {
                    (icwPage.pages[2] as? InfiniteChallengePage)?.tableView.reloadData()
                }
            }
        }

        if context.contentTab == .topics {
            layout(2, 66, 44, 8, backButton)
        } else {
            layout(2, 56, 44, 8, backButton)
        }

        addSubview(backButton)
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        viewWillAppear()
    }
}

private func launchNextGame() {
    if isUnderDailySentenceLimit() {
        guard let vc = UIApplication.getPresentedViewController() else { return }
        launchStoryboard(vc, "MessengerGame")
    }
}
