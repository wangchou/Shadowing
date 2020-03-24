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

private var countDownTimer: Timer?
private var pauseOrPlayButton: UIButton?
private var isPauseMode: Bool = true

func stopCountDown() {
    countDownTimer?.invalidate()
    pauseOrPlayButton?.setIconImage(named: "baseline_play_arrow_black_48pt", title: "", tintColor: .white, isIconOnLeft: false)
    pauseOrPlayButton = nil
    isPauseMode = false
}

@IBDesignable
class GameReportView: UIView, ReloadableView, GridLayout {
    var reportBox: GameReportBoxView?

    var safeAreaDiffY: Int {
        return (getTopPadding() > 20 && !isIPad) ? 2 : 0
    }

    func render() {
        removeAllSubviews()
        backgroundColor = UIColor.black.withAlphaComponent(0.6)
        clipsToBounds = true
        reportBox = GameReportBoxView()

        if context.gameMode == .topicMode {
            frame = CGRect(x: 0, y: 0,
                           width: screen.width,
                           height: screen.width * (1.37 + 0.01 * safeAreaDiffY.c))
            layout(2, 4 + safeAreaDiffY, 44, 48, reportBox!)
        } else {
            frame = CGRect(x: 0, y: 0,
                           width: screen.width,
                           height: screen.width * (1.18 + 0.01 * safeAreaDiffY.c))
            layout(2, 4 + safeAreaDiffY, 44, 40, reportBox!)
        }
        addSubview(reportBox!)
        reportBox?.render()

        pauseOrPlayButton = addNextGameButton()
        addBackButton()
    }

    func viewDidAppear() {
        reportBox?.animateProgressBar()
    }

    func viewDidDisappear() {
        countDownTimer?.invalidate()
        pauseOrPlayButton = nil
        reportBox?.removeAllSubviews()
        removeAllSubviews()
    }

    func addNextGameButton() -> UIButton {
        isPauseMode = true
        let button = addButton(title: "", bgColor: .red) {
            if isPauseMode {
                stopCountDown()
            } else {
                dismissTwoVC(animated: false) {
                    launchNextGame()
                }
            }
        }

        let todaySentenceCount = getTodaySentenceCount()
        let dailyGoal = context.gameSetting.dailySentenceGoal
        var isReachDailyByThisGame = false
        if let record = context.gameRecord {
            isReachDailyByThisGame = todaySentenceCount >= dailyGoal &&
                todaySentenceCount - record.correctCount < dailyGoal
        }
        let countDownSecs = isReachDailyByThisGame ? 8 : 5
        button.setIconImage(named: "baseline_pause_black_48pt", title: " \(i18n.nextGame) (\(countDownSecs)\(i18n.secs))", tintColor: .white, isIconOnLeft: true)

        if context.gameMode == .topicMode {
            layout(2, 54 + safeAreaDiffY, 30, 8, button)
        } else {
            layout(2, 46 + safeAreaDiffY, 30, 8, button)
        }

        var leftSeconds = countDownSecs
        countDownTimer?.invalidate()
        countDownTimer = Timer.scheduledTimer(withTimeInterval: 1.00, repeats: true) { _ in
            leftSeconds -= 1
            pauseOrPlayButton?.setTitle(" \(i18n.nextGame) (\(leftSeconds)\(i18n.secs))", for: .normal)
            guard leftSeconds > 0 else {
                countDownTimer?.invalidate()
                if !isSimulator {
                    dismissTwoVC(animated: false) {
                        launchNextGame()
                    }
                }
                return
            }
        }

        return button
    }

    func addBackButton() {
        let backButton = addButton(title: "", bgColor: .lightGray) {
            stopCountDown()
            dismissTwoVC()
            if context.gameMode == .infiniteChallengeMode {
                if let icwPage = rootViewController.current as? InfiniteChallengeSwipablePage {
                    icwPage.detailPage?.tableView.reloadData()
                }
            }
        }
        backButton.setIconImage(named: "baseline_exit_to_app_black_48pt", title: "", tintColor: .white, isIconOnLeft: false)

        if context.gameMode == .topicMode {
            layout(34, 54 + safeAreaDiffY, 12, 8, backButton)
        } else {
            layout(34, 46 + safeAreaDiffY, 12, 8, backButton)
        }
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        render()
    }
}

func launchNextGame() {
    if context.gameMode == .topicMode, !context.gameSetting.isRepeatOne {
        context.loadNextChallenge()
        rootViewController.topicSwipablePage.detailPage?.render()
    }
    if isUnderDailySentenceLimit() {
        launchVC(Messenger.id, isOverCurrent: false)
    }
}
