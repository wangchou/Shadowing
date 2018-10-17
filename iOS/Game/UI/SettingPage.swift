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
    @IBOutlet weak var gameSpeedCell: UITableViewCell!
    @IBOutlet weak var gameSpeedSlider: UISlider!
    @IBOutlet weak var gameSpeedSlowLabel: UILabel!
    @IBOutlet weak var gameSpeedFastLabel: UILabel!
    @IBOutlet weak var practiceSpeedSlider: UISlider!
    @IBOutlet weak var translationSwitch: UISwitch!
    @IBOutlet weak var guideVoiceSwitch: UISwitch!
    @IBOutlet weak var narratorSwitch: UISwitch!
    @IBOutlet weak var teacherTTSSegmentControl: UISegmentedControl!
    @IBOutlet weak var assistantTTSSegmentControl: UISegmentedControl!

    var testSentence: String {
        switch context.gameSetting.teacher {
        case .hattori, .oren:
            return "こんにちは、私の名前はSiriです。"
        case .kyoko:
            return "こんにちは、私の名前はKyokoです。"
        case .otoya:
            return "こんにちは、私の名前はOtoyaです。"
        default:
            return "今日はいい天気ですね。"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        topBarView.titleLabel.text = "設  定"
        topBarView.leftButton.isHidden = true
        gameSpeedSlider.addTapGestureRecognizer(action: nil)
        practiceSpeedSlider.addTapGestureRecognizer(action: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let setting = context.gameSetting
        autoSpeedSwitch.isOn = setting.isAutoSpeed
        if setting.isAutoSpeed {
            gameSpeedSlider.isEnabled = false
            gameSpeedSlowLabel.textColor = UIColor.lightGray
            gameSpeedFastLabel.textColor = UIColor.lightGray
        } else {
            gameSpeedSlider.isEnabled = true
            gameSpeedSlowLabel.textColor = UIColor.black
            gameSpeedFastLabel.textColor = UIColor.black
        }
        gameSpeedSlider.value = setting.preferredSpeed

        practiceSpeedSlider.value = setting.practiceSpeed

        translationSwitch.isOn = setting.isUsingTranslation
        guideVoiceSwitch.isOn = setting.isUsingGuideVoice
        narratorSwitch.isOn = setting.isUsingNarrator

        teacherTTSSegmentControl.selectedSegmentIndex = getSegmentIndex(speaker: setting.teacher)
        assistantTTSSegmentControl.selectedSegmentIndex = getSegmentIndex(speaker: setting.assisant)
    }

    private func getSegmentIndex(speaker: ChatSpeaker) -> Int {
        switch speaker {
        case .kyokoPremium:
            return 1
        case .otoyaPremium:
            return 2
        default:
            return 0
        }
    }

    private func getChatSpeaker(segmentIndex: Int) -> ChatSpeaker {
        if segmentIndex == 0 { return .system }
        if segmentIndex == 1 { return .kyokoPremium }
        if segmentIndex == 2 { return .otoyaPremium }
        return .system
    }

    private func showVoiceIsNotAvailableAlert() {
        let alert = UIAlertController(title: "你選的語音還未下載", message: "請於手機的「設定 > 一般 > 輔助使用 > 語音 > 聲音 > 日文」下載相關語音。", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "知道了", style: .default))
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func autoSpeedSwitchValueChanged(_ sender: Any) {
        context.gameSetting.isAutoSpeed = autoSpeedSwitch.isOn
        saveGameSetting()
        viewWillAppear(false)
    }

    @IBAction func gameSpeedSilderValueChanged(_ sender: Any) {
        context.gameSetting.preferredSpeed = gameSpeedSlider.value
        saveGameSetting()
    }

    @IBAction func practiceSpeedSliderValueChanged(_ sender: Any) {
        context.gameSetting.practiceSpeed = practiceSpeedSlider.value
        saveGameSetting()
    }

    @IBAction func translationSwitchValueChanged(_ sender: Any) {
        context.gameSetting.isUsingTranslation = translationSwitch.isOn
        saveGameSetting()
    }

    @IBAction func guideVoiceSwitchValueChanged(_ sender: Any) {
        context.gameSetting.isUsingGuideVoice = guideVoiceSwitch.isOn
        saveGameSetting()
    }

    @IBAction func narratorSwitchValueChanged(_ sender: Any) {
        context.gameSetting.isUsingNarrator = narratorSwitch.isOn
        saveGameSetting()
    }

    @IBAction func teacherTTSSegmentControlValueChanged(_ sender: Any) {
        let speaker = getChatSpeaker(segmentIndex: teacherTTSSegmentControl.selectedSegmentIndex)
        let availableVoices = getAvailableVoiceID(language: "ja-JP")

        if speaker == .system || availableVoices.contains(speaker.rawValue) {
            context.gameSetting.teacher = speaker
            _ = SpeechEngine.shared.speak(text: testSentence, speaker: speaker, rate: context.gameSetting.preferredSpeed)
        } else {
            // show alert to download it
            teacherTTSSegmentControl.selectedSegmentIndex = getSegmentIndex(speaker: context.gameSetting.teacher)
            showVoiceIsNotAvailableAlert()
        }
        saveGameSetting()
    }

    @IBAction func assistantTTSSegmentControlValueChanged(_ sender: Any) {
        let speaker = getChatSpeaker(segmentIndex: assistantTTSSegmentControl.selectedSegmentIndex)
        let availableVoices = getAvailableVoiceID(language: "ja-JP")

        if speaker == .system || availableVoices.contains(speaker.rawValue) {
            context.gameSetting.assisant = speaker
            _ = SpeechEngine.shared.speak(text: "正解、違います。", speaker: speaker, rate: fastRate)
        } else {
            // show alert to download it
            assistantTTSSegmentControl.selectedSegmentIndex = getSegmentIndex(speaker: context.gameSetting.assisant)
            showVoiceIsNotAvailableAlert()
        }
        saveGameSetting()
    }

}
