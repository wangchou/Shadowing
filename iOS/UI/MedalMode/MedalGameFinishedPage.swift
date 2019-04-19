//
//  MedalGameFinishedPage.swift
//  今話したい
//
//  Created by Wangchou Lu on 4/4/31 H.
//  Copyright © 31 Heisei Lu, WangChou. All rights reserved.
//

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
        (view as? MedalGameFinishedPageView)?.viewWillAppear()
    }

    override func viewWillDisappear(_ animated: Bool) {
        countDownTimer?.invalidate()
    }
}

class MedalGameFinishedPageView: UIView, ReloadableView, GridLayout {
    var gridCount: Int = 48

    var axis: GridAxis = .horizontal

    var spacing: CGFloat = 0.0

    var strokeWidth: Float = 0

    var gr: GameRecord { return context.gameRecord! }

    var medal: GameMedal { return context.gameMedal }

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
    func viewWillAppear() {
        removeAllSubviews()
        strokeWidth = Float(stepFloat * -1/2.0)
        backgroundColor = rgb(50, 50, 50)
        addTextbackground(bgColor: rgb(50, 50, 50), textColor: textGold)
        let yMax = Int(screen.height / stepFloat)
        addInfo(y: (yMax - 12)/2 - 18)
        addActionButtons(y: (yMax - 12)/2 + 30)
    }

    func viewWillDisappear() {
        countDownTimer?.invalidate()
    }

    // MARK: - Say Result
    private func sayResult(gr: GameRecord) {
        let rankText = context.gameMedal.usingDetailRank ? gr.detailRank.rawValue : gr.rank.rawValue

        _ = teacherSay(
            i18n.getSpeakingStatus(percent: gr.progress, rank: rankText, reward: gr.medalReward),
            rate: fastRate)
    }

    // MARK: - AddInfo
    private func addInfo(y: Int) {
        let medal = context.gameMedal
        guard let gr = context.gameRecord else { return }

        sayResult(gr: gr)

        addTitleBlock(y: y, duration: 0.2)

        // 1 now
        addCompleteness(y: y+5, delay: 0, duration: 0.2)
        addRank(        y: y+5, delay: 0.3, duration: 0.2)
        addRecordDetail(y: y+7, delay: 0.3, duration: 0.6)

        // 2 changes
        addMedalProgressBar(x: 7, y: y + 18,
                            medalFrom: medal.count - (gr.medalReward ?? 0),
                            medalTo: medal.count,
                            animateInDelay: 0.6,
                            duration: 0.2,
                            animateProgressDelay: 1.1,
                            isLightSubText: true)
        addMedal(       y: y+13, delay: 0.6, duration: 0.2)

        // 3 long-term
        addDailyGoalView(x: 7, y: y+30,
                         isFullStatus: true,
                         delay: 1.5, duration: 0.2)
    }

    private func addTitleBlock(y: Int, delay: TimeInterval = 0, duration: TimeInterval) {
        // info background
        let rect = addRect(x: 3, y: y, w: 42, h: 46, color: rgb(0, 0, 0).withAlphaComponent(0.4))
        rect.roundBorder(borderWidth: 0, cornerRadius: stepFloat * 3, color: .clear)

        rect.enlargeIn(delay: delay, duration: duration)

        let attrText = getStrokeText(gameLang == .jp ? "日本語" : "英語",
                                     rgb(220, 220, 220),
                                     strokeWidth: strokeWidth/2,
                                     font: MyFont.bold(ofSize: 10 * stepFloat))
        let label = addAttrText(x: 12, y: y - 8, h: 12, text: attrText)
        label.centerX(frame)
        label.textAlignment = .center
        label.enlargeIn(delay: delay, duration: duration)
    }

    private func addRecordDetail(y: Int, delay: TimeInterval = 0, duration: TimeInterval = 0) {
        var colors: [UIColor] = []
        colors.append(contentsOf: Array.init(repeating: myGreen.withSaturation(1.0).withAlphaComponent(0.8), count: gr.perfectCount))
        colors.append(contentsOf: Array.init(repeating: myGreen.withAlphaComponent(0.5), count: gr.greatCount))
        colors.append(contentsOf: Array.init(repeating: myOrange.withAlphaComponent(0.8), count: gr.goodCount))
        colors.append(contentsOf: Array.init(repeating: myRed.withAlphaComponent(0.8), count: gr.missedCount))
        let rect = getFrame(40, y, 1, 8)

        let unit = Int(stepFloat/2).c

        for i in 0 ..< colors.count {
            let thisRect = CGRect(
                x: rect.origin.x - unit,
                y: rect.origin.y + rect.height - 2 * unit * i.c - unit,
                width: 3 * unit,
                height: unit
            )
            let bar = UIView(frame: thisRect)
            bar.backgroundColor = colors[i]
            addSubview(bar)
            bar.fadeIn(delay: delay, duration: Double(i) * duration/Double(colors.count))
        }
    }

    private func addCompleteness(y: Int, delay: TimeInterval = 0, duration: TimeInterval) {
        var attrText = getStrokeText("成績",
                                 .white,
                                 strokeWidth: strokeWidth/2,
                                 font: MyFont.bold(ofSize: 3 * stepFloat))
        var label = addAttrText(x: 7, y: y, h: 4, text: attrText)
        label.textAlignment = .left
        label.slideIn(delay: delay, duration: duration)

        attrText = getStrokeText(gr.progress,
            .black,
            strokeWidth: strokeWidth/2,
            strokColor: .white,
            font: MyFont.heavyDigit(ofSize: 7 * stepFloat))
        label = addAttrText(x: 1, y: y+3, w: 20, h: 8, text: attrText)
        label.textAlignment = .right
        label.slideIn(delay: delay, duration: duration)

        attrText = getStrokeText("点",
                                 .white,
                                 strokeWidth: strokeWidth/2,
                                 font: MyFont.bold(ofSize: 2 * stepFloat))
        label = addAttrText(x: 21, y: y+7, h: 4, text: attrText)
        label.textAlignment = .left
        label.slideIn(delay: delay, duration: duration)
    }

    private func addRank(y: Int, delay: TimeInterval = 0, duration: TimeInterval) {
        var attrText = getStrokeText("判定",
                                 .white,
                                 strokeWidth: strokeWidth/2,
                                 font: MyFont.bold(ofSize: 3 * stepFloat))
        var label = addAttrText(x: 26, y: y, h: 4, text: attrText)
        label.textAlignment = .left
        label.fadeIn(delay: delay, duration: duration)

        // rank
        let rank = context.gameMedal.usingDetailRank ? gr.detailRank : gr.rank
        attrText = getStrokeText(rank.rawValue,
                                 rank.color,
                                 strokeWidth: strokeWidth,
                                 font: MyFont.heavyDigit(ofSize: 8 * stepFloat))
        label = addAttrText(x: 22, y: y+3, w: 15, h: 8, text: attrText)
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
            font: MyFont.heavyDigit(ofSize: 6 * stepFloat))

        let label = addAttrText(x: 35, y: y, w: 22, h: 6, text: attrText)
        label.sizeToFit()
        label.shrinkIn(delay: delay, duration: duration)
        label.fadeOut(delay: delay + duration + 2.4, duration: 0.2)
    }

    private func addActionButtons(y: Int) {
        let button = createButton(title: "", bgColor: .red)
        let countDownSecs = 5
        button.setIconImage(named: "baseline_play_arrow_black_48pt",
                            title: " 次の挑戦 (\(countDownSecs)秒)",
                            tintColor: .white,
                            isIconOnLeft: true)
        button.titleLabel?.font = MyFont.regular(ofSize: stepFloat * 3.2 )
        button.addTapGestureRecognizer {
            dismissTwoVC(animated: false) {
                launchNextGame()
            }
        }

        layout(3, y, 32, 8, button)
        addSubview(button)
        playButton = button

        var leftSeconds = countDownSecs
        countDownTimer?.invalidate()
        countDownTimer = Timer.scheduledTimer(withTimeInterval: 1.00, repeats: true) { _ in
            leftSeconds -= 1
            playButton?.setTitle(" 次の挑戦 (\(leftSeconds)秒)", for: .normal)
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

        let backButton = createButton(title: "", bgColor: .lightGray)
        backButton.setIconImage(named: "baseline_exit_to_app_black_48pt", title: "", tintColor: .white, isIconOnLeft: false)

        backButton.addTapGestureRecognizer {
            countDownTimer?.invalidate()
            dismissTwoVC()
        }

        layout(37, y, 8, 8, backButton)
        addSubview(backButton)
    }
}
