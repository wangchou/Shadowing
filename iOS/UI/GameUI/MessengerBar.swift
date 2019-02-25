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
        let barWidth = screen.width - 120

        // level icon
        levelLabel = UILabel()
        levelLabel.textAlignment = .center
        levelLabel.frame = CGRect(x: 5, y: 5, width: 40, height: 40)
        addSubview(levelLabel)

        // topic title label
        topicTitleLabel = UILabel()
        topicTitleLabel.frame = CGRect(x: 60, y: 3, width: barWidth - 45, height: 30)
        addSubview(topicTitleLabel)

        // topic progress text
        topicProgressLabel = UILabel()
        topicProgressLabel.frame = CGRect(x: barWidth + 10, y: 3, width: 50, height: 30)
        topicProgressLabel.textAlignment = .right
        addSubview(topicProgressLabel)

        // progress bar
        progressBarBack = UIView()
        progressBarBack.backgroundColor = .lightGray
        progressBarBack.frame = CGRect(x: 60, y: 35, width: barWidth, height: 5)
        addSubview(progressBarBack)

        progressBarFront = UIView()
        progressBarFront.backgroundColor = .darkGray
        addSubview(progressBarFront)

        // pause/continue button
        pauseCountinueButton = UIButton()
        pauseCountinueButton.setIconImage(named: "baseline_pause_black_48pt", title: "", tintColor: .black, isIconOnLeft: false)
        pauseCountinueButton.frame = CGRect(x: screen.width - 55, y: 0, width: 50, height: 50)
        addSubview(pauseCountinueButton)
        viewWillAppear()
        topicProgressLabel.text = "0/\(context.sentences.count)"
        progressBarFront.frame = CGRect(x: 60, y: 35, width: 0, height: 5)
    }

    func viewWillAppear() {
        print("render")
        let key = context.dataSetKey
        let barWidth = screen.width - 120

        if let level = dataKeyToLevels[key] {
            levelLabel.text = level.character
            levelLabel.textColor = level.color
            levelLabel.roundBorder(borderWidth: 1.5, cornerRadius: 20, color: level.color)
            levelLabel.backgroundColor = level.color.withAlphaComponent(0.1)
        }

        topicTitleLabel.text = "\(getDataSetTitle(dataSetKey: key))"
        topicProgressLabel.text = "\(context.sentenceIndex + 1)/\(context.sentences.count)"

        let progressPercent: CGFloat = (context.sentenceIndex.c + 1)/context.sentences.count.c
        progressBarFront.frame = CGRect(x: 60, y: 35, width: (barWidth * progressPercent).f.i, height: 5)

        let imageName = isGameStopped ? "baseline_play_black_48pt" : "baseline_pause_black_48pt"
        pauseCountinueButton.setIconImage(named: imageName, title: "", tintColor: .black, isIconOnLeft: false)
    }
}
