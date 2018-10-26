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

    @IBOutlet weak var autoSpeedLabel: UILabel!
    @IBOutlet weak var autoSpeedSwitch: UISwitch!
    @IBOutlet weak var gameSpeedCell: UITableViewCell!
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
        topBarView.titleLabel.text = "設  定"
        topBarView.leftButton.isHidden = true
        gameSpeedSlider.addTapGestureRecognizer(action: nil)
        practiceSpeedSlider.addTapGestureRecognizer(action: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let isJa = Locale.current.languageCode == "ja"
        autoSpeedLabel.text = isJa ? "自動速度" : "自動速度"
        translationLabel.text = isJa ? "中国語翻訳" : "中文翻譯"
        guideVoiceLabel.text = isJa ? "ガイド音声" : "日文引導朗讀"
        narratorLabel.text = isJa ? "ゲーム中国語説明" : "遊戲開始中文說明"
        gotoIOSSettingButton.setTitle(isJa ? "iPhone設定へ" : "前往iPhone設定中心", for: .normal)
        teacherTTSSegmentControl.setTitle(isJa ? "デフォルト" : "預定", forSegmentAt: 0)
        assistantTTSSegmentControl.setTitle(isJa ? "デフォルト" : "預定", forSegmentAt: 0)

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
        gameSpeedFastLabel.text = String(format: "%.2fx", setting.preferredSpeed*2)

        practiceSpeedSlider.value = setting.practiceSpeed
        practiceSpeedFastLabel.text = String(format: "%.2fx", setting.practiceSpeed*2)

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
        let isJa = Locale.current.languageCode == "ja"
        let title = isJa ? "選らんた声はまだダウンロードされていません" : "你選的語音還未下載"
        let message = isJa ? "iPhoneの「設定 > 一般 > アクセシビリティ > スピーチ > 声 > 日本語」で、ダウンロードしましょう。":"請於手機的「設定 > 一般 > 輔助使用 > 語音 > 聲音 > 日文」下載相關語音。"
        let okTitle = isJa ? "わかった" : "知道了"
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
        let speedText = String(format: "%.2f", context.gameSetting.preferredSpeed * 2)
        _ = teacherSay("速度は\(speedText)です", rate: context.gameSetting.preferredSpeed)
    }

    @IBAction func practiceSpeedSliderValueChanged(_ sender: Any) {
        context.gameSetting.practiceSpeed = practiceSpeedSlider.value
        saveGameSetting()
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
        let isJa = Locale.current.languageCode == "ja"
        switch section {
        case 0:
            return isJa ? "ゲーム時の読み上げ速度": "遊戲時的朗讀速度"
        case 1:
            return isJa ? "練習時の読み上げ速度": "練習時的朗讀速度"
        case 2:
            return isJa ? "ゲーム設定": "遊戲設定"
        case 3:
            return isJa ? "マイクと音声認識のアクセス権限": "麥克風與語音辨識權限"
        case 4:
            return isJa ? "日本語先生": "日文老師"
        case 5:
            return isJa ? "日本語アシスタント": "日文助理"
        default:
            return "Other Devices"
        }
    }
}
