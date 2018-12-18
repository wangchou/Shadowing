//
//  ICListTopView.swift
//  今話したい
//
//  Created by Wangchou Lu on 11/15/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import UIKit

private let context = GameContext.shared
private let i18n = I18n.shared

class ICListTopView: UIView, GridLayout, ReloadableView {
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
        viewWillAppear()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        viewWillAppear()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        viewWillAppear()
    }

    func viewWillAppear() {
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

// MARK: Daily Goal Mode
extension ICListTopView {
    func renderDailyGoalMode() {
        gridCount = 48
        updateDailyViewBGColor()

        circleFrame = getFrame(11, 3, 24, 24)

        let backCircle = CircleView(frame: circleFrame)
        backCircle.lineWidth = stepFloat * 1.3
        backCircle.color = rgb(155, 155, 155)
        addSubview(backCircle)

        frontCircle = CircleView(frame: circleFrame)
        frontCircle!.lineWidth = stepFloat * 1.3
        frontCircle!.percent = percent >= 1.0 ? percent.c : 0
        addSubview(frontCircle!)

        percentLabel = addText(x: 14, y: 6, w: 30, h: 8,
                                   text: percent >= 1.0 ? percentageText : "0.0%",
                                   font: MyFont.bold(ofSize: getFontSize(h: 8)),
                                   color: .black)
        percentLabel?.textAlignment = .center
        percentLabel?.centerIn(circleFrame)

        let goalLabel = addText(x: 14, y: 28, w: 30, h: 4,
                                text: goalText,
                                font: MyFont.bold(ofSize: getFontSize(h: 4)))
        goalLabel.textAlignment = .center
        goalLabel.centerX(circleFrame)

        addDailySideBar()
        addFreeVersionButton()
    }

    func animateProgress() {
        guard context.gameSetting.icTopViewMode == .dailyGoal,
              percent > 0,
              percent < 1.0 else { return }

        // background
        let animation = CABasicAnimation(keyPath: "backgroundColor")

        animation.duration = 0.5

        animation.fromValue = longTermGoalColor.withSaturation(0).cgColor
        animation.toValue = longTermGoalColor.withSaturation(percent.c).cgColor

        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)

        layer.backgroundColor = longTermGoalColor.withSaturation(percent.c).cgColor
        layer.add(animation, forKey: "animateBackground")

        // percentLabel
        guard let percentLabel = percentLabel else { return }
        var repeatCount = 0
        let targetCount = 25
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            guard repeatCount <= 25 else {
                self.timer?.invalidate()
                return
            }
            let currentPercent = self.percent * repeatCount.f/targetCount.f
            percentLabel.text = String(format: "%.1f", currentPercent * 100) + "%"
            percentLabel.centerIn(self.circleFrame)
            repeatCount += 1
        }

        // circle
        guard let circleView = frontCircle else { return }
        circleView.percent = percent.c
        circleView.animate(duration: 0.5)
    }

    func updateDailyViewBGColor() {
        // 0%   = rgb(238, 238, 238)
        // 100% = rgb(255, 204, 0)
        guard percent < 1.0 else {
            backgroundColor = longTermGoalColor.withSaturation(1.0)
            return
        }

        guard percent > 0 else {
            backgroundColor = rgb(238, 238, 238)
            return
        }

        backgroundColor = longTermGoalColor.withSaturation(0)
    }

    func addDailySideBar() {
        let topRect = addRect(x: 38, y: 3, w: 8, h: 20, color: .white)
        topRect.roundBorder(borderWidth: 0,
                            cornerRadius: 5,
                            color: .clear)

        let xFrame = topRect.frame
        addDailySideBarText(sprintText, y: 4, boundFrame: xFrame, color: .darkGray)
        addDailySideBarText(continuesText, y: 8, isBold: true, boundFrame: xFrame)
        addDailySideBarText(dayText, y: 11, boundFrame: topRect.frame, color: .darkGray)
        addDailySideBarText(sentencesCountText, y: 16, isBold: true, boundFrame: xFrame)
        addDailySideBarText(sentenceText, y: 19, boundFrame: xFrame, color: .darkGray)

        let bottomRect = addRect(x: 38, y: 24, w: 8, h: 8, color: .white)
        bottomRect.roundBorder(borderWidth: 0,
                               cornerRadius: 5,
                               color: .clear)
        addDailySideBarText(bestText, y: 25, boundFrame: xFrame, color: .darkGray)
        addDailySideBarText(bestCountText, y: 28, isBold: true, boundFrame: xFrame)

        addDailySideBarSeparateLine(y: 7, boundFrame: getFrame(38, 3, 8, 9))
        addDailySideBarSeparateLine(y: 15, boundFrame: getFrame(38, 14, 8, 2))
    }

    func addDailySideBarText(_ text: String,
                             y: Int,
                             isBold: Bool = false,
                             boundFrame: CGRect,
                             color: UIColor = .black) {
        let font = isBold ? MyFont.bold(ofSize: getFontSize(h: 3)) :
                            MyFont.regular(ofSize: getFontSize(h: 3))
        let sprintLabel = addText(x: 14, y: y, w: 8, h: 3,
                                  text: text,
                                  font: font,
                                  color: color)
        sprintLabel.textAlignment = .center
        sprintLabel.centerX(boundFrame)
    }

    func addDailySideBarSeparateLine(y: Int, boundFrame: CGRect) {
        let separateLine = UIView()
        layout(0, y, 6, 1, separateLine)
        separateLine.frame.size.height = 0.5
        separateLine.backgroundColor = rgb(200, 200, 200)
        addSubview(separateLine)
        separateLine.centerIn(boundFrame)
    }

    func addFreeVersionButton() {
        guard isFreeVersion() else { return }
        let freeRect = addRect(x: 2, y: 27, w: 8, h: 5, color: .clear)
        freeRect.roundBorder(borderWidth: 1.5,
                               cornerRadius: 5,
                               color: .white)
        let freeLabel = addText(x: 14, y: 26, w: 8, h: 3,
                                  text: i18n.freeVersion,
                                  font: MyFont.bold(ofSize: getFontSize(h: 3)),
                                  color: .white)
        freeLabel.textAlignment = .center
        freeLabel.centerIn(freeRect.frame)
        freeRect.addTapGestureRecognizer {
            IAPHelper.shared.showPurchaseView(isChanllenge: false)
        }
    }
}

// MARK: Timeline Mode
extension ICListTopView {
    func renderTimelineMode() {
        gridCount = 16
        backgroundColor = longTermGoalColor.withSaturation(0.3)
        addTimeline()
        addTimelineBottomBar()
    }

    func addTimeline() {
        let dailyGoal = context.gameSetting.dailySentenceGoal
        let today = Date()
        let weekday = Calendar.current.component(.weekday, from: today)
        var timelineBox = TimelineBox(date: today, row: weekday, column: 1)
        //let recordsByDate = getRecordsByDate()
        var index = 0
        let sentencesCounts = getSentenceCountsByDays()
        while timelineBox.column < timelineColumnCount {
            //let dateString = getDateKey(date: timelineBox.date)
            //let color = getColorFrom(records: recordsByDate[dateString])
            let isGoalCompleted = (index < sentencesCounts.count && sentencesCounts[index] >= dailyGoal)
            addTimelineBox(
                row: timelineBox.row,
                column: timelineBox.column,
                color: isGoalCompleted ? .black : .clear
            )
            timelineBox.toYesterday()
            if timelineBox.day == 1 {
                addTimelineTextLabel(row: 0, column: timelineBox.column, text: "\(timelineBox.month)月")
            }
            index += 1
        }
        let weekdayLabels = ["日", "月", "火", "水", "木", "金", "土"]
        for i in 0..<weekdayLabels.count {
            addTimelineTextLabel(row: i + 1, column: 0, text: weekdayLabels[i], color: (i == 0 || i == 6) ? .red : .black)
        }
    }

    func addTimelineBottomBar() {
        let sevenDaysPercentText = String(format: "%d", (100 * sevenDaysCount.f / 7).i)
        let thirtyDaysPercentText = String(format: "%d", (100 * thirtyDaysCount.f / 30).i)

        let topTexts = ["\(continues)", "\(bestCount)", "\(sevenDaysPercentText)%", "\(thirtyDaysPercentText)%", "\(allSentenceCount)"]
        let bottomTexts = [i18n.continues, i18n.best, i18n.last7Days, i18n.last30Days, i18n.sentence]
        for boxIndex in 0..<5 {
            let box = addRect(x: 1 + boxIndex * 3, y: 8, w: 3, h: 2)
            addTimelinePadding(box)
            box.frame.size.width -= stepFloat * 0.3
            box.frame.size.height += stepFloat * 0.2
            box.frame.origin.y += stepFloat * 0.3
            box.roundBorder(borderWidth: 0, cornerRadius: 5, color: .clear)
            box.backgroundColor = .white

            let topText = addText(
                x: 1 + boxIndex * 3, y: 8, w: 4, h: 2,
                text: topTexts[boxIndex],
                font: MyFont.bold(ofSize: stepFloat * 0.7),
                color: rgb(74, 74, 74)
            )
            topText.textAlignment = .center
            topText.centerX(box.frame)
            topText.frame.origin.y += stepFloat * 0.4

            let bottomText = addText(
                x: 1 + boxIndex * 3, y: 9, w: 4, h: 2,
                text: bottomTexts[boxIndex],
                font: MyFont.regular(ofSize: stepFloat * 0.5),
                color: .lightGray
            )
            bottomText.textAlignment = .center
            bottomText.centerX(box.frame)
            bottomText.frame.origin.y += stepFloat * 0.25
        }
    }

    func addTimelineBox(row: Int, column: Int, color: UIColor = myLightText) {
        let width = stepFloat * 0.7
        let box = UIView()
        box.backgroundColor = color
        layout(timelineColumnCount - column, row, 1, 1, box)
        box.frame.size.width = width
        box.frame.size.height = width
        box.roundBorder(borderWidth: 1, cornerRadius: width/2, color: .black)
        addSubview(box)

        addTimelinePadding(box)
    }

    func addTimelineTextLabel(row: Int, column: Int, text: String, color: UIColor = .black) {
        let label = addText(
            x: timelineColumnCount - column,
            y: row,
            w: 3, h: 1,
            text: text,
            font: MyFont.thin(ofSize: stepFloat * 0.7),
            color: color
        )
        if row == 0 { // month labels
            label.frame.origin.y += stepFloat * (-0.1 + timelineYPadding)
        } else {
            label.frame.origin.y += stepFloat * (-0.2 + timelineYPadding)
        }
        label.frame.origin.x += stepFloat * timelineXPadding
    }

    func addTimelinePadding(_ view: UIView) {
        view.frame.origin.y += stepFloat * timelineYPadding
        view.frame.origin.x += stepFloat * timelineXPadding
    }
}

// MARK: LongTermGoalMode
extension ICListTopView {
    func renderLongTermGoalMode() {
        gridCount = 50
        backgroundColor = rgb(28, 28, 28)

        addLongTermTitle()
        addLongTermGoalDesc()
        addLongTermGoalBottomBar()
    }

    func addLongTermTitle() {
        if isGameClear {
            var descAttrText = NSMutableAttributedString()
            func addWord(_ word: String, _ level: Level) {
                descAttrText.append(getText(word,
                                            color: level.color.withSaturation(1.0),
                                            font: MyFont.bold(ofSize: stepFloat * 8)))
            }
            addWord("今", Level.lv0)
            addWord("話", Level.lv2)
            addWord("し", Level.lv4)
            addWord("た", Level.lv6)
            addWord("い", Level.lv8)
            let gameClearLabel = addAttrText(x: 5, y: 7, h: 14, text: descAttrText)
            gameClearLabel.textAlignment = .center
            gameClearLabel.centerX(frame)
        } else {
            let currentLvlColor = longTermGoalColor
            let goalLabel = addText(x: 5, y: 7, w: 50, h: 14, text: longTermGoalText, color: currentLvlColor)
            goalLabel.textAlignment = .center
            goalLabel.centerX(frame)
        }
    }
    func addLongTermGoalBottomBar() {
        let lvlColors = [Level.lv0.color.withSaturation(1.0),
                         Level.lv2.color.withSaturation(1.0),
                         Level.lv4.color.withSaturation(1.0),
                         Level.lv6.color.withSaturation(1.0)]

        var levelSentenceCounts = [1000, 3000, 6000, 10000]
        var wPoints = [0, 5, 15, 30, 50]
        var t: UILabel
        var bar: UIView
        for i in 0..<levelSentenceCounts.count {
            let w = wPoints[i+1] - wPoints[i]
            let c = lvlColors[i]
            bar = addRect(x: wPoints[i], y: 30, w: w, h: 1, color: c)
            bar.moveToBottom(frame)
            t = addText(x: 0, y: 20, w: 8, h: 3, text: "\(levelSentenceCounts[i])", color: c)
            t.textAlignment = .right
            t.moveToRight(bar.frame)
            t.moveToBottom(frame, yShift: -1 * stepFloat)
        }
    }

    func addLongTermGoalDesc() {
        let percentText = String(format: "%.1f", 100 * allSentenceCount.f/longTermGoal.f)
        let remainingDays = String(format: "%.1f", max(0, longTermGoal - allSentenceCount).f/context.gameSetting.dailySentenceGoal.f)
        let gray = rgb(155, 155, 155)
        var descAttrText = NSMutableAttributedString()
        func addWhiteText(_ text: String) {
            descAttrText.append(getText(text, color: .white,
                font: MyFont.bold(ofSize: stepFloat * 2.5)
            ))
        }
        func addGrayText(_ text: String) {
            descAttrText.append(getText(text, color: gray,
                                        font: MyFont.regular(ofSize: stepFloat * 2.5)
            ))
        }
        func addBoldGrayText(_ text: String) {
            descAttrText.append(getText(text, color: gray,
                                        font: MyFont.bold(ofSize: stepFloat * 2.5)
            ))
        }
        if isGameClear {
            addWhiteText("100 ")
            addGrayText("% を話した、")
            addWhiteText("\(clearDurationInDays) ")
            addGrayText("日間で。")
        } else {
            addWhiteText("\(percentText) ")
            addGrayText(i18n.longTermGoalMiddleText)
            addWhiteText(" \(remainingDays) ")
            addGrayText("\(i18n.dayRange)。")
        }

        let y = isGameClear ? 20 : 23
        var descLabel = addAttrText(x: 5, y: y, h: 5, text: descAttrText)
        descLabel.textAlignment = .center
        descLabel.centerX(frame)

        if isGameClear {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            dateFormatter.locale = Locale(identifier: Locale.current.identifier)
            descAttrText = NSMutableAttributedString()
            addBoldGrayText(dateFormatter.string(from: clearDate))
            descLabel = addAttrText(x: 5, y: 25, h: 5, text: descAttrText)
            descLabel.textAlignment = .center
            descLabel.centerX(frame)
        }
    }
}
