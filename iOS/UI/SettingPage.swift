//
//  SettingPage.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 9/21/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import AVFoundation
import Foundation
import UIKit

private let context = GameContext.shared

private let dailyGoals: [Int] = [20, 50, 100, 200, 500]

class SettingPage: UITableViewController {
    @IBOutlet var topBarView: TopBarView!

    @IBOutlet var wantToSayLabel: UILabel!
    @IBOutlet var gameLangSegmentControl: UISegmentedControl!

    @IBOutlet var learningModeLabel: UILabel!
    @IBOutlet var learningModeSegmentControl: UISegmentedControl!
    @IBOutlet var gameSpeedSlider: UISlider!
    @IBOutlet var gameSpeedFastLabel: UILabel!
    @IBOutlet var translationLanguageLabel: UILabel!
    @IBOutlet var translationLanguageSegment: UISegmentedControl!

    @IBOutlet var showTranslationLabel: UILabel!
    @IBOutlet var showTranslationSwitch: UISwitch!

    @IBOutlet var showOriginalLabel: UILabel!
    @IBOutlet var showOriginalSwitch: UISwitch!

    @IBOutlet var narratorLabel: UILabel!
    @IBOutlet var narratorSwitch: UISwitch!
    @IBOutlet var monitoringLabel: UILabel!
    @IBOutlet var monitoringSwitch: UISwitch!
    @IBOutlet var monitoringVolumeSlider: UISlider!
    @IBOutlet var monitoringVolumeLabel: UILabel!

    @IBOutlet var practiceSpeedFastLabel: UILabel!
    @IBOutlet var practiceSpeedSlider: UISlider!
    @IBOutlet var teacherLabel: UILabel!
    @IBOutlet var teacherNameLabel: UILabel!
    @IBOutlet var assisantLabel: UILabel!
    @IBOutlet var assistantNameLabel: UILabel!
    @IBOutlet var translatorLabel: UILabel!
    @IBOutlet var translatorNameLabel: UILabel!

    @IBOutlet var dailyGoalSegmentedControl: UISegmentedControl!

    @IBOutlet var gotoIOSSettingButton: UIButton!
    @IBOutlet var gotoAppStoreButton: UIButton!
    @IBOutlet var gotoAcknowledgeButton: UIButton!

    var teacher: AVSpeechSynthesisVoice? {
        return AVSpeechSynthesisVoice(identifier: context.gameSetting.teacher) ??
            getDefaultVoice(language: gameLang.defaultCode)
    }

    var assistant: AVSpeechSynthesisVoice? {
        return AVSpeechSynthesisVoice(identifier: context.gameSetting.assistant) ??
            getDefaultVoice(language: gameLang.defaultCode)
    }

    var translator: AVSpeechSynthesisVoice? {
        return AVSpeechSynthesisVoice(identifier: context.gameSetting.translator) ?? getDefaultVoice(language: context.gameSetting.translationLang.defaultCode)
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
        let setting = context.gameSetting
        topBarView.titleLabel.text = i18n.setting

        gameLangSegmentControl.setTitle(i18n.english, forSegmentAt: 0)
        gameLangSegmentControl.setTitle(i18n.japanese, forSegmentAt: 1)

        translationLanguageSegment.setTitle("\(gameLang == .ja ? i18n.english : i18n.japanese)", forSegmentAt: 0)
        translationLanguageSegment.setTitle("\(i18n.chinese)", forSegmentAt: 1)

        gameSpeedSlider.isContinuous = false
        gameSpeedSlider.value = setting.gameSpeed
        gameSpeedFastLabel.text = String(format: "%.2fx", setting.gameSpeed * 2)

        narratorLabel.text = i18n.narratorLabel
        translationLanguageLabel.text = i18n.translationLanguageLabel
        showTranslationLabel.text = i18n.showTranslationLabel
        showOriginalLabel.text = i18n.showOriginalLabel
        monitoringLabel.text = i18n.monitoringLabel
        wantToSayLabel.text = i18n.wantToSayLabel

        teacherLabel.text = i18n.teacherLabel
        assisantLabel.text = i18n.assistantLabel
        translatorLabel.text = i18n.translatorLabel

        teacherNameLabel.text = teacher?.name ?? i18n.defaultVoice
        assistantNameLabel.text = assistant?.name ?? i18n.defaultVoice
        translatorNameLabel.text = translator?.name ?? i18n.defaultVoice

        gameLangSegmentControl.selectedSegmentIndex = gameLang == .ja ? 1 : 0
        translationLanguageSegment.selectedSegmentIndex = setting.translationLang == .zh ? 1: 0
        dailyGoalSegmentedControl.selectedSegmentIndex = dailyGoals.firstIndex(of: context.gameSetting.dailySentenceGoal) ?? 1

        gotoIOSSettingButton.setTitle(i18n.gotoIOSSettingButtonTitle, for: .normal)
        gotoAppStoreButton.setTitle(i18n.gotoAppStore, for: .normal)
        gotoAcknowledgeButton.setTitle(i18n.gotoAcknowledge, for: .normal)

        practiceSpeedSlider.isContinuous = false
        practiceSpeedSlider.value = setting.practiceSpeed
        practiceSpeedFastLabel.text = String(format: "%.2fx", setting.practiceSpeed * 2)

        for i in 0 ..< dailyGoals.count {
            dailyGoalSegmentedControl.setTitle("\(dailyGoals[i])\(i18n.sentenceUnit)", forSegmentAt: i)
        }

        narratorSwitch.isOn = setting.isSpeakInitialDescription
        monitoringSwitch.isOn = setting.isMointoring
        if setting.isMointoring {
            monitoringVolumeSlider.isEnabled = true
        } else {
            monitoringVolumeSlider.isEnabled = false
        }
        monitoringVolumeSlider.value = Float(setting.monitoringVolume)

        monitoringVolumeLabel.text = (setting.monitoringVolume > 0 ? "+":"") + String(format: "%ddb", setting.monitoringVolume)

        showTranslationSwitch.isOn = setting.isShowTranslation

        showTranslationSwitch.isEnabled = context.gameSetting.learningMode != .interpretation
        showTranslationLabel.textColor = context.gameSetting.learningMode != .interpretation ? .black : minorTextColor
        showOriginalSwitch.isEnabled = context.gameSetting.learningMode != .interpretation
        showOriginalLabel.textColor = context.gameSetting.learningMode != .interpretation ? .black : minorTextColor

        initLearningModeSegmentControl(label: learningModeLabel, control: learningModeSegmentControl)
    }

    // MARK: - IBActions sorted by UI
    @IBAction func gameLangSegmentControlValueChanged(_: Any) {
        RootContainerViewController.isShowSetting = true
        if gameLangSegmentControl.selectedSegmentIndex == 1 {
            changeGameLangTo(lang: .ja)
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

    // ---------------------------------------------------------------------------------

    @IBAction func learningModeSegmentControlValueChanged(_: Any) {
        actOnLearningModeSegmentControlValueChanged(control: learningModeSegmentControl)
        render()
    }

    @IBAction func translationLanguageSegmentedControlValueChanged(_: Any) {
        switch translationLanguageSegment.selectedSegmentIndex {
        case 0:
            context.gameSetting.translationLang = gameLang == .ja ? .en : .ja
        case 1:
            context.gameSetting.translationLang = .zh
        default:
            context.gameSetting.translationLang = .zh
        }
        saveGameSetting()
        render()
    }

    @IBAction func showTranslationSwitchValueChanged(_: Any) {
        context.gameSetting.isShowTranslation = showTranslationSwitch.isOn
        saveGameSetting()
    }

    @IBAction func showOriginalSwitchValueChanged(_ sender: Any) {
        context.gameSetting.isShowOriginal = showOriginalSwitch.isOn
        saveGameSetting()
    }

    @IBAction func narratorSwitchValueChanged(_: Any) {
        context.gameSetting.isSpeakInitialDescription = narratorSwitch.isOn
        saveGameSetting()
    }

    @IBAction func monitoringSwitchValueChanged(_: Any) {
        context.gameSetting.isMointoring = monitoringSwitch.isOn
        monitoringVolumeSlider.isEnabled = monitoringSwitch.isOn
        monitoringVolumeSlider.setNeedsDisplay()
        saveGameSetting()
    }

    @IBAction func monitoringVolumeSliderValueChanged(_ sender: Any) {
        let volume = Int(monitoringVolumeSlider.value)
        context.gameSetting.monitoringVolume = volume
        monitoringVolumeLabel.text = (volume > 0 ? "+":"") + String(format: "%ddb", volume)
        saveGameSetting()
    }

    // Game Speed ------------------------------------------------------------------

    @IBAction func gameSpeedSilderValueChanged(_: Any) {
        context.gameSetting.gameSpeed = gameSpeedSlider.value
        saveGameSetting()
        gameSpeedFastLabel.text = String(format: "%.2fx", gameSpeedSlider.value * 2)
        let speedText = String(format: "%.2f", context.gameSetting.gameSpeed * 2)
        _ = teacherSay("\(i18n.speedIs)\(speedText)です",
                       rate: context.gameSetting.gameSpeed,
                       ttsFixes: [])
    }

    @IBAction func practiceSpeedSliderValueChanged(_: Any) {
        context.gameSetting.practiceSpeed = practiceSpeedSlider.value
        saveGameSetting()
        practiceSpeedFastLabel.text = String(format: "%.2fx", practiceSpeedSlider.value * 2)
        let speedText = String(format: "%.2f", context.gameSetting.practiceSpeed * 2)
        _ = teacherSay("\(i18n.speedIs)\(speedText)です",
                       rate: context.gameSetting.practiceSpeed,
                       ttsFixes: [])
    }

    // Change Voices
    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 4 {
            if indexPath.row == 0 { // teacher voice
                VoiceSelectionPage.fromPage = self
                VoiceSelectionPage.selectingVoiceFor = .teacher
                VoiceSelectionPage.selectedVoice = teacher
            }
            if indexPath.row == 1 { // assistant voice
                VoiceSelectionPage.fromPage = self
                VoiceSelectionPage.selectingVoiceFor = .assisant
                VoiceSelectionPage.selectedVoice = assistant
            }
            launchVC(VoiceSelectionPage.id)
        }
        if indexPath.section == 5 && indexPath.row == 1 { // translator voice
            VoiceSelectionPage.fromPage = self
            VoiceSelectionPage.selectingVoiceFor = .translator
            VoiceSelectionPage.selectedVoice = translator
            launchVC(VoiceSelectionPage.id)
        }
    }

    // ----------------------- daily Goal -------------------------------------------
    @IBAction func dailyGoalSegmentedControlValueChanged(_: Any) {
        switch dailyGoalSegmentedControl.selectedSegmentIndex {
        case 0, 1, 2, 3, 4:
            context.gameSetting.dailySentenceGoal = dailyGoals[dailyGoalSegmentedControl.selectedSegmentIndex]
        default:
            context.gameSetting.dailySentenceGoal = 50
        }
        saveGameSetting()
    }

    @IBAction func goToSettingCenter(_: Any) {
        goToIOSSettingCenter()
    }

    @IBAction func gotoAppStore(_: Any) {
        if let url = URL(string: "https://itunes.apple.com/app/id1439727086") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }

    @IBAction func gotoAcknowledge(_ sender: Any) {
        InfoPage.content = i18n.acknowledgement
        launchVC(InfoPage.id)
    }

    // MARK: - Section Title

    override func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        let i18n = I18n.shared
        switch section {
        case 0:
            return " "
        case 1:
            return i18n.settingSectionGameSetting
        case 2:
            return i18n.settingSectionGameSpeed
        case 3:
            return i18n.settingSectionPracticeSpeed
        case 4:
            return i18n.textToSpeech
        case 5:
            return i18n.translation
        case 6:
            return i18n.dailyGoal
        case 7:
            return i18n.micAndSpeechPermission
        case 8:
            return i18n.yourFeedbackMakeAppBetter
        case 9:
            return ""

        default:
            return "Other Setting"
        }
    }
}

// MARK: - utility functions

func actOnLearningModeSegmentControlValueChanged(control: UISegmentedControl) {
    context.gameSetting.learningMode = LearningMode(rawValue: control.selectedSegmentIndex) ?? .meaningAndSpeaking

    switch context.gameSetting.learningMode {
    case .meaningAndSpeaking:
        context.gameSetting.isSpeakTranslation = true
        context.gameSetting.isSpeakOriginal = true
    case .speakingOnly, .echoMethod:
        context.gameSetting.isSpeakTranslation = false
        context.gameSetting.isSpeakOriginal = true
    case .interpretation:
        context.gameSetting.isSpeakTranslation = true
        context.gameSetting.isSpeakOriginal = false
        
        context.gameSetting.isShowTranslation = false
        context.gameSetting.isShowOriginal = true
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
