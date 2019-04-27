//
//  MedalPage.swift
//  今話したい
//
//  Created by Wangchou Lu on 3/26/31 H.
//  Copyright © 31 Heisei Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

private let context = GameContext.shared

class MedalPage: UIViewController {
    static let id = "MedalPage"
    var medalPageView: MedalPageView? {
        return (view as? MedalPageView)
    }

    override func loadView() {
        view = MedalPageView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        medalPageView?.viewWillAppear()
    }
}

class MedalPageView: UIView, ReloadableView, GridLayout {
    var yMax: Int {
        return Int((screen.height - getBottomPadding()) / step)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        sharedInit()
    }

    func sharedInit() {
        self.clipsToBounds = true
        self.frame = CGRect(x: 0, y: 0, width: screen.width, height: screen.height)
    }

    func viewWillAppear() {
        context.gameMode = .medalMode
        removeAllSubviews()
        addTextbackground(bgColor: rgb(60, 60, 60), textColor: textGold)
        addTopBar(y: topPaddedY + 1)

        addLangInfo(y: (yMax + 12)/2 - 22 - 4)
        addGoButton(x: 28, y: (yMax + 12)/2 - 22 + 27, w: 18)
        addBottomButtons()
    }

    // MARK: - TopBar
    private func addButton(iconName: String,
                           _ x: Int, _ y: Int, _ w: Int, _ h: Int,
                           onClick: (() -> Void)?) {
        let button = createButton(title: "", bgColor: myOrange)
        button.setIconImage(named: iconName, tintColor: .black, isIconOnLeft: false)
        button.roundBorder(borderWidth: step/2, cornerRadius: step,
                           color: rgb(35, 35, 35))
        addSubview(button)
        layout(x, y, w, h, button)
        button.addTapGestureRecognizer {
            onClick?()
        }
    }

    private func addTopBar(y: Int) {
        addButton(iconName: "outline_settings_black_\(iconSize)",
        2, y, 7, 7) {
            (rootViewController.current as? UIPageViewController)?.goToPreviousPage()
        }

        addButton(iconName: "outline_all_inclusive_black_\(iconSize)",
        39, y, 7, 7) {
            (rootViewController.current as? UIPageViewController)?.goToNextPage()
        }

        // total medal counts
        let outerRect = addRect(x: 13, y: y, w: 21, h: 7,
                                color: UIColor.black.withAlphaComponent(0.2))
        outerRect.roundBorder(borderWidth: step/2, cornerRadius: step,
                              color: UIColor.black.withAlphaComponent(0.8))
        outerRect.centerX(frame)

        let medalView = MedalView()
        layout(15, y + 2, 4, 4, medalView)
        medalView.centerY(outerRect.frame)
        medalView.moveToLeft(outerRect.frame, xShift: step * 1.5)
        addSubview(medalView)

        let starAttrStr = getStrokeText("\(context.gameMedal.totalCount)",
            myOrange,
            strokeWidth: Float(step * -3/5),
            font: MyFont.heavyDigit(ofSize: 5 * step))
        let label = addAttrText(x: 19, y: y - 1, w: 13, h: 9, text: starAttrStr)
        label.moveToRight(outerRect.frame, xShift: -1.5 * step)
        label.textAlignment = .right
    }

    // MARK: - LangInfo
    private func addLangInfo(y: Int) {
        addChangeLangButton(y: y)
        addLangTitleBox(y: y + 4)
        addMedalProgressBar(x: 7, y: y + 13, medalFrom: context.gameMedal.count)
        addDailyGoalView(x: 7, y: y + 24)
    }

    private func addLangTitleBox(y: Int) {
        let rect = addRect(x: 3, y: y+6, w: 42, h: 31, color: UIColor.black.withAlphaComponent(0.4))
        rect.roundBorder(borderWidth: 0, cornerRadius: step * 2, color: .clear)
        let font = (i18n.isZh || i18n.isJa) ? MyFont.bold(ofSize: 9*step) :
                                              MyFont.bold(ofSize: 7*step)
        let attrTitle = getStrokeText(gameLang == .jp ? i18n.japanese : i18n.english,
                                      .white,
                                      strokeWidth: Float(step * -1/3),
                                      font: font)

        let label = addAttrText(x: 7, y: y, h: 13, text: attrTitle)
        label.sizeToFit()
    }

    private func addChangeLangButton(y: Int) {
        let changeLangButton = UIButton()
        changeLangButton.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        changeLangButton.roundBorder(borderWidth: 0, cornerRadius: step, color: .clear)
        let attrTitle = getStrokeText(gameLang == .jp ? i18n.enAbbr : i18n.jaAbbr,
                                      rgb(200, 200, 200),
                                      strokeWidth: Float(step * -1/3),
                                      font: MyFont.bold(ofSize: 4*step))

        changeLangButton.setAttributedTitle(attrTitle, for: .normal)
        layout(34, y, 8, 5, changeLangButton)
        changeLangButton.addTarget(self, action: #selector(onChangeLangButtonClicked), for: .touchUpInside)
        changeLangButton.showsTouchWhenHighlighted = true
        addSubview(changeLangButton)
    }

    @objc func onChangeLangButtonClicked() {
        changeGameLangTo(lang: gameLang == .jp ? .en : .jp)
        self.viewWillAppear()
    }

    // MARK: - GoButton
    private func addGoButton(x: Int, y: Int, w: Int) {
        let button = UIButton()
        button.setTitleColor(UIColor.white.withAlphaComponent(0.6), for: .highlighted)
        button.backgroundColor = .red
        let attrText = getStrokeText(
            "GO!",
            .white,
            font: MyFont.bold(ofSize: 5 * step)
        )
        button.setAttributedTitle(attrText, for: .normal)
        button.roundBorder(borderWidth: step/2,
                           cornerRadius: step * CGFloat(w)/2,
                           color: .black)
        button.showsTouchWhenHighlighted = true
        button.addTarget(self, action: #selector(onGoButtonClicked), for: .touchUpInside)

        layout(x, y, w, w, button)
        addSubview(button)
    }

    @objc func onGoButtonClicked() {
        context.gameMode = .medalMode
        guard !TopicDetailPage.isChallengeButtonDisabled else { return }
        if isUnderDailySentenceLimit() {
            launchVC(Messenger.id)
        }
    }

    func addBottomButtons() {
        let buttonY = Int((screen.height - bottomButtonHeight)/step) - 2
        addButton(iconName: "round_timeline_black_\(iconSize)",
                  2, buttonY, 7, 7) {
            launchVC(MedalSummaryPage.id)
        }

        addButton(iconName: "round_spellcheck_black_\(iconSize)",
        10, buttonY, 7, 7) {
            context.loadMedalCorrectionSentence()
            launchVC(MedalCorrectionPage.id)
        }

        if i18n.isZh {
            addButton(iconName: "outline_info_black_\(iconSize)",
                      39, buttonY, 7, 7) {
                launchVC("InfoPage")
            }
        }
    }
}

private func rollingText(view: UIView) {
    let animator = UIViewPropertyAnimator(duration: 15, curve: .easeOut, animations: {
        view.transform = CGAffineTransform.identity
            .translatedBy(x: 0, y: screen.width/2)
            .rotated(by: -1 * .pi/8)
            .translatedBy(x: -1.5 * screen.width * cos(.pi/8), y: -1.5 * screen.width * sin(.pi/8))
    })

    animator.startAnimation()
}

extension GridLayout where Self: UIView {
    // MARK: - textBackground
    func addTextbackground(bgColor: UIColor, textColor: UIColor) {
        backgroundColor = bgColor
        if isSimulator { return }
        let num = Int(sqrt(pow(screen.width, 2) + pow(screen.height, 2)) / step)/8
        let level = context.gameMedal.lowLevel
        let sentences = getRandSentences(level: level, numOfSentences: num * 4)

        func randPad(_ string: String) -> String {
            var res = string
            let prefixCount = Int.random(in: 0 ... 10)
            let suffixCount = Int.random(in: 2 ... 10)
            for _ in 0 ..< prefixCount {
                res = " " + res
            }
            for _ in 0 ..< suffixCount {
                res += " "
            }
            return res
        }

        for i in 0 ..< num {
            let x = 1
            let y = i * 9
            let sentence = randPad(sentences[i]) +
                randPad(sentences[i+num]) +
                randPad(sentences[i + (2 * num)]) +
                sentences[i + (3 * num)]
            let label = addText(x: x, y: y, h: 6 - level.rawValue/3,
                                text: sentence,
                                color: textColor)
            label.sizeToFit()
            label.centerX(frame)
            label.textAlignment = .left

            label.transform = CGAffineTransform.identity
                .translatedBy(x: 0, y: screen.width/2)
                .rotated(by: -1 * .pi/8)
            rollingText(view: label)
        }
    }

    func addDailyGoalView(x: Int, y: Int,
                          isFullStatus: Bool = false,
                          delay: TimeInterval = 0,
                          duration: TimeInterval = 0) {
        // title
        let titleLabel = addText(x: x, y: y, h: 3, text: i18n.todaySummary, color: .white)
        titleLabel.frame.origin.y += step/4

        // Daily Circle Progress
        let todayPercent = getTodaySentenceCount().f/context.gameSetting.dailySentenceGoal.f
        let dailyGoalView = ProgressCircleView()
        layout(x, y + 4, 8, 8, dailyGoalView)
        addSubview(dailyGoalView)
        dailyGoalView.percent = todayPercent

        func addCircleStatus(x: Int,
                             valueString: String,
                             isHeavy: Bool = true,
                             valueColor: UIColor,
                             subtitle: String) -> [UIView] {
            let bgRect = addRect(x: x, y: y + 4, w: 8, h: 8,
                                 color: progressBackGray.withAlphaComponent(0.6))
            bgRect.frame = bgRect.frame.padding(-1 * step * 8/24 * 1.1)
            bgRect.roundBorder(borderWidth: 0.5, cornerRadius: bgRect.frame.width/2, color: .clear)

            let attrText = getStrokeText(valueString,
                                         valueColor,
                                         strokeWidth: Float(-0.3 * step),
                                         strokColor: .black,
                                         font: isHeavy ? MyFont.heavyDigit(ofSize: 3.6 * step) :
                                            MyFont.bold(ofSize: 3 * step)
            )
            let valueLabel = addAttrText(x: x+10, y: y + 4, h: 4, text: attrText)
            valueLabel.sizeToFit()
            valueLabel.centerIn(bgRect.frame)

            let subtitleLabel = addText(x: x+10, y: y+13, h: 4, text: subtitle,
                                        font: MyFont.regular(ofSize: 2 * step),
                                        color: minorTextColor)
            subtitleLabel.sizeToFit()
            subtitleLabel.centerX(bgRect.frame)
            return [bgRect, valueLabel, subtitleLabel]
        }

        var views: [UIView] = [titleLabel, dailyGoalView]

        // 今日のメダル
        let todayMedalCount = getTodayMedalCount()
        let medalCountColor = todayMedalCount > 0 ? myGreen :
            (todayMedalCount == 0 ? myWhite : myRed)
        let medalCountViews = addCircleStatus(x: x + 11,
                                              valueString: "\(todayMedalCount > 0 ? "+" : "")\(todayMedalCount)",
            valueColor: medalCountColor,
            subtitle: i18n.medal)
        views.append(contentsOf: medalCountViews)

        // ゲーム時間
        if isFullStatus {
            let playSecs = getTodaySeconds()
            let timeValueString = playSecs < 6000 ? String(format: "%.1f", playSecs.f/60) :
                String(format: "%.0f", playSecs.f/60)
            let timeStatusViews = addCircleStatus(x: x + 22,
                                                  valueString: timeValueString,
                                                  isHeavy: false,
                                                  valueColor: .white,
                                                  subtitle: i18n.mins)
            views.append(contentsOf: timeStatusViews)
        }

        if duration > 0 {
            views.forEach { $0.fadeIn(delay: delay, duration: duration,
                                      fromAlpha: 0, toAlpha: 0.6) }
            Timer.scheduledTimer(withTimeInterval: delay + duration, repeats: false) { _ in
                views.forEach { $0.fadeIn(delay: 0, duration: 1.0,
                                          fromAlpha: 0.6, toAlpha: 1.0) }

            }
        }
    }

    // MARK: - progressBar
    func addMedalProgressBar(
        x: Int,
        y: Int,
        medalFrom: Int,
        medalTo: Int = -1,
        animateInDelay: TimeInterval = 0,
        duration: TimeInterval = 0,
        animateProgressDelay: TimeInterval = 0,
        isLightSubText: Bool = false
        ) {
        let medalProgressBar = MedalProgressBar()
        layout(x, y, 34, 15, medalProgressBar)
        addSubview(medalProgressBar)
        medalProgressBar.medalCount = medalFrom
        medalProgressBar.isFinishedPageMode = isLightSubText
        if duration > 0 {
            medalProgressBar.animateIn(delay: animateInDelay, duration: duration)
        }

        // animate progress
        if medalTo >= 0 {
            Timer.scheduledTimer(withTimeInterval: animateProgressDelay, repeats: false) { _ in
                medalProgressBar.animateMedalProgress(to: medalTo)
            }
        }
    }
}
