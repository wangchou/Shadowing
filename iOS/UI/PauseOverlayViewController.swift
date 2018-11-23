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
    @IBOutlet weak var speakTranslationSwitch: UISwitch!
    @IBOutlet weak var autoSpeedSwitch: UISwitch!
    @IBOutlet weak var ttsSpeedSlider: UISlider!
    @IBOutlet weak var fastLabel: UILabel!
    @IBOutlet weak var autoSpeedLabel: UILabel!
    @IBOutlet weak var translationLabel: UILabel!
    @IBOutlet weak var guideVoiceLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var speakTranslationLabel: UILabel!
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
        let i18n = I18n.shared
        finishButton.setTitle(i18n.finishGameButtonTitle, for: .normal)
        resumeButton.setTitle(i18n.continueGameButtonTitle, for: .normal)
        autoSpeedLabel.text = i18n.autoSpeedLabel
        translationLabel.text = i18n.translationLabel
        speakTranslationLabel.text = i18n.speakTranslationLabel
        guideVoiceLabel.text = i18n.guideVoiceLabel
        speedLabel.text = i18n.speed

        ttsSpeedSlider.minimumValue = AVSpeechUtteranceMinimumSpeechRate
        ttsSpeedSlider.maximumValue = AVSpeechUtteranceMaximumSpeechRate * 0.75
        guideVoiceSwitch.isOn = context.gameSetting.isUsingGuideVoice
        tranlationSwitch.isOn = context.gameSetting.isShowTranslation
        speakTranslationSwitch.isOn = context.gameSetting.isSpeakTranslation
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
    }

    @IBAction func onGuideVoiceSwitchTapped(_ sender: Any) {
        context.gameSetting.isUsingGuideVoice = guideVoiceSwitch.isOn
        saveGameSetting()
        viewWillAppear(false)
    }
    @IBAction func onSpeakTranslationSwitchTapped(_ sender: Any) {
        context.gameSetting.isSpeakTranslation = speakTranslationSwitch.isOn
        saveGameSetting()
        viewWillAppear(false)
    }
    @IBAction func onTranslationSwitchTapped(_ sender: Any) {
        context.gameSetting.isShowTranslation = tranlationSwitch.isOn
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
        dismiss(animated: true)
        postCommand(.forceStopGame)
    }

    @objc func viewTapped() {
        dismiss(animated: true, completion: nil)
        postCommand(.resume)
    }

    @IBAction func resumeButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        postCommand(.resume)
    }
}
