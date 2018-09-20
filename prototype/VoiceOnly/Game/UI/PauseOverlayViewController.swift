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
    @IBOutlet weak var tranlationSwitch: UISwitch!
    @IBOutlet weak var autoSpeedSwitch: UISwitch!
    @IBOutlet weak var ttsSpeedLabel: UILabel!
    @IBOutlet weak var ttsSpeedSlider: UISlider!
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
        tranlationSwitch.isOn = context.gameSetting.isUsingTranslation
        autoSpeedSwitch.isOn = context.gameSetting.isAutoSpeed
        ttsSpeedLabel.text = "\(String(format: "%.2f", context.gameSetting.preferredSpeed*2))X"
        ttsSpeedSlider.value = context.gameSetting.preferredSpeed
        ttsSpeedSlider.isEnabled = !context.gameSetting.isAutoSpeed
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
        ShadowingFlow.shared.stop()
        if context.gameFlowMode == .shadowing {
            launchStoryboard(self, "ShadowingListPage")
        } else {
            dismiss(animated: false) {
                UIApplication.getPresentedViewController()?.dismiss(animated: true, completion: nil)
            }
        }
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
