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
        drawTextBackground(bgColor: rgb(50, 50, 50), textColor: rgb(70, 70, 70))
        let yMax = Int(screen.height / stepFloat)
        addInfo(y: (yMax - 18)/2 - 21)
        addActionButtons()
    }

    func viewWillDisappear() {
        countDownTimer?.invalidate()
    }

    private func addInfo(y: Int) {
        let medal = context.gameMedal
        let strokeWidth = Float(stepFloat * -1/2.0)

        // info background
        let rect = addRect(x: 3, y: y, w: 42, h: 42, color: rgb(255, 255, 255).withAlphaComponent(0.1))
        rect.roundBorder(borderWidth: 0, cornerRadius: stepFloat * 3, color: .clear)

        addMedalProgressBar(y: y + 30, medal: medal, textColor: .white, strokeColor: .black)

        guard let gr = context.gameRecord else { return }

        // rankTitle
        var attrText = getStrokeText("判定",
                                     rgb(220, 220, 220),
                                     strokeWidth: strokeWidth/2,
                                     font: MyFont.bold(ofSize: 8 * fontSize))
        var label = addAttrText(x: 6, y: y+3, h: 8, text: attrText)
        label.textAlignment = .left

        // rank
        let rank = context.gameMedal.usingDetailRank ? gr.detailRank : gr.rank
        attrText = getStrokeText(rank.rawValue,
                                 rank.color,
                                 strokeWidth: strokeWidth,
                                 font: MyFont.heavyDigit(ofSize: 10 * fontSize))
        label = addAttrText(x: 27, y: y+3, w: 15, h: 8, text: attrText)
        label.textAlignment = .right

        // medal
        guard let reward = gr.medalReward else { return }
        let medalText = "\(reward >= 0 ? "+" : "")\(reward)"
        attrText = getStrokeText("\(medalText)",
                                 reward >= 0 ? myGreen : myRed,
                                 strokeWidth: strokeWidth,
                                 font: MyFont.heavyDigit(ofSize: 10 * fontSize))

        label = addAttrText(x: 22, y: y+17, w: 20, h: 8, text: attrText)
        label.textAlignment = .right

        let medalView = MedalView()
        layout(6, y + 16, 10, 10, medalView)
        addSubview(medalView)
        medalView.viewWillAppear()
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
