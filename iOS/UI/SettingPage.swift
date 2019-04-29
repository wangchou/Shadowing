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
    @IBOutlet weak var learningModeLabel: UILabel!

    @IBOutlet weak var learningModeSegmentControl: UISegmentedControl!
    @IBOutlet weak var practiceSpeedFastLabel: UILabel!
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
    @IBOutlet weak var gotoAppStoreButton: UIButton!

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
        render()
    }

    func render() {
        gameLangSegmentControl.setTitle(i18n.english, forSegmentAt: 0)
        gameLangSegmentControl.setTitle(i18n.japanese, forSegmentAt: 1)

        for i in 0..<dailyGoals.count {
            dailyGoalSegmentedControl.setTitle("\(dailyGoals[i])\(i18n.sentenceUnit)", forSegmentAt: i)
        }
        topBarView.titleLabel.text = i18n.setting
        autoSpeedLabel.text = i18n.autoSpeedLabel
        narratorLabel.text = i18n.narratorLabel
        monitoringLabel.text = i18n.monitoringLabel
        wantToSayLabel.text = i18n.wantToSayLabel

        teacherLabel.text = i18n.teacherLabel
        assisantLabel.text = i18n.assistantLabel

        if let teacher = AVSpeechSynthesisVoice(identifier: context.gameSetting.teacher) {
            teacherNameLabel.text = teacher.name
        }

        if let assisant = AVSpeechSynthesisVoice(identifier: context.gameSetting.assisant) {
            assistantNameLabel.text = assisant.name
        }

        gameLangSegmentControl.selectedSegmentIndex = gameLang == .jp ? 1 : 0
        dailyGoalSegmentedControl.selectedSegmentIndex = dailyGoals.firstIndex(of: context.gameSetting.dailySentenceGoal) ?? 1

        gotoIOSSettingButton.setTitle(i18n.gotoIOSSettingButtonTitle, for: .normal)
        gotoAppStoreButton.setTitle(i18n.gotoAppStore, for: .normal)

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

        narratorSwitch.isOn = setting.isUsingNarrator
        monitoringSwitch.isOn = setting.isMointoring

        initLearningModeSegmentControl(label: learningModeLabel, control: learningModeSegmentControl)
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
        _ = teacherSay("\(i18n.speedIs)\(speedText)です", rate: context.gameSetting.preferredSpeed)
    }

    @IBAction func practiceSpeedSliderValueChanged(_ sender: Any) {
        context.gameSetting.practiceSpeed = practiceSpeedSlider.value
        saveGameSetting()
        practiceSpeedFastLabel.text = String(format: "%.2fx", practiceSpeedSlider.value * 2)
        let speedText = String(format: "%.2f", context.gameSetting.practiceSpeed * 2)
        _ = teacherSay("\(i18n.speedIs)\(speedText)です", rate: context.gameSetting.practiceSpeed)
    }

    // game option group
    @IBAction func learningModeSegmentControlValueChanged(_ sender: Any) {
        actOnLearningModeSegmentControlValueChanged(control: learningModeSegmentControl)
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

    @IBAction func gotoAppStore(_ sender: Any) {
        if let url = URL(string: "https://itunes.apple.com/app/id1439727086") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }

    @IBAction func gameLangSegmentControlValueChanged(_ sender: Any) {
        RootContainerViewController.isShowSetting = true
        if gameLangSegmentControl.selectedSegmentIndex == 1 {
            changeGameLangTo(lang: .jp)
        } else {
            changeGameLangTo(lang: .en)
        }

        render()

        if gameLang == .en {
            context.bottomTab = .infiniteChallenge
            rootViewController.showInfiniteChallengePage(idx: 1)
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
            return " "
        case 1:
            return " "
        case 2:
            return i18n.settingSectionGameSpeed
        case 3:
            return i18n.settingSectionPracticeSpeed
        case 4:
            return i18n.textToSpeech
        case 5:
            return i18n.dailyGoal
        case 6:
            return i18n.micAndSpeechPermission
        case 7:
            return i18n.yourFeedbackMakeAppBetter

        default:
            return "Other Setting"
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 4 {
            if indexPath.row == 0 { // teacher voice
                VoiceSelectionPage.fromPage = self
                VoiceSelectionPage.selectingVoiceFor = .teacher
                VoiceSelectionPage.selectedVoice = AVSpeechSynthesisVoice(identifier: context.gameSetting.teacher)
            }
            if indexPath.row == 1 { // assistant voice
                VoiceSelectionPage.fromPage = self
                VoiceSelectionPage.selectingVoiceFor = .assisant
                VoiceSelectionPage.selectedVoice = AVSpeechSynthesisVoice(identifier: context.gameSetting.assisant)
            }
            launchVC(VoiceSelectionPage.id)
        }
    }
}

func actOnLearningModeSegmentControlValueChanged(control: UISegmentedControl) {
    context.gameSetting.learningMode = LearningMode(rawValue: control.selectedSegmentIndex) ?? .meaningAndSpeaking

    switch context.gameSetting.learningMode {
    case .meaningAndSpeaking:
        context.gameSetting.isSpeakTranslation = true
        context.gameSetting.isUsingGuideVoice = true
    case .speakingOnly, .echoMethod:
        context.gameSetting.isSpeakTranslation = false
        context.gameSetting.isUsingGuideVoice = true
    case .interpretation:
        context.gameSetting.isSpeakTranslation = true
        context.gameSetting.isUsingGuideVoice = false
    }
    saveGameSetting()
}

func initLearningModeSegmentControl(label: UILabel, control: UISegmentedControl) {
    label.text = i18n.learningMode
    control.selectedSegmentIndex = context.gameSetting.learningMode.rawValue
    control.setTitle(i18n.meaningAndSpeaking, forSegmentAt: 0)
    control.setTitle(i18n.speakingOnly, forSegmentAt: 1)
    control.setTitle(i18n.echoMethod, forSegmentAt: 2)
    control.setTitle(i18n.interpretation, forSegmentAt: 3)
}
