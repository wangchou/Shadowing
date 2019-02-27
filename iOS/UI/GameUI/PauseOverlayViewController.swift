//
//  PauseOverlayViewController.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/13.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

private let context = GameContext.shared

class PauseOverlayViewController: UIViewController {
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var autoSpeedSwitch: UISwitch!
    @IBOutlet weak var ttsSpeedSlider: UISlider!
    @IBOutlet weak var fastLabel: UILabel!
    @IBOutlet weak var autoSpeedLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var learningModeLabel: UILabel!
    @IBOutlet weak var learningModeSegmentControl: UISegmentedControl!
    @IBOutlet weak var repeatOneSwitchButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        finishButton.layer.cornerRadius = 5

        view.addTapGestureRecognizer(action: viewTapped)

        // prevent events pass to back view
        ttsSpeedSlider.addTapGestureRecognizer(action: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let i18n = I18n.shared

        autoSpeedLabel.text = i18n.autoSpeedLabel
        speedLabel.text = i18n.speed

        ttsSpeedSlider.minimumValue = AVSpeechUtteranceMinimumSpeechRate
        ttsSpeedSlider.maximumValue = AVSpeechUtteranceMaximumSpeechRate * 0.75

        autoSpeedSwitch.isOn = context.gameSetting.isAutoSpeed
        ttsSpeedSlider.value = context.gameSetting.preferredSpeed
        fastLabel.text = String(format: "%.2fx", context.gameSetting.preferredSpeed*2)
        if context.gameSetting.isAutoSpeed {
            ttsSpeedSlider.isEnabled = false
            fastLabel.textColor = UIColor.lightGray
            speedLabel.textColor = UIColor.gray
        } else {
            ttsSpeedSlider.isEnabled = true
            fastLabel.textColor = UIColor.white
            speedLabel.textColor = UIColor.white
        }

        if context.contentTab == .topics {
            repeatOneSwitchButton.isHidden = false
        } else {
            repeatOneSwitchButton.isHidden = true
        }

        repeatOneSwitchButton.roundBorder(borderWidth: 0, cornerRadius: 25, color: .clear)

        if context.gameSetting.isRepeatOne {
            repeatOneSwitchButton.tintColor = UIColor.white
            repeatOneSwitchButton.backgroundColor = myOrange.withSaturation(1)
        } else {
            repeatOneSwitchButton.tintColor = UIColor.white.withBrightness(0.7)
            repeatOneSwitchButton.backgroundColor = UIColor.white.withBrightness(0.5)
        }

        initLearningModeSegmentControl(label: learningModeLabel, control: learningModeSegmentControl)
    }

    @IBAction func onLearningModeSegmentControlValueChanged(_ sender: Any) {
        actOnLearningModeSegmentControlValueChanged(control: learningModeSegmentControl)
    }
    @IBAction func onAutoSpeedSwitchTapped(_ sender: Any) {
        context.gameSetting.isAutoSpeed = autoSpeedSwitch.isOn
        saveGameSetting()
        viewWillAppear(false)
    }
    @IBAction func onTTSSpeedSliderValueChanged(_ sender: Any) {
        context.gameSetting.preferredSpeed = ttsSpeedSlider.value
        saveGameSetting()
        viewWillAppear(false)
    }

    @IBAction func repeatOneSwitchButtonClicked(_ sender: Any) {
        context.gameSetting.isRepeatOne = !context.gameSetting.isRepeatOne
        saveGameSetting()
        viewWillAppear(false)
    }
    @IBAction func finishButtonClicked(_ sender: Any) {
        dismissTwoVC(animated: true)
        postCommand(.forceStopGame)
    }

    @objc func viewTapped() {
        dismiss(animated: false, completion: nil)
        postCommand(.resume)
    }
}
