//
//  MessengerBar.swift
//  今話したい
//
//  Created by Wangchou Lu on 2/24/31 H.
//  Copyright © 31 Heisei Lu, WangChou. All rights reserved.
//

import UIKit

private let context = GameContext.shared

@IBDesignable
class MessengerBar: UIView, ReloadableView {

    var isGameStopped: Bool = false {
        didSet {
            viewWillAppear()
        }
    }

    var levelLabel: UILabel!
    var topicTitleLabel: UILabel!
    var topicProgressLabel: UILabel!
    var progressBarBack: UIView!
    var progressBarFront: UIView!
    var pauseCountinueButton: UIButton!
    var skipNextButton: UIButton!

    private let circleWidth = 36
    private let barWidth = screen.width - 165

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
        // level icon
        levelLabel = UILabel()
        levelLabel.textAlignment = .center
        levelLabel.frame = CGRect(x: 10, y: 12, width: circleWidth, height: circleWidth)
        addSubview(levelLabel)

        // topic title label
        topicTitleLabel = UILabel()
        topicTitleLabel.font = MyFont.regular(ofSize: 16)
        topicTitleLabel.frame = CGRect(x: 60, y: 8, width: barWidth - 50, height: 30)
        addSubview(topicTitleLabel)

        // topic progress text
        topicProgressLabel = UILabel()
        topicProgressLabel.font = MyFont.regular(ofSize: 16)
        topicProgressLabel.frame = CGRect(x: barWidth, y: 8, width: 60, height: 30)
        topicProgressLabel.textAlignment = .right
        addSubview(topicProgressLabel)

        // progress bar
        progressBarBack = UIView()
        progressBarBack.backgroundColor = rgb(220, 220, 220)
        progressBarBack.frame = CGRect(x: 60, y: 38, width: barWidth, height: 7)
        progressBarBack.roundBorder(borderWidth: 0.5, cornerRadius: 3.5, color: .clear)
        addSubview(progressBarBack)

        progressBarFront = UIView()
        progressBarFront.backgroundColor = rgb(140, 140, 140)
        addSubview(progressBarFront)

        // pause/continue button
        pauseCountinueButton = UIButton()
        pauseCountinueButton.setIconImage(named: "baseline_pause_black_48pt", title: "", tintColor: .black, isIconOnLeft: false)
        pauseCountinueButton.frame = CGRect(x: screen.width - 96, y: 5, width: 48, height: 48)
        addSubview(pauseCountinueButton)

        // skipNextButton
        skipNextButton = UIButton()
        skipNextButton.setIconImage(named: "baseline_skip_next_black_48pt", title: "", tintColor: .black, isIconOnLeft: false)
        skipNextButton.frame = CGRect(x: screen.width - 50, y: 5, width: 48, height: 48)
        addSubview(skipNextButton)

        let separatedLine = UIView()
        separatedLine.backgroundColor = .darkGray
        separatedLine.frame = CGRect(x: 0, y: 0, width: screen.width, height: 0.5)
        addSubview(separatedLine)

        initData()
    }

    func initData() {
        topicProgressLabel.text = "0/\(context.sentences.count)"
        progressBarFront.frame = CGRect(x: 60, y: 38, width: 0, height: 7)
        progressBarFront.roundBorder(borderWidth: 0.5, cornerRadius: 3.5, color: .clear)
    }

    func viewWillAppear() {
        let key = context.dataSetKey

        let level: Level? = context.contentTab == .topics ?
            dataKeyToLevels[key] : context.infiniteChallengeLevel

        if let level = level {
            levelLabel.text = level.character
            levelLabel.textColor = level.color
            levelLabel.roundBorder(borderWidth: 1.5, cornerRadius: circleWidth.c/2, color: level.color)
            levelLabel.backgroundColor = level.color.withAlphaComponent(0.1)
        }

        topicTitleLabel.text = context.gameTitle
        topicProgressLabel.text = "\(context.sentenceIndex + 1)/\(context.sentences.count)"

        let progressPercent: CGFloat = context.sentences.isEmpty ? 0 :
            (context.sentenceIndex.c + 1)/context.sentences.count.c

        progressBarFront.frame = CGRect(x: 60, y: 38, width: (barWidth * progressPercent).f.i, height: 7)
        progressBarFront.roundBorder(borderWidth: 0.5, cornerRadius: 3.5, color: .clear)

        let imageName = isGameStopped ? "baseline_play_arrow_black_48pt" : "baseline_pause_black_48pt"
        pauseCountinueButton.setIconImage(named: imageName, title: "", tintColor: .black, isIconOnLeft: false)
    }
}
