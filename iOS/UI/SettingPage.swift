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
private let i18n = I18n.shared

class SettingPage: UITableViewController {
    @IBOutlet weak var topBarView: TopBarView!
    @IBOutlet weak var gameLangSegmentControl: UISegmentedControl!

    @IBOutlet weak var autoSpeedLabel: UILabel!
    @IBOutlet weak var autoSpeedSwitch: UISwitch!
    @IBOutlet weak var gameSpeedSlider: UISlider!
    @IBOutlet weak var gameSpeedFastLabel: UILabel!

    @IBOutlet weak var practiceSpeedSlider: UISlider!

    @IBOutlet weak var practiceSpeedFastLabel: UILabel!
    @IBOutlet weak var translationLabel: UILabel!
    @IBOutlet weak var translationSwitch: UISwitch!
    @IBOutlet weak var guideVoiceLabel: UILabel!
    @IBOutlet weak var guideVoiceSwitch: UISwitch!
    @IBOutlet weak var narratorLabel: UILabel!
    @IBOutlet weak var narratorSwitch: UISwitch!
    @IBOutlet weak var monitoringLabel: UILabel!
    @IBOutlet weak var monitoringSwitch: UISwitch!

    @IBOutlet weak var gotoIOSSettingButton: UIButton!
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

        topBarView.leftButton.isHidden = true
        gameSpeedSlider.addTapGestureRecognizer(action: nil)
        practiceSpeedSlider.addTapGestureRecognizer(action: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        gameLangSegmentControl.setTitle(i18n.english, forSegmentAt: 0)
        gameLangSegmentControl.setTitle(i18n.japanese, forSegmentAt: 1)
        topBarView.titleLabel.text = i18n.setting
        autoSpeedLabel.text = i18n.autoSpeedLabel
        translationLabel.text = i18n.translationLabel
        guideVoiceLabel.text = i18n.guideVoiceLabel
        narratorLabel.text = i18n.narratorLabel
        monitoringLabel.text = i18n.monitoringLabel

        gameLangSegmentControl.selectedSegmentIndex = gameLang == .jp ? 1 : 0

        gotoIOSSettingButton.setTitle(i18n.gotoIOSSettingButtonTitle, for: .normal)
        teacherTTSSegmentControl.setTitle(i18n.defaultText, forSegmentAt: 0)
        assistantTTSSegmentControl.setTitle(i18n.defaultText, forSegmentAt: 0)

        let setting = context.gameSetting
        autoSpeedSwitch.isOn = setting.isAutoSpeed

        if setting.isAutoSpeed {
            gameSpeedSlider.isEnabled = false
            gameSpeedFastLabel.textColor = UIColor.lightGray
        } else {
            gameSpeedSlider.isEnabled = true
            gameSpeedFastLabel.textColor = UIColor.black
        }
        gameSpeedSlider.value = setting.preferredSpeed
        gameSpeedFastLabel.text = String(format: "%.2fx", setting.preferredSpeed * 2)

        practiceSpeedSlider.value = setting.practiceSpeed
        practiceSpeedFastLabel.text = String(format: "%.2fx", setting.practiceSpeed * 2)

        translationSwitch.isOn = setting.isUsingTranslation
        guideVoiceSwitch.isOn = setting.isUsingGuideVoice
        narratorSwitch.isOn = setting.isUsingNarrator
        monitoringSwitch.isOn = setting.isMointoring

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
        let title = i18n.voiceNotAvailableTitle
        let message = i18n.voiceNotAvailableMessage
        let okTitle = i18n.voiceNotAvailableOKButton
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: okTitle, style: .default))
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
        gameSpeedFastLabel.text = String(format: "%.2fx", gameSpeedSlider.value * 2)
        let speedText = String(format: "%.2f", context.gameSetting.preferredSpeed * 2)
        _ = teacherSay("速度は\(speedText)です", rate: context.gameSetting.preferredSpeed)
    }

    @IBAction func practiceSpeedSliderValueChanged(_ sender: Any) {
        context.gameSetting.practiceSpeed = practiceSpeedSlider.value
        saveGameSetting()
        practiceSpeedFastLabel.text = String(format: "%.2fx", practiceSpeedSlider.value * 2)
        let speedText = String(format: "%.2f", context.gameSetting.practiceSpeed * 2)
        _ = teacherSay("速度は\(speedText)です", rate: context.gameSetting.practiceSpeed)
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
    @IBAction func monitoringSwitchValueChanged(_ sender: Any) {
        context.gameSetting.isMointoring = monitoringSwitch.isOn
        saveGameSetting()
    }
    @IBAction func goToSettingCenter(_ sender: Any) {
        goToIOSSettingCenter()
    }

    @IBAction func teacherTTSSegmentControlValueChanged(_ sender: Any) {
        let speaker = getChatSpeaker(segmentIndex: teacherTTSSegmentControl.selectedSegmentIndex)
        let availableVoices = getAvailableVoiceID(language: "ja-JP")

        if speaker == .system || availableVoices.contains(speaker.rawValue) {
            context.gameSetting.teacher = speaker
            _ = teacherSay(testSentence, rate: context.gameSetting.preferredSpeed)
        } else {
            // show alert to download it
            teacherTTSSegmentControl.selectedSegmentIndex = getSegmentIndex(speaker: context.gameSetting.teacher)
            showVoiceIsNotAvailableAlert()
        }
        saveGameSetting()
    }

    @IBAction func gameLangSegmentControlValueChanged(_ sender: Any) {
        if gameLangSegmentControl.selectedSegmentIndex == 1 {
            gameLang = .jp
        } else {
            gameLang = .en
        }

        saveGameLang()
        loadGameHistory()
        loadGameSetting()
        loadGameMiscData()
        viewWillAppear(false)

        if gameLang == .en {
            rootViewController.showInfiniteChallengePage(isShowSetting: true)
            context.contentTab = .infiniteChallenge
        }
    }

    @IBAction func assistantTTSSegmentControlValueChanged(_ sender: Any) {
        let speaker = getChatSpeaker(segmentIndex: assistantTTSSegmentControl.selectedSegmentIndex)
        let availableVoices = getAvailableVoiceID(language: "ja-JP")

        if speaker == .system || availableVoices.contains(speaker.rawValue) {
            context.gameSetting.assisant = speaker
            _ = assisantSay("正解、違います。")
        } else {
            // show alert to download it
            assistantTTSSegmentControl.selectedSegmentIndex = getSegmentIndex(speaker: context.gameSetting.assisant)
            showVoiceIsNotAvailableAlert()
        }
        saveGameSetting()
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let i18n = I18n.shared
        switch section {
        case 0:
            return i18n.settingTitle
        case 1:
            return i18n.settingSectionGameSpeed
        case 2:
            return i18n.settingSectionPracticeSpeed
        case 3:
            return i18n.gameSetting
        case 4:
            return i18n.micAndSpeechPermission
        case 5:
            return i18n.japaneseTeacher
        case 6:
            return i18n.japaneseAssistant
        default:
            return "Other Setting"
        }
    }
}
