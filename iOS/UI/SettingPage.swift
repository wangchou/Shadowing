//
//  SettingPage.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 9/21/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

private let context = GameContext.shared
private let i18n = I18n.shared
private let dailyGoals: [Int] = [20, 50, 100, 200, 500]

class SettingPage: UITableViewController {
    @IBOutlet weak var topBarView: TopBarView!
    @IBOutlet weak var gameLangSegmentControl: UISegmentedControl!

    @IBOutlet weak var wantToSayLabel: UILabel!
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

    @IBOutlet weak var teacherLabel: UILabel!
    @IBOutlet weak var teacherNameLabel: UILabel!
    @IBOutlet weak var assisantLabel: UILabel!
    @IBOutlet weak var assistantNameLabel: UILabel!
    @IBOutlet weak var gotoIOSSettingButton: UIButton!
    @IBOutlet weak var dailyGoalSegmentedControl: UISegmentedControl!

    var testSentence: String {
        if let voice = AVSpeechSynthesisVoice(identifier: context.gameSetting.teacher) {
            if gameLang == .jp {
                return "こんにちは、私の名前は\(voice.name)です。"
            } else {
                return "Hello. My name is \(voice.name)."
            }
        }

        if gameLang == .jp {
            return "今日はいい天気ですね。"
        } else {
            return "It's nice to meet you."
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

        for i in 0..<dailyGoals.count {
            dailyGoalSegmentedControl.setTitle("\(dailyGoals[i])\(i18n.sentenceUnit)", forSegmentAt: i)
        }
        topBarView.titleLabel.text = i18n.setting
        autoSpeedLabel.text = i18n.autoSpeedLabel
        translationLabel.text = i18n.translationLabel
        guideVoiceLabel.text = i18n.guideVoiceLabel
        narratorLabel.text = i18n.narratorLabel
        monitoringLabel.text = i18n.monitoringLabel
        wantToSayLabel.text = i18n.wantToSayLabel

        teacherLabel.text = i18n.teacherLabel
        assisantLabel.text = i18n.assistantLabel

        if let teacher = AVSpeechSynthesisVoice(identifier: context.gameSetting.teacher) {
            teacherNameLabel.text = teacher.detailName
        }

        if let assisant = AVSpeechSynthesisVoice(identifier: context.gameSetting.assisant) {
            assistantNameLabel.text = assisant.detailName
        }

        gameLangSegmentControl.selectedSegmentIndex = gameLang == .jp ? 1 : 0
        dailyGoalSegmentedControl.selectedSegmentIndex = dailyGoals.firstIndex(of: context.gameSetting.dailySentenceGoal) ?? 1

        gotoIOSSettingButton.setTitle(i18n.gotoIOSSettingButtonTitle, for: .normal)

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
        rootViewController.reloadTableData()
    }

    @IBAction func dailyGoalSegmentedControlValueChanged(_ sender: Any) {
        switch dailyGoalSegmentedControl.selectedSegmentIndex {
        case 0, 1, 2, 3, 4:
            context.gameSetting.dailySentenceGoal = dailyGoals[dailyGoalSegmentedControl.selectedSegmentIndex]
        default:
            context.gameSetting.dailySentenceGoal = 50
        }
        saveGameSetting()
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let i18n = I18n.shared
        switch section {
        case 0:
            return ""
        case 1:
            return i18n.settingSectionGameSpeed
        case 2:
            return i18n.settingSectionPracticeSpeed
        case 3:
            return i18n.gameSetting
        case 4:
            return i18n.textToSpeech
        case 5:
            return i18n.dailyGoal
        case 6:
            return i18n.micAndSpeechPermission

        default:
            return "Other Setting"
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 3 {
            VoiceSelectionPage.voices = getAvailableVoice(prefix: gameLang.prefix)

            if indexPath.row == 0 { // teacher voice
                VoiceSelectionPage.fromSettingPage = self
                VoiceSelectionPage.selectingVoiceFor = .teacher
                VoiceSelectionPage.selectedVoice = AVSpeechSynthesisVoice(identifier: context.gameSetting.teacher)
            }
            if indexPath.row == 1 { // assistant voice
                VoiceSelectionPage.fromSettingPage = self
                VoiceSelectionPage.selectingVoiceFor = .assisant
                VoiceSelectionPage.selectedVoice = AVSpeechSynthesisVoice(identifier: context.gameSetting.assisant)
            }
            launchStoryboard(self, "VoiceSelectionViewController", isOverCurrent: true, animated: true)
        }
    }
}

extension AVSpeechSynthesisVoice {
    var detailName: String {
        let pureName = self.name.replace("（.*）", "")
        return "\(pureName) \(self.quality == .enhanced ? i18n.enhancedVoice : "")"
    }
}
