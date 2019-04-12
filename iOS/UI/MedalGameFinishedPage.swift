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
    static let vcName = "Medal Game Finished Page"

    var medalView: MedalGameFinishedPageView? {
        return view as? MedalGameFinishedPageView
    }
    override func loadView() {
        view = MedalGameFinishedPageView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        medalView?.viewWillAppear()
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

    func viewWillAppear() {
        removeAllSubviews()
        strokeWidth = Float(stepFloat * -1/2.0)
        backgroundColor = rgb(50, 50, 50)
        drawTextBackground(bgColor: rgb(50, 50, 50), textColor: textGold)
        let yMax = Int(screen.height / stepFloat)
        addInfo(y: (yMax - 12)/2 - 17)
        addActionButtons(y: (yMax - 12)/2 + 28)
    }

    func viewWillDisappear() {
        countDownTimer?.invalidate()
    }

    private func sayResult(gr: GameRecord) {
        let rankText = context.gameMedal.usingDetailRank ? gr.detailRank.rawValue : gr.rank.rawValue

        _ = teacherSay(
            i18n.getSpeakingStatus(percent: gr.progress, rank: rankText, reward: gr.medalReward),
            rate: fastRate)
    }

    private func addInfo(y: Int) {
        let medal = context.gameMedal

        guard let gr = context.gameRecord else { return }

        sayResult(gr: gr)

        drawTitleBlock(y: y, gr: gr, duration: 0.3)
        drawCompleteness(y: y+5, gr, duration: 0.3)
        drawRank(y: y+5, gr, delay: 0.4, duration: 0.3)
        drawMedal(y: y+18, gr: gr, medal: medal, delay: 0.8, duration: 0.3)
        addMedalProgressBar(y: y + 30,
                                 medalFrom: medal.count - (context.gameRecord?.medalReward ?? 0),
                                 medalTo: medal.count,
                                 delay: 1.4,
                                 duration: 0.1)
    }

    private func drawTitleBlock(y: Int, gr: GameRecord, delay: TimeInterval = 0, duration: TimeInterval) {
        // info background
        let rect = addRect(x: 3, y: y, w: 42, h: 42, color: rgb(255, 255, 255).withAlphaComponent(0.1))
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

    private func drawCompleteness(y: Int, _ gr: GameRecord, delay: TimeInterval = 0, duration: TimeInterval) {
        // completeness
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
            font: MyFont.heavyDigit(ofSize: 8 * stepFloat))
        label = addAttrText(x: 3, y: y+3, w: 20, h: 8, text: attrText)
        label.textAlignment = .right
        label.slideIn(delay: delay, duration: duration)

        attrText = getStrokeText("点",
                                 .white,
                                 strokeWidth: strokeWidth/2,
                                 font: MyFont.bold(ofSize: 3 * stepFloat))
        label = addAttrText(x: 23, y: y+7, h: 4, text: attrText)
        label.textAlignment = .left
        label.slideIn(delay: delay, duration: duration)
    }

    private func drawRank(y: Int, _ gr: GameRecord, delay: TimeInterval = 0, duration: TimeInterval) {
        // rankTitle
        var attrText = getStrokeText("判定",
                                 .white,
                                 strokeWidth: strokeWidth/2,
                                 font: MyFont.bold(ofSize: 3 * stepFloat))
        var label = addAttrText(x: 29, y: y, h: 4, text: attrText)
        label.textAlignment = .left
        label.slideIn(delay: delay, duration: duration)

        // rank
        let rank = context.gameMedal.usingDetailRank ? gr.detailRank : gr.rank
        attrText = getStrokeText(rank.rawValue,
                                 rank.color,
                                 strokeWidth: strokeWidth,
                                 font: MyFont.heavyDigit(ofSize: 8 * stepFloat))
        label = addAttrText(x: 26, y: y+3, w: 15, h: 8, text: attrText)
        label.textAlignment = .right
        label.slideIn(delay: delay, duration: duration)
    }

    private func drawMedal(y: Int, gr: GameRecord, medal: GameMedal, delay: TimeInterval = 0, duration: TimeInterval) {
        // medal
        let medalView = MedalView()
        layout(7, y, 10, 10, medalView)
        addSubview(medalView)
        medalView.viewWillAppear()
        medalView.shrinkIn(delay: delay, duration: duration)

        // medal text
        guard let reward = gr.medalReward else { return }
        let medalText = "\(reward >= 0 ? "+" : "")\(reward)"
        let attrText = getStrokeText("\(medalText)",
            .white,
            strokeWidth: strokeWidth,
            font: MyFont.heavyDigit(ofSize: 10 * stepFloat))

        let label = addAttrText(x: 19, y: y, w: 22, h: 10, text: attrText)
        label.textAlignment = .right

        label.shrinkIn(delay: delay, duration: duration)
    }

    private func addActionButtons(y: Int) {
        let button = createButton(title: "", bgColor: .red)
        let countDownSecs = 5
        button.setIconImage(named: "baseline_play_arrow_black_48pt", title: " 次の挑戦 (\(countDownSecs)秒)", tintColor: .white, isIconOnLeft: true)
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
//                dismissTwoVC(animated: false) {
//                    launchNextGame()
//                }
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
