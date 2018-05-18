//
//  P8ViewController.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/05.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

private let context = GameContext.shared

// Prototype 8: messenger / line interface
class Messenger: UIViewController {
    let game = SimpleGame.shared
    var lastLabel: FuriganaLabel = FuriganaLabel()

    private var y: Int = 8
    private var previousY: Int = 0

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var sentenceCountLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!

    func addLabel(_ text: String, isLeft: Bool = true) {
        let myLabel = FuriganaLabel()
        updateLabel(myLabel, text: text, isLeft: isLeft)
        scrollView.addSubview(myLabel)
        lastLabel = myLabel
    }

    func updateLabel(_ myLabel: FuriganaLabel, text: String, isLeft: Bool = true) {
        let maxLabelWidth: Int = Int(screenSize.width*2/3)
        let spacing: Int = 8
        var height: Int = 30
        var width: Int = 10
        if let tokenInfos = kanaTokenInfosCacheDictionary[text] {
            myLabel.attributedText = getFuriganaString(tokenInfos: tokenInfos)
        } else {
            myLabel.text = text
        }

        // initial
        guard let attributed = myLabel.attributedText else { print("orz..."); return }

        // sizeToFit is not working here... T.T
        height = Int(myLabel.heightOfCoreText(attributed: attributed, width: CGFloat(maxLabelWidth)))
        width = Int(myLabel.widthOfCoreText(attributed: attributed, maxWidth: CGFloat(maxLabelWidth)))

        myLabel.frame = CGRect(x: 5, y: y, width: width, height: height)

        myLabel.layer.borderWidth = 1.5
        myLabel.clipsToBounds = true
        myLabel.layer.cornerRadius = 15.0

        if isLeft {
            myLabel.backgroundColor = .white
        } else {
            myLabel.frame.origin.x = CGFloat(Int(screenSize.width) - spacing - Int(myLabel.frame.width))
            if text == "..." {
                myLabel.backgroundColor = .gray
            } else if text == "聽不清楚" {
                myLabel.backgroundColor = myRed
            } else {
                myLabel.backgroundColor = myGreen
            }
        }

        previousY = y
        y += Int(myLabel.frame.height) + spacing

        scrollView.contentSize = CGSize(
            width: scrollView.frame.size.width,
            height: max(scrollView.frame.size.height, CGFloat(y))
        )
        scrollView.scrollRectToVisible(CGRect(x: 5, y: y-1, width: 1, height: 1), animated: true)
    }

    func updateLastLabelText(_ text: String, isLeft: Bool = true) {
        y = previousY
        updateLabel(lastLabel, text: text, isLeft: isLeft)
    }

    @objc func scrollViewTapped() {
        print("scrollViewTapped")
        game.pause()
        launchStoryboard(self, "PauseOverlay", isOverCurrent: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        startEventObserving(self)
        game.play()
        sentenceCountLabel.text = "還有\(context.sentences.count)句"
        speedLabel.text = String(format: "%.2f 倍速", context.teachingRate * 2)
        timeLabel.text = "00:00"
        context.startTime = getNow()

        let scrollViewTap = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped))
        scrollViewTap.numberOfTapsRequired = 1
        scrollView.addGestureRecognizer(scrollViewTap)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopEventObserving(self)
        game.stop()
    }
}
