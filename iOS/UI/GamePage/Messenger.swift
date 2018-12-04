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
private let i18n = I18n.shared

enum LabelPosition {
    case left
    case center
    case right
}

// Prototype 8: messenger / line interface
class Messenger: UIViewController {
    var lastLabel: FuriganaLabel = FuriganaLabel()

    private var y: Int = 8
    private var previousY: Int = 0

    @IBOutlet weak var levelMeterView: UIView!
    @IBOutlet weak var levelMeterValueBar: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var sentenceCountLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    let spacing = 15

    override func viewDidLoad() {
        super.viewDidLoad()

        print("\nisEverReceiptProcessed:", isEverReceiptProcessed, "\n")
        // in case there is no network for VerifyReceipt when app launch.
        if !isEverReceiptProcessed {
            IAPHelper.shared.processReceipt()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        start()
        UIApplication.shared.isIdleTimerDisabled = true
        scrollView.delaysContentTouches = false
        levelMeterValueBar.roundBorder(borderWidth: 0, cornerRadius: 4.5, color: .clear)
        levelMeterValueBar.frame.size.height = 0
        levelMeterView.isUserInteractionEnabled = false
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        scrollView.removeAllSubviews()
        end()
        UIApplication.shared.isIdleTimerDisabled = false
    }

    func start() {
        startEventObserving(self)
        GameFlow.shared.start()
        sentenceCountLabel.text = "\(i18n.remaining)\(context.sentences.count)\(i18n.sentenceUnit)"
        speedLabel.text = String(format: "%.2f 倍速", context.teachingRate * 2)
        timeLabel.text = "00:00"
        context.startTime = getNow()

        scrollView.addTapGestureRecognizer(action: scrollViewTapped)
    }

    func end() {
        stopEventObserving(self)
    }

    func addLabel(_ text: NSAttributedString, pos: LabelPosition = .left) {
        let myLabel = FuriganaLabel()
        updateLabel(myLabel, text: text, pos: pos)
        scrollView.addSubview(myLabel)
        lastLabel = myLabel
    }

    func updateLabel(_ myLabel: FuriganaLabel, text: NSAttributedString, pos: LabelPosition) {
        let maxLabelWidth: Int = Int(screen.width*3/4)

        var height = 30
        var width = 10
        myLabel.attributedText = text

        // sizeToFit is not working here... T.T
        height = Int(myLabel.heightOfCoreText(attributed: text, width: CGFloat(maxLabelWidth)))
        width = Int(myLabel.widthOfCoreText(attributed: text, maxWidth: CGFloat(maxLabelWidth)))

        myLabel.frame = CGRect(x: 5, y: y, width: width, height: height)

        myLabel.roundBorder()

        switch pos {
        case .left:
            myLabel.backgroundColor = myWhite
        case .right:
            myLabel.frame.origin.x = CGFloat(Int(screen.width) - 5 - Int(myLabel.frame.width))
            if text.string == "..." {
                myLabel.backgroundColor = .gray
            } else if text.string == i18n.iCannotHearYou {
                myLabel.backgroundColor = myRed
            } else {
                myLabel.backgroundColor = myGreen
            }
        case .center:
            myLabel.backgroundColor = .clear
            myLabel.centerX(scrollView.frame)
            myLabel.alpha = 0.5
        }

        previousY = y
        y += Int(myLabel.frame.height) + spacing

        scrollView.scrollTo(y)
    }

    func updateLastLabelText(_ text: NSAttributedString, pos: LabelPosition = .left) {
        y = previousY
        updateLabel(lastLabel, text: text, pos: pos)
    }

    @objc func scrollViewTapped() {
        postCommand(.pause)
        launchStoryboard(self, "PauseOverlay", isOverCurrent: true)
    }
}
