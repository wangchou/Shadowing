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

extension UIView {
    func roundBorder(borderWidth: CGFloat = 1.5, cornerRadius: CGFloat = 15) {
        self.layer.borderWidth = borderWidth
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
    }

    func centerIn(_ boundRect: CGRect) {
        let xPadding = (boundRect.width - self.frame.width)/2
        let yPadding = (boundRect.height - self.frame.height)/2
        self.frame.origin.x = boundRect.origin.x + xPadding
        self.frame.origin.y = boundRect.origin.y + yPadding
    }
}

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
    let spacing = 8

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        start()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        end()
    }

    func start() {
        startEventObserving(self)
        game.play()
        sentenceCountLabel.text = "還有\(context.sentences.count)句"
        speedLabel.text = String(format: "%.2f 倍速", context.teachingRate * 2)
        timeLabel.text = "00:00"
        context.startTime = getNow()

        let scrollViewTap = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped))
        scrollViewTap.numberOfTapsRequired = 1
    }

    func end() {
        stopEventObserving(self)
        game.stop()
    }

    func addLabel(_ text: String, isLeft: Bool = true) {
        let myLabel = FuriganaLabel()
        updateLabel(myLabel, text: text, isLeft: isLeft)
        scrollView.addSubview(myLabel)
        lastLabel = myLabel
    }

    func updateLabel(_ myLabel: FuriganaLabel, text: String, isLeft: Bool = true) {
        let maxLabelWidth: Int = Int(screen.width*2/3)

        var height = 30
        var width = 10
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

        myLabel.roundBorder()

        if isLeft {
            myLabel.backgroundColor = myWhite
        } else {
            myLabel.frame.origin.x = CGFloat(Int(screen.width) - spacing - Int(myLabel.frame.width))
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

        scrollViewY(y)
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

    @objc func finishGame() {
        launchStoryboard(self, "ContentViewController")
    }

    @objc func restartGame() {
        y += Int(screen.height)
        scrollViewY(y)
        end()
        start()
    }

    func scrollViewY(_ y: Int) {
        scrollView.contentSize = CGSize(
            width: scrollView.frame.size.width,
            height: max(scrollView.frame.size.height, CGFloat(y))
        )
        scrollView.scrollRectToVisible(CGRect(x: 5, y: y-1, width: 1, height: 1), animated: true)
    }

    func addGameReport() {
        let report = UITextView()
        report.font = UIFont.systemFont(ofSize: 20)
        if let record = context.gameRecord {
            report.text = """
            達成率:\t\(record.progress)
            ---
            正解⭐️:\t\(record.perfectCount)
            すごい:\t\(record.greatCount)
            いいね:\t\(record.goodCount)
            違うよ:\t\(context.sentences.count - record.perfectCount - record.greatCount - record.goodCount)
            """
        }
        report.backgroundColor = .white
        report.frame = CGRect(x: 5, y: y, width: Int(screen.width - 10), height: 200)
        report.sizeToFit()
        report.frame.size.width = screen.width - 10

        let rankLabel = UILabel()
        rankLabel.text = context.gameRecord?.rank
        rankLabel.font = UIFont.systemFont(ofSize: 150)
        rankLabel.frame = CGRect(x: 150, y: y - 30, width: 200, height: 200)
        rankLabel.sizeToFit()
        rankLabel.centerIn(CGRect(
            x: 125,
            y: CGFloat(y),
            width: report.frame.width - 120,
            height: report.frame.height
        ))
        print(rankLabel.frame)
        y += Int(report.frame.height) + spacing
        report.roundBorder()

        scrollViewY(y)
        scrollView.addSubview(report)
        scrollView.addSubview(rankLabel)
    }

    func addButton(_ text: String, _ selector: Selector) {
        let button = UIButton()

        button.setTitle(text, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.titleEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        button.backgroundColor = .red
        button.frame = CGRect(x: 5, y: y, width: Int(screen.width - 10), height: 50)
        button.addTarget(self, action: selector, for: .touchUpInside)
        button.roundBorder()

        y += Int(button.frame.height) + spacing
        scrollViewY(y)

        scrollView.addSubview(button)
    }
}
