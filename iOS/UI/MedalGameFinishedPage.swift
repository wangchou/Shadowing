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
        sayResult()
        strokeWidth = Float(stepFloat * -1/2.0)
        drawTextBackground(bgColor: rgb(50, 50, 50), textColor: rgb(70, 70, 70))
        let yMax = Int(screen.height / stepFloat)
        addInfo(y: (yMax - 18)/2 - 18)
        addActionButtons()
    }

    func viewWillDisappear() {
        countDownTimer?.invalidate()
    }

    private func sayResult() {
        guard let record = context.gameRecord else { return }
        let statusText = i18n.getSpeakingStatus(
            percent: record.progress,
            rank: record.rank.rawValue,
            reward: record.medalReward)
        _ = teacherSay(statusText, rate: fastRate)
    }

    private func addInfo(y: Int) {
        let medal = context.gameMedal

        // info background
        let rect = addRect(x: 3, y: y, w: 42, h: 42, color: rgb(255, 255, 255).withAlphaComponent(0.1))
        rect.roundBorder(borderWidth: 0, cornerRadius: stepFloat * 3, color: .clear)

        enlargeIn(view: rect, duration: 3.0)

        guard let gr = context.gameRecord else { return }

        drawTitle(y: y, gr: gr)

        drawCompletenessAndRank(y: y, gr)

        drawMedal(y: y, gr: gr, medal: medal)

        addMedalProgressBar(y: y + 30, medal: medal,
                            textColor: .white, strokeColor: .black,
                            isSlideIn: true)
    }

    private func drawTitle(y: Int, gr: GameRecord) {
        let attrText = getStrokeText(gameLang == .jp ? "日本語" : "英語",
                                     rgb(220, 220, 220),
                                     strokeWidth: strokeWidth/2,
                                     font: MyFont.bold(ofSize: 10 * fontSize))
        let label = addAttrText(x: 12, y: y - 8, h: 12, text: attrText)
        label.centerX(frame)
        label.textAlignment = .center

        slideIn(view: label, duration: 0.3)
    }

    private func drawCompletenessAndRank(y: Int, _ gr: GameRecord) {
        // completeness
        var attrText = getStrokeText("完成率",
                                 .white,
                                 strokeWidth: strokeWidth/2,
                                 font: MyFont.bold(ofSize: 3 * fontSize))
        var label = addAttrText(x: 7, y: y+4, h: 4, text: attrText)
        label.textAlignment = .left
        slideIn(view: label, delay: 0.5, duration: 0.3)

        attrText = getStrokeText(gr.progress,
            .black,
            strokeWidth: strokeWidth/2,
            strokColor: .white,
            font: MyFont.heavyDigit(ofSize: 8 * fontSize))
        label = addAttrText(x: 3, y: y+7, w: 20, h: 8, text: attrText)
        label.textAlignment = .right
        slideIn(view: label, delay: 0.5, duration: 0.3)

        attrText = getStrokeText("%",
                                 .white,
                                 strokeWidth: strokeWidth/2,
                                 font: MyFont.bold(ofSize: 3 * fontSize))
        label = addAttrText(x: 23, y: y+11, h: 4, text: attrText)
        label.textAlignment = .left
        slideIn(view: label, delay: 0.5, duration: 0.3)

        // rankTitle
        attrText = getStrokeText("判定",
                                 .white,
                                 strokeWidth: strokeWidth/2,
                                 font: MyFont.bold(ofSize: 3 * fontSize))
        label = addAttrText(x: 29, y: y+4, h: 4, text: attrText)
        label.textAlignment = .left
        slideIn(view: label, delay: 0.5, duration: 0.3)

        // rank
        let rank = context.gameMedal.usingDetailRank ? gr.detailRank : gr.rank
        attrText = getStrokeText(rank.rawValue,
                                 rank.color,
                                 strokeWidth: strokeWidth,
                                 font: MyFont.heavyDigit(ofSize: 8 * fontSize))
        label = addAttrText(x: 26, y: y+7, w: 15, h: 8, text: attrText)
        label.textAlignment = .right
        slideIn(view: label, delay: 0.5, duration: 0.3)
    }

    private func drawMedal(y: Int, gr: GameRecord, medal: GameMedal) {
        // medal
        let medalView = MedalView()
        layout(7, y + 18, 8, 8, medalView)
        addSubview(medalView)
        medalView.viewWillAppear()
        slideIn(view: medalView, delay: 1.0, duration: 0.3)

        // medal text
        guard let reward = gr.medalReward else { return }
        let medalText = "\(reward >= 0 ? "+" : "")\(reward)"
        let attrText = getStrokeText("\(medalText)",
            reward >= 0 ? myGreen : myRed,
            strokeWidth: strokeWidth,
            font: MyFont.heavyDigit(ofSize: 8 * fontSize))

        let label = addAttrText(x: 21, y: y+18, w: 20, h: 8, text: attrText)
        label.textAlignment = .right

        slideIn(view: label, delay: 1.0, duration: 0.3)
    }


    private func addActionButtons() {
        let yMax = Int(screen.height / stepFloat)
        let button = createButton(title: "", bgColor: .red)
        let countDownSecs = 5
        button.setIconImage(named: "baseline_play_arrow_black_48pt", title: " 次の挑戦 (\(countDownSecs)秒)", tintColor: .white, isIconOnLeft: true)
        button.addTapGestureRecognizer {
            dismissTwoVC(animated: false) {
                launchNextGame()
            }
        }

        layout(3, yMax - 18, 28, 12, button)
        addSubview(button)
        playButton = button
/*
        var leftSeconds = countDownSecs
        countDownTimer?.invalidate()
        countDownTimer = Timer.scheduledTimer(withTimeInterval: 1.00, repeats: true) { _ in
            leftSeconds -= 1
            playButton?.setTitle(" 次の挑戦 (\(leftSeconds)秒)", for: .normal)
            guard leftSeconds > 0 else {
                countDownTimer?.invalidate()
                dismissTwoVC(animated: false) {
                    launchNextGame()
                }
                return
            }
        }
*/
        let backButton = createButton(title: "", bgColor: .lightGray)
        backButton.setIconImage(named: "baseline_exit_to_app_black_48pt", title: "", tintColor: .white, isIconOnLeft: false)

        backButton.addTapGestureRecognizer {
            countDownTimer?.invalidate()
            dismissTwoVC()
        }

        layout(33, yMax - 18, 12, 12, backButton)
        addSubview(backButton)
    }
}

func slideIn(view: UIView, delay: TimeInterval = 0, duration: TimeInterval) {
    view.frame.origin.x += screen.width
    view.alpha = 0.2

    let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeIn, animations: {
        view.transform = CGAffineTransform(translationX: -1 * screen.width, y: 0)
        view.alpha = 1
    })
    Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
        animator.startAnimation()
    }
}

func enlargeIn(view: UIView, delay: TimeInterval = 0, duration: TimeInterval) {
    view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
    view.alpha = 0.5

    let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeIn, animations: {
        view.transform = CGAffineTransform(scaleX: 1, y: 1)
        view.alpha = 1
    })
    Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
        animator.startAnimation()
    }
}


