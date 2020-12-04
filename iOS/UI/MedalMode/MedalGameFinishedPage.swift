//
//  MedalGameFinishedPage.swift
//  今話したい
//
//  Created by Wangchou Lu on 4/4/31 H.
//  Copyright © 31 Heisei Lu, WangChou. All rights reserved.
//

import Promises
import UIKit

private let context = GameContext.shared
private var countDownTimer: Timer?
private var playButton: UIButton?

class MedalGameFinishedPage: UIViewController {
    static let id = "Medal Game Finished Page"

    override func loadView() {
        view = MedalGameFinishedPageView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (view as? MedalGameFinishedPageView)?.render()
    }

    override func viewWillDisappear(_: Bool) {
        countDownTimer?.invalidate()
    }
}

class MedalGameFinishedPageView: UIView, ReloadableView, GridLayout {
    var strokeWidth: Float = 0

    var gr: GameRecord { return context.gameRecord! }

    var medal: GameMedal { return context.gameMedal }

    private var statusSpeakingPromise: Promise<Void> = fulfilledVoidPromise()

    var isJustReachDailyGoal: Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }

    private func sharedInit() {
        clipsToBounds = true
        frame = CGRect(x: 0, y: 0, width: screen.width, height: screen.height)
    }

    // MARK: - Lifecycle

    func render() {
        removeAllSubviews()
        strokeWidth = Float(step * -1 / 2.0)
        addTextbackground(useGameSentences: true)
        let yMax = Int(screen.height / step)
        addInfo(y: (yMax - 12) / 2 - 20)
        addActionButtons(y: (yMax - 12) / 2 + 28)
    }

    // MARK: - Say Result

    private func sayResult(gr: GameRecord) {
        let rankText = context.gameMedal.usingDetailRank ? gr.detailRank.rawValue : gr.rank.rawValue

        statusSpeakingPromise = teacherSay(
            i18n.getSpeakingStatus(percent: gr.progress, rank: rankText, reward: gr.medalReward),
            rate: context.assistantRate,
            ttsFixes: []
        )

        let todaySentenceCount = getTodaySentenceCount()
        if todaySentenceCount >= context.gameSetting.dailySentenceGoal,
           todaySentenceCount - (context.gameRecord?.correctCount ?? 0) < context.gameSetting.dailySentenceGoal {
            isJustReachDailyGoal = true
        }

        if isJustReachDailyGoal {
            statusSpeakingPromise.then {
                _ = teacherSay(i18n.reachDailyGoal,
                               rate: fastRate,
                               ttsFixes: [])
            }
        }
    }

    // MARK: - AddInfo

    private func addInfo(y: Int) {
        let medal = context.gameMedal
        guard let gr = context.gameRecord else { return }

        sayResult(gr: gr)

        addTitleBlock(y: y, duration: 0.2)

        // 1 now
        addCompleteness(y: y + 3, delay: 0, duration: 0.2)
        addRank(y: y + 3, delay: 0.3, duration: 0.2)
        addRecordDetail(y: y + 5, delay: 0.3, duration: 0.6)

        // 2 changes
        addMedalProgressBar(x: 7, y: y + 16,
                            medalFrom: medal.count - (gr.medalReward ?? 0),
                            medalTo: medal.count,
                            animateInDelay: 0.6,
                            duration: 0.2,
                            animateProgressDelay: 1.1,
                            isFinishPage: true)
        addMedal(y: y + 11, delay: 0.6, duration: 0.2)

        // 3 long-term
        addDailyGoalView(x: 7, y: y + 29,
                         isFullStatus: true,
                         delay: 1.8, duration: 0.2)
        addTipBox()
    }

    private func addTipBox() {
        if isIPad { return }
        let y = Int((screen.height - bottomButtonHeight) / step) - 3
        let h = 8
        let font = MyFont.regular(ofSize: step * 2)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = step / 3
        let attributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: paragraphStyle,
            .font: font,
        ]
        let attributedString = NSAttributedString(string: i18n.getRandTip(),
                                                  attributes: attributes)

        let box = addRect(x: 3, y: y, w: gridCount - 6, h: h)
        box.roundBorder(radius: step)
        box.backgroundColor = rgb(190, 190, 190).withAlphaComponent(0.7)

        let label = UILabel()
        label.attributedText = attributedString
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0

        layout(4, y, gridCount - 8, h, label)
        addSubview(label)
    }

    private func addTitleBlock(y: Int, delay: TimeInterval = 0, duration: TimeInterval) {
        // info background
        let rect = addRect(x: 3, y: y, w: 42, h: 46, color: rgb(0, 0, 0).withAlphaComponent(0.4))
        rect.roundBorder(radius: step * 3)

        rect.enlargeIn(delay: delay, duration: duration)

        let fontSize = (i18n.language.count > 5 || isIPad) ? 8 * step : 10 * step
        let attrText = getStrokeText(i18n.language,
                                     rgb(220, 220, 220),
                                     strokeWidth: strokeWidth / 2,
                                     font: MyFont.bold(ofSize: fontSize))
        let label = addAttrText(x: 5,
                                y: isIPad ? (y - 7) : (y - 8),
                                h: 12, text: attrText)
        label.centerX(frame)
        label.textAlignment = .center
        label.enlargeIn(delay: delay, duration: duration)
    }

    private func addRecordDetail(y: Int, delay: TimeInterval = 0, duration: TimeInterval = 0) {
        var colors: [UIColor] = []
        colors.append(contentsOf: Array(repeating: myGreen.withSaturation(1.0).withAlphaComponent(0.8), count: gr.perfectCount))
        colors.append(contentsOf: Array(repeating: myGreen.withAlphaComponent(0.5), count: gr.greatCount))
        colors.append(contentsOf: Array(repeating: myOrange.withAlphaComponent(0.8), count: gr.goodCount))
        colors.append(contentsOf: Array(repeating: myRed.withAlphaComponent(0.8), count: gr.missedCount))
        let rect = getFrame(40, y, 1, 8)

        let unit = Int(step / 2).c

        for i in 0 ..< colors.count {
            let thisRect = CGRect(
                x: rect.x - unit,
                y: rect.y + rect.height - 2 * unit * i.c - unit,
                width: 3 * unit,
                height: unit
            )
            let bar = UIView(frame: thisRect)
            bar.backgroundColor = colors[i]
            addSubview(bar)
            bar.fadeIn(delay: delay, duration: Double(i) * duration / Double(colors.count))
        }
    }

    private func addCompleteness(y: Int, delay: TimeInterval = 0, duration: TimeInterval) {
        var attrText = getStrokeText(i18n.completeness,
                                     minorTextColor,
                                     strokeWidth: strokeWidth / 2,
                                     font: MyFont.bold(ofSize: 2 * step))
        var label = addAttrText(x: 7, y: y, h: 4, text: attrText)
        label.textAlignment = .left
        label.slideIn(delay: delay, duration: duration)

        attrText = getStrokeText(gr.progress,
                                 .black,
                                 strokeWidth: strokeWidth / 2,
                                 strokColor: .white,
                                 font: MyFont.heavyDigit(ofSize: 7 * step))
        label = addAttrText(x: 1, y: y + 3, w: 20, h: 8, text: attrText)
        label.textAlignment = .right
        label.slideIn(delay: delay, duration: duration)

        attrText = getStrokeText("%",
                                 minorTextColor,
                                 strokeWidth: strokeWidth / 2,
                                 font: MyFont.bold(ofSize: 2 * step))
        label = addAttrText(x: 21, y: y + 7, h: 4, text: attrText)
        label.textAlignment = .left
        label.slideIn(delay: delay, duration: duration)
    }

    private func addRank(y: Int, delay: TimeInterval = 0, duration: TimeInterval) {
        var attrText = getStrokeText(i18n.rank,
                                     minorTextColor,
                                     strokeWidth: strokeWidth / 2,
                                     font: MyFont.bold(ofSize: 2 * step))
        var label = addAttrText(x: 26, y: y, h: 4, text: attrText)
        label.textAlignment = .left
        label.fadeIn(delay: delay, duration: duration)

        // rank
        let rank = context.gameMedal.usingDetailRank ? gr.detailRank : gr.rank
        attrText = getStrokeText(rank.rawValue,
                                 rank.color,
                                 strokeWidth: strokeWidth,
                                 font: MyFont.heavyDigit(ofSize: 8 * step))
        label = addAttrText(x: 22, y: y + 3, w: 15, h: 8, text: attrText)
        label.textAlignment = .right
        label.fadeIn(delay: delay, duration: duration)
    }

    private func addMedal(y: Int, delay: TimeInterval = 0, duration: TimeInterval) {
        // medal text
        guard let reward = gr.medalReward else { return }
        let medalText = "\(reward >= 0 ? "+" : "")\(reward)".padWidthTo(4)
        let attrText = getStrokeText("\(medalText)",
                                     .white,
                                     strokeWidth: strokeWidth,
                                     font: MyFont.heavyDigit(ofSize: 6 * step))

        let label = addAttrText(x: 35, y: y, w: 22, h: 6, text: attrText)
        label.sizeToFit()
        label.shrinkIn(delay: delay, duration: duration)
        label.fadeOut(delay: delay + duration + 2.4, duration: 0.2)
    }

    private func addActionButtons(y: Int) {
        let button = addButton(title: "", bgColor: .red) {
            SpeechEngine.shared.stopListeningAndSpeaking()
            launchNextGame()
        }

        let countDownSecs = isJustReachDailyGoal ? 9 : 6
        button.setIconImage(named: "baseline_play_arrow_black_48pt",
                            title: " \(i18n.nextGame) (\(countDownSecs)\(i18n.secs))",
                            tintColor: .white,
                            isIconOnLeft: true)
        button.titleLabel?.font = MyFont.regular(ofSize: step * 3.2)

        layout(3, y, 32, 8, button)
        playButton = button

        var leftSeconds = countDownSecs
        countDownTimer?.invalidate()
        countDownTimer = Timer.scheduledTimer(withTimeInterval: 1.00, repeats: true) { _ in
            leftSeconds -= 1
            playButton?.setTitle(" \(i18n.nextGame) (\(leftSeconds)\(i18n.secs))", for: .normal)
            guard leftSeconds > 0 else {
                countDownTimer?.invalidate()
                if !isSimulator {
                    launchNextGame()
                }
                return
            }
        }

        let backButton = addButton(title: "", bgColor: .lightGray) {
            countDownTimer?.invalidate()
            if let vc = Messenger.last?.presentingViewController {
                vc.dismiss(animated: false)
            } else {
                dismissTwoVC()
            }
        }

        backButton.setIconImage(named: "baseline_exit_to_app_black_48pt", title: "", tintColor: .white, isIconOnLeft: false)

        layout(37, y, 8, 8, backButton)
    }
}
