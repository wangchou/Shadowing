//
//  ICListTopView.swift
//  今話したい
//
//  Created by Wangchou Lu on 11/15/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import UIKit
import FirebaseAnalytics

private let context = GameContext.shared

class TopChartView: UIView, GridLayout, ReloadableView {
    // GridLayout
    var gridCount: Int = 48

    var axis: GridAxis = .horizontal

    var spacing: CGFloat = 0

    // animateProgress
    var timer: Timer?
    var frontCircle: CircleView?
    var percentLabel: UILabel?
    var circleFrame: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)

    var timelineColumnCount: Int  = 15
    var timelineYPadding: CGFloat = 0.3
    var timelineXPadding: CGFloat = -0.35

    let animationSecs: TimeInterval = 0.5

    var percent: Float = 0

    var percentageText: String {
        if percent >= 1.0 { return "完 成" }

        return String(format: "%.1f", percent * 100) + "%"
    }

    var goalText: String {
        return "\(i18n.goalPrefix)\(context.gameSetting.dailySentenceGoal)\(i18n.goalSuffix)"
    }

    var sprintText: String {
        return i18n.continues
    }

    var continues: Int = 0
    var continuesText: String {
        return "\(continues)"
    }

    var allSentenceCount: Int = 0

    var sevenDaysCount: Int = 0
    var thirtyDaysCount: Int = 0
    var isGameClear: Bool {
        return allSentenceCount >= 10000
    }
    var clearDurationInDays: Int = 0
    var clearDate: Date = Date()

    var longTermGoalColor: UIColor {
        if allSentenceCount < 1000 {
            return Level.lv0.color.withSaturation(1.0)
        }

        if allSentenceCount < 3000 {
            return Level.lv2.color.withSaturation(1.0)
        }

        if allSentenceCount < 6000 {
            return Level.lv4.color.withSaturation(1.0)
        }

        return Level.lv6.color.withSaturation(1.0)
    }
    var longTermGoal: Int {
        if allSentenceCount < 1000 {
            return 1000
        }

        if allSentenceCount < 3000 {
            return 3000
        }

        if allSentenceCount < 6000 {
            return 6000
        }
        return 10000
    }

    var longTermGoalText: String {
        return "\(longTermGoal)\(i18n.sentence)"
    }

    var dayText: String {
        return i18n.day
    }

    var continueSentenceCount: Int = 0
    var sentencesCountText: String {
        return "\(continueSentenceCount)"
    }

    var sentenceText: String {
        return i18n.sentence
    }

    var bestText: String {
        return i18n.best
    }
    var bestCount: Int = 0
    var bestCountText: String {
        return "\(bestCount)"
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addOnClickHandler()
        viewWillAppear()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addOnClickHandler()
        viewWillAppear()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        viewWillAppear()
    }

    func addOnClickHandler() {
        addTapGestureRecognizer {
            switchToNextTopViewMode()
            Analytics.logEvent("top_chart_view_clicked", parameters: nil)
            self.viewWillAppear()
            self.animateProgress()
        }
    }

    func viewWillAppear() {
        frame.size.width = screen.width
        frame.size.height = screen.width * 34/48
        removeAllSubviews()
        updateByRecords()

        switch GameContext.shared.gameSetting.icTopViewMode {
        case .dailyGoal:
            renderDailyGoalMode()
        case .timeline:
            renderTimelineMode()
        case .longTermGoal:
            renderLongTermGoalMode()
        }
    }

    func updateByRecords() {
        let sentenceCounts = getSentenceCountsByDays()
        percent = min(sentenceCounts[0].f / context.gameSetting.dailySentenceGoal.f, 1.0)

        continueSentenceCount = sentenceCounts[0]
        for i in 1..<sentenceCounts.count {
            if sentenceCounts[i] >= context.gameSetting.dailySentenceGoal {
                continueSentenceCount += sentenceCounts[i]
            } else {
                break
            }
        }

        continues = 0
        for i in 0..<sentenceCounts.count {
            if sentenceCounts[i] >= context.gameSetting.dailySentenceGoal {
                continues += 1
            } else if i > 0 { // skip today
                break
            }
        }

        bestCount = 0
        allSentenceCount = 0
        sevenDaysCount = 0
        thirtyDaysCount = 0
        var currentBest = 0
        var index = 0
        sentenceCounts.forEach { c in
            allSentenceCount += c
            if c >= context.gameSetting.dailySentenceGoal {
                currentBest += 1
                if index < 7 {
                    sevenDaysCount += 1
                }
                if index < 30 {
                    thirtyDaysCount += 1
                }
            } else {
                currentBest = 0
            }
            if currentBest > bestCount {
                bestCount = currentBest
            }
            index += 1
        }

        clearDurationInDays = 0
        if isGameClear {
            var sCount = 0
            for i in stride(from: sentenceCounts.count - 1, through: 0, by: -1) {
                sCount += sentenceCounts[i]
                clearDurationInDays += 1
                if sCount >= 10000 {
                    var dateComponent = DateComponents()
                    dateComponent.day = -1 * i
                    clearDate = Calendar.current.date(byAdding: dateComponent, to: Date()) ?? Date()
                    break
                }
            }
        }
    }
}

func switchToNextTopViewMode() {
    switch context.gameSetting.icTopViewMode {
    case .dailyGoal:
        context.gameSetting.icTopViewMode = .timeline
    case .timeline:
        context.gameSetting.icTopViewMode = .longTermGoal
    case .longTermGoal:
        context.gameSetting.icTopViewMode = .dailyGoal
    }
    saveGameSetting()
}
