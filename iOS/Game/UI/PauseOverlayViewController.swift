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
    @IBOutlet weak var resumeButton: UIButton!
    @IBOutlet weak var guideVoiceSwitch: UISwitch!
    @IBOutlet weak var tranlationSwitch: UISwitch!
    @IBOutlet weak var autoSpeedSwitch: UISwitch!
    @IBOutlet weak var ttsSpeedSlider: UISlider!
    @IBOutlet weak var slowLabel: UILabel!
    @IBOutlet weak var fastLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        finishButton.layer.cornerRadius = 10
        resumeButton.layer.cornerRadius = 10

        view.addTapGestureRecognizer(action: viewTapped)

        // prevent events pass to back view
        ttsSpeedSlider.addTapGestureRecognizer(action: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ttsSpeedSlider.minimumValue = AVSpeechUtteranceMinimumSpeechRate
        ttsSpeedSlider.maximumValue = AVSpeechUtteranceMaximumSpeechRate
        guideVoiceSwitch.isOn = context.gameSetting.isUsingGuideVoice
        tranlationSwitch.isOn = context.gameSetting.isUsingTranslation
        autoSpeedSwitch.isOn = context.gameSetting.isAutoSpeed
        ttsSpeedSlider.value = context.gameSetting.preferredSpeed
        if context.gameSetting.isAutoSpeed {
            ttsSpeedSlider.isEnabled = false
            fastLabel.textColor = UIColor.lightGray
            slowLabel.textColor = UIColor.gray
        } else {
            ttsSpeedSlider.isEnabled = true
            fastLabel.textColor = UIColor.white
            slowLabel.textColor = UIColor.white
        }
    }

    @IBAction func onGuideVoiceSwitchTapped(_ sender: Any) {
        context.gameSetting.isUsingGuideVoice = guideVoiceSwitch.isOn
        saveGameSetting()
        viewWillAppear(false)
    }
    @IBAction func onTranslationSwitchTapped(_ sender: Any) {
        context.gameSetting.isUsingTranslation = tranlationSwitch.isOn
        saveGameSetting()
        viewWillAppear(false)
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

    @IBAction func finishButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        postEvent(.forceStopGame)
    }

    @objc func viewTapped() {
        dismiss(animated: true, completion: nil)
        postEvent(.resume)
    }

    @IBAction func resumeButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        postEvent(.resume)
    }
}
