//
//  MedalPage.swift
//  今話したい
//
//  Created by Wangchou Lu on 3/26/31 H.
//  Copyright © 31 Heisei Lu, WangChou. All rights reserved.
//

import Foundation
import Promises
import UIKit

private let context = GameContext.shared

class MedalPage: UIViewController {
    static let id = "MedalPage"
    static var shared: MedalPage?
    var medalPageView: MedalPageView? {
        return (view as? MedalPageView)
    }

    override func loadView() {
        view = MedalPageView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        medalPageView?.render()
        MedalPage.shared = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        MedalPage.shared = nil
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
        clipsToBounds = true
        frame = CGRect(x: 0, y: 0, width: screen.width, height: screen.height)
    }

    func render() {
        context.gameMode = .medalMode
        removeAllSubviews()
        addTextbackground()
        addTopBar(y: topPaddedY + 1)

        addLangInfo(y: (yMax + 12) / 2 - 22 - 4)
        addGoButton(x: 28, y: (yMax + 12) / 2 - 22 + 27, w: 18)
        addBottomButtons()
    }

    // MARK: - TopBar

    private func addIconButton(iconName: String,
                               _ x: Int, _ y: Int, _ w: Int, _ h: Int,
                               onClick: (() -> Void)?) {
        let button = addButton(title: "", bgColor: myOrange, onClick: onClick)
        button.setIconImage(named: iconName, tintColor: .black, isIconOnLeft: false)
        button.roundBorder(width: step / 2, radius: step,
                           color: rgb(35, 35, 35))
        button.showsTouchWhenHighlighted = true

        layout(x, y, w, h, button)
    }

    private func addTopBar(y: Int) {
        addIconButton(iconName: "outline_settings_black_\(iconSize)",
                      2, y, 7, 7) {
            (rootViewController.current as? UIPageViewController)?.goToPreviousPage()
        }

        addIconButton(iconName: "outline_all_inclusive_black_\(iconSize)",
                      39, y, 7, 7) {
            (rootViewController.current as? UIPageViewController)?.goToNextPage()
        }

        // total medal counts
        let outerRect = addRect(x: 13, y: y, w: 21, h: 7,
                                color: UIColor.black.withAlphaComponent(0.2))
        outerRect.roundBorder(width: step / 2, radius: step,
                              color: UIColor.black.withAlphaComponent(0.8))
        outerRect.centerX(frame)

        let medalView = MedalView()
        layout(15, y + 2, 4, 4, medalView)
        medalView.centerY(outerRect.frame)
        medalView.moveToLeft(outerRect.frame, xShift: step * 1.5)
        addSubview(medalView)

        let starAttrStr = getStrokeText("\(context.gameMedal.totalCount)",
                                        myOrange,
                                        strokeWidth: Float(step * -3 / 5),
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
        let rect = addRect(x: 3, y: y + 6, w: 42, h: 31, color: UIColor.black.withAlphaComponent(0.4))
        rect.roundBorder(radius: step * 2)
        let font = (i18n.isZh || i18n.isJa) ? MyFont.bold(ofSize: 9 * step) :
            MyFont.bold(ofSize: 7 * step)
        let attrTitle = getStrokeText(gameLang == .jp ? i18n.japanese : i18n.english,
                                      .white,
                                      strokeWidth: Float(step * -1 / 3),
                                      font: font)

        addAttrText(x: 7, y: y - 2, h: 13, text: attrTitle)
    }

    private func addChangeLangButton(y: Int) {
        let changeLangButton = UIButton()
        layout(34, y, 8, 5, changeLangButton)
        addSubview(changeLangButton)

        let attrTitle = getStrokeText(gameLang == .jp ? i18n.enAbbr : i18n.jaAbbr,
                                      buttonForegroundGray,
                                      strokeWidth: Float(step * -1 / 3),
                                      font: MyFont.bold(ofSize: 4 * step))

        changeLangButton.setAttributedTitle(attrTitle, for: .normal)

        changeLangButton.addTapGestureRecognizer { [weak self] in
            changeLangButton.isUserInteractionEnabled = false
            changeGameLangTo(lang: gameLang == .jp ? .en : .jp)
            Promises.all([waitTranslationLoaded,
                          waitKanaInfoLoaded,
                          waitSentenceScoresLoaded,
                          waitUserSaidSentencesLoaded]).then { _ in
                            changeLangButton.isUserInteractionEnabled = true
                self?.render()
            }
        }

        changeLangButton.setStyle(style: .darkOption, step: step)
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
        button.roundBorder(width: step / 2,
                           radius: step * CGFloat(w) / 2,
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
            launchVC(Messenger.id, isOverCurrent: false)
        }
    }

    func addBottomButtons() {
        let buttonY = Int((screen.height - bottomButtonHeight) / step) - 2
        addIconButton(iconName: "round_timeline_black_\(iconSize)",
                      2, buttonY, 7, 7) {
            launchVC(MedalSummaryPage.id)
        }

        addIconButton(iconName: "round_spellcheck_black_\(iconSize)",
                      10, buttonY, 7, 7) {
            context.loadMedalCorrectionSentence()
            launchVC(MedalCorrectionPage.id)
        }

        waitSentenceScoresLoaded.then { _ in
            self.addMissCountBubble(buttonY: buttonY)
        }
        if i18n.isZh {
            let x = isIPad ? 18 : 39
            addIconButton(iconName: "outline_info_black_\(iconSize)",
                          x, buttonY, 7, 7) {
                launchVC("InfoPage")
            }
        }
    }

    private func addMissCountBubble(buttonY: Int) {
        let missedCount = context.getMissedCount()
        if missedCount > 0 {
            let w = missedCount >= 100 ? 7 : (missedCount >= 10 ? 5 : 4)
            let y = missedCount >= 100 ? (buttonY - 2) : (buttonY - 1)
            let circle = addRect(x: 19 - w, y: y, w: w, h: 4, color: .red)
            circle.roundBorder(width: step / 4, radius: circle.frame.height / 2, color: .black)
            let missedText = getStrokeText("\(missedCount)", .white,
                                           strokeWidth: -2, strokColor: .black,
                                           font: MyFont.heavyDigit(ofSize: step * 2.4))
            let label = addAttrText(x: 0, y: 0, h: 3,
                                    text: missedText)
            label.sizeToFit()
            label.centerIn(circle.frame)
        }
    }
}

private func rollingText(view: UIView) {
    let animator = UIViewPropertyAnimator(duration: 30, curve: .easeOut, animations: {
        let tx: CGFloat = -1.5 * 320 * cos(.pi / 8)
        var ty: CGFloat = -1.5 * 320 * sin(.pi / 8)

        // not sure why... this will fix bug
        if #available(iOS 13, *) {
            ty = 0
        }

        view.transform = view.transform
            .translatedBy(x: tx, y: ty)
    })

    animator.startAnimation()
}

extension GridLayout where Self: UIView {
    // MARK: - textBackground

    func addTextbackground(bgColor: UIColor = darkBackground,
                           textColor: UIColor = textGold,
                           useGameSentences: Bool = false) {
        backgroundColor = bgColor
        if isSimulator { return }
        let num = Int(sqrt(pow(frame.width, 2) + pow(frame.height, 2)) / step) / 8
        let level = context.gameMedal.lowLevel
        func getGameSentences() -> [String] {
            var sentences: [String] = []
            let count = isSimulator ? 3 : context.sentences.count
            for i in 0 ..< num * 4 {
                sentences.append(context.sentences[i % count])
            }
            return sentences
        }
        let sentences = useGameSentences ? getGameSentences() :
            getRandSentences(level: level, numOfSentences: num * 4)

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
            let y = i * 9 + 3
            let sentence = randPad(sentences[i]) +
                randPad(sentences[i + num]) +
                randPad(sentences[i + (2 * num)]) +
                sentences[i + (3 * num)]
            let label = addText(x: x, y: y, h: 6 - level.rawValue / 3,
                                text: sentence,
                                color: textColor)
            label.sizeToFit()
            label.frame.size.height += step // fix sizeToFit will cut the bottom of g
            label.centerX(frame)
            label.textAlignment = .left

            var ty = tan(.pi / 8) * frame.width
            if #available(iOS 13, *) {
                ty = 0
            }
            label.transform = CGAffineTransform.identity
                .translatedBy(x: 0, y: ty)
                .rotated(by: -1 * .pi / 8)
            rollingText(view: label)
        }
    }

    func addDailyGoalView(x: Int, y: Int,
                          isFullStatus: Bool = false,
                          delay: TimeInterval = 0,
                          duration: TimeInterval = 0) {
        // title
        let titleLabel = addText(x: x, y: y, h: 3, text: i18n.todaySummary, color: .white)
        titleLabel.frame.origin.y += step / 4

        // Daily Circle Progress
        let todayPercent = getTodaySentenceCount().f / context.gameSetting.dailySentenceGoal.f
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
            bgRect.frame = bgRect.frame.padding(-1 * step * 8 / 24 * 1.1)
            bgRect.roundBorder(radius: bgRect.frame.width / 2)

            let attrText = getStrokeText(valueString,
                                         valueColor,
                                         strokeWidth: Float(-0.3 * step),
                                         strokColor: .black,
                                         font: isHeavy ? MyFont.heavyDigit(ofSize: 3.6 * step) :
                                             MyFont.bold(ofSize: 3 * step))
            let valueLabel = addAttrText(x: x + 10, y: y + 4, h: 4, text: attrText)
            valueLabel.sizeToFit()
            valueLabel.centerIn(bgRect.frame)

            let subtitleLabel = addText(x: x + 10, y: y + 13, h: 4, text: subtitle,
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
            let timeValueString = playSecs < 6000 ? String(format: "%.1f", playSecs.f / 60) :
                String(format: "%.0f", playSecs.f / 60)
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
        isFinishPage: Bool = false
    ) {
        let medalProgressBar = MedalProgressBar()
        layout(x, y, 34, 15, medalProgressBar)
        addSubview(medalProgressBar)
        medalProgressBar.medalCount = medalFrom
        medalProgressBar.isFinishedPageMode = isFinishPage
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
