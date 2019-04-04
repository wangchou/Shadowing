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

        // info background
        let rect = addRect(x: 3, y: y, w: 42, h: 42, color: rgb(255, 255, 255).withAlphaComponent(0.03))

        addMedalProgressBar(y: y + 1, medal: medal)


        guard let gr = context.gameRecord else { return }

        // rank
        let rankText = context.gameMedal.usingDetailRank ? gr.detailRank : gr.rank
        var attrText = getStrokeText("Rank: \(rankText)", .white, strokeWidth: -2.5, font: MyFont.bold(ofSize: 8*fontSize))

        var label = addAttrText(x: 5, y: y+16, h: 8, text: attrText)
        label.textAlignment = .left

        // medal
        guard let reward = gr.medalReward else { return }
        let medalText = "\(reward >= 0 ? "+" : "")\(reward)"
        attrText = getStrokeText("🏅: \(medalText)", reward >= 0 ? myOrange : myRed, strokeWidth: -2.5, font: MyFont.bold(ofSize: 8*fontSize))

        label = addAttrText(x: 5, y: y+30, h: 8, text: attrText)
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

        layout(3, yMax - 18, 42, 12, button)
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
    }

}
