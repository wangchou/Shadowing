//
//  P8ViewController.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/05.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import AVFoundation
import Promises
import UIKit

private let context = GameContext.shared

enum LabelPosition {
    case left
    case center
    case right
}

// Prototype 8: messenger / line interface
class Messenger: UIViewController {
    static let id = "MessengerGame"
    static var lastInstance: Messenger?
    var lastLabel = FuriganaLabel()

    private var y: Int = 8
    private var previousY: Int = 0

    @IBOutlet var levelMeterView: UIView!
    @IBOutlet var levelMeterValueBar: UIView!
    @IBOutlet var levelMeterHeightConstraint: NSLayoutConstraint!
    @IBOutlet var scrollView: UIScrollView!

    // pauseOverlay
    @IBOutlet var overlayView: UIView!
    @IBOutlet var speedSlider: UISlider!
    @IBOutlet var speedLabel: UILabel!
    @IBOutlet var showOptionLabel: UILabel!
    @IBOutlet var showOptionSegment: UISegmentedControl!

    @IBOutlet var learningModeLabel: UILabel!
    @IBOutlet var learningModeSegmentControl: UISegmentedControl!
    @IBOutlet var repeatOneSwitchButton: UIButton!
    @IBOutlet var exitButton: UIButton!

    @IBOutlet weak var speedNameLabel: UILabel!

    @IBOutlet var messengerBar: MessengerBar!

    let spacing = 15

    override func viewDidLoad() {
        super.viewDidLoad()

        // in case there is no network for VerifyReceipt when app launch.
        if !isEverReceiptProcessed {
            IAPHelper.shared.processReceipt()
        }

        // UI Settings
        overlayView.isHidden = true
        exitButton.layer.cornerRadius = 5
        levelMeterView.isUserInteractionEnabled = false
        levelMeterValueBar.roundBorder(radius: 4.5)
        scrollView.delaysContentTouches = false

        // actions
        speedSlider.addTapGestureRecognizer(action: nil)
        overlayView.addTapGestureRecognizer(action: continueGame)
        scrollView.addTapGestureRecognizer(action: pauseContinueGame)
        messengerBar.addTapGestureRecognizer(action: pauseContinueGame)
        messengerBar.pauseCountinueButton.addTarget(self, action: #selector(pauseContinueGame), for: .touchUpInside)
        messengerBar.skipNextButton.addTarget(self, action: #selector(skipNext), for: .touchUpInside)
        Messenger.lastInstance = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        start()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if context.gameMode == .medalMode {
            DispatchQueue.main.async {
                MedalPage.shared?.medalPageView?.render()
            }
        } else if context.gameMode == .infiniteChallengeMode {
            DispatchQueue.main.async {
                InfiniteChallengePage.lastDisplayed?.infoView?.render()
            }
        } else if context.gameMode == .topicMode {
            DispatchQueue.main.async {
                TopicDetailPage.lastDisplayed?.render()
            }
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        scrollView.removeAllSubviews()
        view.removeAllSubviews()
        stopEventObserving(self)
        SpeechEngine.shared.monitoringOff()
        UIApplication.shared.isIdleTimerDisabled = false
        SpeechEngine.shared.stop()
        Messenger.lastInstance = nil
    }

    // call this before dismiss game finished page
    func prepareForRestart() {
        stopEventObserving(self)
        scrollView.removeAllSubviews()
        scrollView.contentSize = scrollView.frame.size
        scrollView.scrollTo(0)
        previousY = 0
        y = 8
    }

    func start() {
        startEventObserving(self)
        GameFlow.shared = GameFlow()
        GameFlow.shared.start()
        UIApplication.shared.isIdleTimerDisabled = true
        messengerBar.render()
        renderOverlayView()
        if context.gameSetting.isMointoring {
            SpeechEngine.shared.monitoringOn()
        }
        levelMeterValueBar.frame.size.height = 0
    }

    func renderOverlayView() {
        let i18n = I18n.shared

        speedSlider.minimumValue = AVSpeechUtteranceMinimumSpeechRate
        speedSlider.maximumValue = AVSpeechUtteranceMaximumSpeechRate * 0.75

        showOptionSegment.setTitle(i18n.translated, forSegmentAt: 0)
        showOptionSegment.setTitle(i18n.original, forSegmentAt: 1)

        showOptionLabel.text = i18n.showOptionLabel
        showOptionSegment.selectedSegmentIndex = context.gameSetting.isShowTranslation ? 0 : 1
        showOptionSegment.isEnabled = context.gameSetting.learningMode != .interpretation
        showOptionLabel.textColor = context.gameSetting.learningMode != .interpretation ? .white : UIColor.white.withAlphaComponent(0.3)

        speedSlider.value = context.gameSetting.gameSpeed
        speedNameLabel.text = i18n.speed
        speedLabel.text = String(format: "%.2fx", context.gameSetting.gameSpeed * 2)

        if context.gameMode == .topicMode {
            repeatOneSwitchButton.isHidden = false
        } else {
            repeatOneSwitchButton.isHidden = true
        }

        repeatOneSwitchButton.roundBorder(radius: 25)

        if context.gameSetting.isRepeatOne {
            repeatOneSwitchButton.tintColor = UIColor.white
            repeatOneSwitchButton.backgroundColor = myOrange.withSaturation(1)
        } else {
            repeatOneSwitchButton.tintColor = UIColor.white.withBrightness(0.7)
            repeatOneSwitchButton.backgroundColor = UIColor.white.withBrightness(0.5)
        }

        initLearningModeSegmentControl(label: learningModeLabel, control: learningModeSegmentControl)

        if #available(iOS 13, *) {
            learningModeSegmentControl.backgroundColor = .lightGray
        }
    }

    func prescrolling(_ text: NSAttributedString, pos _: LabelPosition = .left) {
        let originalPreviousY = previousY
        let originalY = y
        let originalLastLabel = lastLabel

        addLabel(text, isAddSubview: false)

        // center echo text
        if context.gameSetting.learningMode == .echoMethod {
            let echoText = rubyAttrStr(i18n.listenToEcho)
            addLabel(echoText, pos: .center, isAddSubview: false)
        }

        // right text
        let dotText = rubyAttrStr("...")
        addLabel(dotText, pos: .right, isAddSubview: false)
        previousY = originalPreviousY
        y = originalY
        lastLabel = originalLastLabel
    }

    func addLabel(_ text: NSAttributedString, pos: LabelPosition = .left, isAddSubview: Bool = true) {
        let myLabel = FuriganaLabel()
        updateLabel(myLabel, text: text, pos: pos)
        if isAddSubview {
            scrollView.addSubview(myLabel)
        }
        lastLabel = myLabel
    }

    func updateLabel(_ myLabel: FuriganaLabel, text: NSAttributedString, pos: LabelPosition) {
        let maxLabelWidth = Int(screen.width * 3 / 4)

        var height = 30
        var width = 10
        myLabel.attributedText = text

        // sizeToFit is not working here... T.T
        height = Int(myLabel.heightOfCoreText(attributed: text, width: CGFloat(maxLabelWidth)))
        width = Int(myLabel.widthOfCoreText(attributed: text, maxWidth: CGFloat(maxLabelWidth)))

        myLabel.frame = CGRect(x: 5, y: y, width: width, height: height)

        myLabel.roundBorder(width: 1.5, radius: 15, color: rgb(50, 50, 50).withAlphaComponent(0.85))

        switch pos {
        case .left:
            myLabel.backgroundColor = myWhite
        case .right:
            myLabel.frame.origin.x = CGFloat(Int(screen.width) - 5 - Int(myLabel.frame.width))
            if text.string == "..." {
                myLabel.backgroundColor = UIColor.gray.withBrightness(0.7)
            } else if text.string == i18n.iCannotHearYou {
                myLabel.backgroundColor = myRed.withBrightness(1)
            } else {
                myLabel.backgroundColor = myGreen.withBrightness(0.85)
            }
        case .center:
            myLabel.backgroundColor = .clear
            myLabel.centerX(scrollView.frame)
            myLabel.alpha = 0.5
        }

        previousY = y
        y += Int(myLabel.frame.height) + spacing

        if pos == .right {
            scrollView.scrollTo(y)
        }
    }

    func updateLastLabelText(_ text: NSAttributedString, pos: LabelPosition = .left) {
        y = previousY
        updateLabel(lastLabel, text: text, pos: pos)
    }

    @objc func pauseContinueGame() {
        if messengerBar.isGameStopped {
            continueGame()
        } else {
            messengerBar.isGameStopped = true
            messengerBar.render()
            postCommand(.pause)
            overlayView.isHidden = false
        }
    }

    @objc func skipNext() {
        // TODO: check next level is accessible for infiniteChallenge Mode
        postCommand(.forceStopGame)
        prepareForRestart()
        if context.gameMode == .topicMode {
            context.loadNextChallenge()
        }
        start()
    }

    @objc func continueGame() {
        overlayView.isHidden = true
        postCommand(.resume)
    }

    // pauseOverlay actions
    @IBAction func speedChanged(_: Any) {
        context.gameSetting.gameSpeed = speedSlider.value
        saveGameSetting()
        renderOverlayView()
    }

    @IBAction func showOptionSegmentValueChanged(_: Any) {
        context.gameSetting.isShowTranslation = showOptionSegment.selectedSegmentIndex == 0
        saveGameSetting()
        renderOverlayView()
    }

    @IBAction func learningModeSegmentControlValueChanged(_: Any) {
        actOnLearningModeSegmentControlValueChanged(control: learningModeSegmentControl)
        renderOverlayView()
    }

    @IBAction func repeatOneSwitchButtonClicked(_: Any) {
        context.gameSetting.isRepeatOne = !context.gameSetting.isRepeatOne
        saveGameSetting()
        renderOverlayView()
    }

    @IBAction func exitButtonClicked(_: Any) {
        dismiss(animated: true, completion: nil)
        postCommand(.forceStopGame)
    }
}
