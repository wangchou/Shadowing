//
//  SettingPage.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 9/21/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

private let context = GameContext.shared

class SettingPage: UITableViewController {
    @IBOutlet weak var topBarView: TopBarView!
    @IBOutlet weak var autoSpeedSwitch: UISwitch!
    @IBOutlet weak var gameSpeedLabel: UILabel!
    @IBOutlet weak var gameSpeedSlider: UISlider!
    @IBOutlet weak var practiceSpeedLabel: UILabel!
    @IBOutlet weak var practiceSpeedSlider: UISlider!
    @IBOutlet weak var translationSwitch: UISwitch!
    @IBOutlet weak var guideVoiceSwitch: UISwitch!
    @IBOutlet weak var narratorSwitch: UISwitch!
    @IBOutlet weak var teacherTTSSegmentControl: UISegmentedControl!
    @IBOutlet weak var assistantTTSSegmentControl: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        topBarView.titleLabel.text = "設  定"
        topBarView.leftButton.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let setting = context.gameSetting
        autoSpeedSwitch.isOn = setting.isAutoSpeed
        if setting.isAutoSpeed {
            gameSpeedSlider.isEnabled = false
        }
        gameSpeedSlider.value = setting.preferredSpeed
        gameSpeedLabel.text = "\(String(format: "%.2f", setting.preferredSpeed*2))X"

        practiceSpeedSlider.value = setting.practiceSpeed
        practiceSpeedLabel.text = "\(String(format: "%.2f", setting.practiceSpeed*2))X"

        translationSwitch.isOn = setting.isUsingTranslation
        guideVoiceSwitch.isOn = setting.isUsingGuideVoice
        narratorSwitch.isOn = setting.isUsingNarrator

        teacherTTSSegmentControl.selectedSegmentIndex = getSegmentIndex(speaker: setting.teacher)
        assistantTTSSegmentControl.selectedSegmentIndex = getSegmentIndex(speaker: setting.assisant)
    }

    private func getSegmentIndex(speaker: ChatSpeaker) -> Int {
        switch speaker {
        case .hattori:
            return 3
        case .oren:
            return 2
        case .kyoko:
            return 0
        case .otoya:
            return 1
        default:
            return 0
        }
    }

    private func getChatSpeaker(segmentIndex: Int) -> ChatSpeaker {
        if segmentIndex == 0 { return .kyoko }
        if segmentIndex == 1 { return .otoya }
        if segmentIndex == 2 { return .oren }
        if segmentIndex == 3 { return .hattori }
        return .kyoko
    }

    private func showVoiceIsNotAvailableAlert() {
        let alert = UIAlertController(title: "你選的語音還未下載", message: "請於手機的「設定 > 一般 > 輔助使用 > 語音 > 聲音 > 日文」下載相關語音。", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            //UIApplication.shared.openURL(NSURL(string:UIApplication.openSettingsURLString)! as URL);
        }))
        //alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func autoSpeedSwitchValueChanged(_ sender: Any) {
        context.gameSetting.isAutoSpeed = autoSpeedSwitch.isOn
    }

    @IBAction func gameSpeedSilderValueChanged(_ sender: Any) {
        context.gameSetting.preferredSpeed = gameSpeedSlider.value
        viewWillAppear(false)
    }

    @IBAction func practiceSpeedSliderValueChanged(_ sender: Any) {
        context.gameSetting.practiceSpeed = practiceSpeedSlider.value
        viewWillAppear(false)
    }

    @IBAction func translationSwitchValueChanged(_ sender: Any) {
        context.gameSetting.isUsingTranslation = translationSwitch.isOn
    }

    @IBAction func guideVoiceSwitchValueChanged(_ sender: Any) {
        context.gameSetting.isUsingGuideVoice = guideVoiceSwitch.isOn
    }

    @IBAction func narratorSwitchValueChanged(_ sender: Any) {
        context.gameSetting.isUsingNarrator = narratorSwitch.isOn
    }

    @IBAction func teacherTTSSegmentControlValueChanged(_ sender: Any) {
        let speaker = getChatSpeaker(segmentIndex: teacherTTSSegmentControl.selectedSegmentIndex)
        let availableVoices = getAvailableVoiceID(language: "ja-JP")

        if availableVoices.contains(speaker.rawValue) {
            context.gameSetting.teacher = speaker
        } else {
            // show alert to download it
            teacherTTSSegmentControl.selectedSegmentIndex = getSegmentIndex(speaker: context.gameSetting.teacher)
            showVoiceIsNotAvailableAlert()
        }
    }

    @IBAction func assistantTTSSegmentControlValueChanged(_ sender: Any) {
        let speaker = getChatSpeaker(segmentIndex: teacherTTSSegmentControl.selectedSegmentIndex)
        let availableVoices = getAvailableVoiceID(language: "ja-JP")

        if availableVoices.contains(speaker.rawValue) {
            context.gameSetting.assisant = speaker
        } else {
            // show alert to download it
            assistantTTSSegmentControl.selectedSegmentIndex = getSegmentIndex(speaker: context.gameSetting.assisant)
            showVoiceIsNotAvailableAlert()
        }
    }

}
