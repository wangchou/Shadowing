//
//  TopicButtonAreaView.swift
//  今話したい
//
//  Created by Wangchou Lu on 2/26/31 H.
//  Copyright © 31 Heisei Lu, WangChou. All rights reserved.
//

import UIKit

private let context = GameContext.shared

let backGray = rgb(248, 248, 252)

@IBDesignable
class TopicButtonAreaView: UIView, GridLayout, ReloadableView {

    // GridLayout
    var gridCount: Int = 48

    var axis: GridAxis = .horizontal

    var spacing: CGFloat = 0

    var playButton: UIButton!
    var repeatOneSwitchButton: UIButton!
    var topViewSwitchButton: UIButton!

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

    private func sharedInit() {
        frame.size.width = screen.width
        let separateLine = UIView()
        separateLine.backgroundColor = rgb(220, 220, 220)
        separateLine.frame = CGRect(x: 0, y: 0, width: screen.width, height: 0.5)
        addSubview(separateLine)

        playButton = UIButton()
        playButton.addTarget(self, action: #selector(onPlayButtonClicked), for: .touchUpInside)
        playButton.roundBorder(borderWidth: 0, cornerRadius: 5, color: .clear)
        playButton.setIconImage(named: "baseline_play_arrow_black_48pt", title: "", tintColor: .black, isIconOnLeft: false)
        playButton.tintColor = myRed.withSaturation(1)

        layout(18, 2, 12, 8, playButton)
        addSubview(playButton)

        topViewSwitchButton = UIButton()
        topViewSwitchButton.addTarget(self, action: #selector(onSwitchButtonClicked), for: .touchUpInside)
        topViewSwitchButton.roundBorder(borderWidth: 0, cornerRadius: 5, color: .clear)
        topViewSwitchButton.setIconImage(named: "baseline_style_black_36pt", title: "", tintColor: .black, isIconOnLeft: false)
        topViewSwitchButton.tintColor = myGreen.withSaturation(1)
        layout(3, 2, 12, 8, topViewSwitchButton)
        addSubview(topViewSwitchButton)

        repeatOneSwitchButton = UIButton()
        repeatOneSwitchButton.addTarget(self, action: #selector(onRepeatOneButtonClicked), for: .touchUpInside)
        layout(35, 2, 8, 8, repeatOneSwitchButton)

        repeatOneSwitchButton.roundBorder(borderWidth: 0, cornerRadius: repeatOneSwitchButton.frame.width/2, color: .clear)
        repeatOneSwitchButton.setIconImage(named: "baseline_repeat_one_black_24pt", title: "", tintColor: .white, isIconOnLeft: false)
        addSubview(repeatOneSwitchButton)

        addSeparationLine(y: 12)
        viewWillAppear()
    }

    func viewWillAppear() {
        if context.gameSetting.isRepeatOne {
            repeatOneSwitchButton.tintColor = UIColor.white
            repeatOneSwitchButton.backgroundColor = myOrange.withSaturation(1)
        } else {
            repeatOneSwitchButton.tintColor = myOrange.withSaturation(1)
            repeatOneSwitchButton.backgroundColor = backGray
        }
    }

    func addSeparationLine(y: Int) {
        let line = UIView()
        line.backgroundColor = rgb(220, 220, 220)
        layout(0, y, 48, 1, line)
        line.frame.size.height = 0.5
        addSubview(line)
    }

    @objc func onPlayButtonClicked() {
        context.gameMode = .topicMode
        if isUnderDailySentenceLimit() {
            launchVC(Messenger.id)
        }
    }

    @objc func onSwitchButtonClicked() {
        switchToNextTopViewMode()
        rootViewController.rerenderTopView()
    }

    @objc func onRepeatOneButtonClicked() {
        context.gameSetting.isRepeatOne = !context.gameSetting.isRepeatOne
        saveGameSetting()
        viewWillAppear()
    }
}
