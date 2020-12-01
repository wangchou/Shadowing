//
//  VoiceSelectionViewController.swift
//  今話したい
//
//  Created by Wangchou Lu on 11/14/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import AVFoundation
import UIKit

private let context = GameContext.shared

enum SelectingVoiceFor {
    case teacher, assisant, translator
}

class VoiceSelectionPage: UIViewController {
    static let id = "VoiceSelectionViewController"
    static var fromPage: UIViewController?
    static var selectingVoiceFor: SelectingVoiceFor = .teacher
    static var selectedVoice: AVSpeechSynthesisVoice?

    var isSpeedChanged: Bool = false
    var isWithPracticeSpeedSection: Bool {
        return (VoiceSelectionPage.fromPage as? MedalCorrectionPage) != nil
    }

    @IBOutlet var downloadVoiceTextView: UITextView!
    var selectingVoiceFor: SelectingVoiceFor {
        return VoiceSelectionPage.selectingVoiceFor
    }

    var voices: [AVSpeechSynthesisVoice] {
        switch selectingVoiceFor {
        case .teacher, .assisant:
            return getAvailableVoice(prefix: gameLang.prefix)
        case .translator:
            return getAvailableVoice(prefix: context.gameSetting.translationLang.prefix)
        }
    }

    var voicesGrouped: [[AVSpeechSynthesisVoice]] {
        var voiceDictByLanguage: [String: [AVSpeechSynthesisVoice]] = [:]
        var isZh = false
        voices.forEach { v in
            if v.language.contains("zh") { isZh = true }
            if voiceDictByLanguage[v.language] != nil {
                voiceDictByLanguage[v.language]?.append(v)
            } else {
                voiceDictByLanguage[v.language] = [v]
            }
        }
        var voicesGrouped: [[AVSpeechSynthesisVoice]] = []
        let keys = !isZh ? voiceDictByLanguage.keys.sorted() :
                           voiceDictByLanguage.keys.sorted().reversed() // Taiwan Top
        for key in keys {
            voicesGrouped.append(
                voiceDictByLanguage[key]!.sorted {
                    $0.name < $1.name
                }
            )
        }
        return voicesGrouped
    }

    var selectedVoice: AVSpeechSynthesisVoice? {
        set {
            VoiceSelectionPage.selectedVoice = newValue
        }
        get {
            return VoiceSelectionPage.selectedVoice
        }
    }

    var testSentence: String {
        if let voice = selectedVoice {
            let jaHello = "こんにちは、私の名前は\(voice.name)です。"
                .replacingOccurrences(of: "Otoya", with: " オトヤ ")
                .replacingOccurrences(of: "Kyoko", with: " 京子 ")
            let enHello = "Hello. My name is \(voice.name)."
            let zhHello = "你好，我的名字是\(voice.name)"
            switch selectingVoiceFor {
            case .teacher:
                return gameLang == .ja ? jaHello : enHello
            case .assisant:
                return "\(Score(value: 100).text), \(Score(value: 80).text), \(Score(value: 60).text), \(Score(value: 0).text) "
            case .translator:
                if voice.language.contains("ja") {
                    return jaHello
                } else if voice.language.contains("en") {
                    return enHello
                } else {
                    return zhHello
                }
            }
        }

        print("Error: testSentence... should not reach here")

        if gameLang == .ja {
            return "今日はいい天気ですね。"
        } else {
            return "It's nice to meet you."
        }
    }

    @IBOutlet var cancelButton: UIButton!

    @IBOutlet var doneButton: UIButton!
    @IBOutlet var titleLabel: UILabel!

    @IBOutlet var tableView: UITableView!
    @IBOutlet var practiceSpeedLabel: UILabel!
    @IBOutlet var practiceSpeedSlider: UISlider!
    @IBOutlet var practiceSpeedValueLabel: UILabel!

    var originPracticeSpeed: Float = 0
    var originVoice: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        doneButton.isEnabled = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        switch selectingVoiceFor {
        case .teacher:
            titleLabel.text = i18n.teacherLabel
            originVoice = context.gameSetting.teacher
        case .assisant:
            titleLabel.text = i18n.assistantLabel
            originVoice = context.gameSetting.assistant
        case .translator:
            titleLabel.text = i18n.translatorLabel
            originVoice = context.gameSetting.translator
        }
        doneButton.setTitle(i18n.done, for: .normal)
        cancelButton.setTitle(i18n.cancel, for: .normal)
        downloadVoiceTextView.text = i18n.voiceNotAvailableMessage
        downloadVoiceTextView.font = MyFont.regular(ofSize: 12)
        if !isWithPracticeSpeedSection {
            tableView.tableHeaderView = nil
        } else {
            practiceSpeedSlider.isContinuous = false
            practiceSpeedSlider.value = context.gameSetting.practiceSpeed
            practiceSpeedValueLabel.text = String(format: "%.2fx", context.gameSetting.practiceSpeed * 2)
            practiceSpeedLabel.text = i18n.settingSectionPracticeSpeed
        }
        originPracticeSpeed = context.gameSetting.practiceSpeed
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SpeechEngine.shared.stopListeningAndSpeaking()
    }

    @IBAction func onCancelButtonClicked(_: Any) {
        context.gameSetting.practiceSpeed = originPracticeSpeed
        switch selectingVoiceFor {
        case .teacher:
            context.gameSetting.teacher = originVoice
        case .assisant:
            context.gameSetting.assistant = originVoice
        case .translator:
            context.gameSetting.translator = originVoice
        }
        saveGameSetting()
        dismiss(animated: true)
    }

    @IBAction func practiceSpeedSliderValueChanged(_: Any) {
        context.gameSetting.practiceSpeed = practiceSpeedSlider.value
        practiceSpeedValueLabel.text = String(format: "%.2fx", practiceSpeedSlider.value * 2)
        let speedText = String(format: "%.2f", context.gameSetting.practiceSpeed * 2)
        _ = teacherSay("\(i18n.speedIs)\(speedText)です",
                       rate: context.gameSetting.practiceSpeed,
                       ttsFixes: [])
        doneButton.isEnabled = true
        isSpeedChanged = true
    }

    @IBAction func onDoneButtonClicked(_: Any) {
        dismiss(animated: true)
        if let settingPage = VoiceSelectionPage.fromPage as? SettingPage {
            settingPage.render()
        }
        if let correctionPage = VoiceSelectionPage.fromPage as? MedalCorrectionPage {
            correctionPage.medalCorrectionPageView?.renderTopView()
        }
        saveGameSetting()
    }
}

extension VoiceSelectionPage: UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return voicesGrouped.count
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return voicesGrouped[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VoiceTableCell", for: indexPath)
        guard let voiceCell = cell as? VoiceTableCell else { print("voiceCell convert error"); return cell }
        let voice = voicesGrouped[indexPath.section][indexPath.row]
        voiceCell.nameLabel.text = voice.name

        if voice.identifier == selectedVoice?.identifier {
            voiceCell.accessoryType = .checkmark
        } else {
            voiceCell.accessoryType = .none
        }
        return voiceCell
    }

    func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        return i18n.getLangDescription(langAndRegion: voicesGrouped[section][0].language)
    }
}

extension VoiceSelectionPage: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedVoice = voicesGrouped[indexPath.section][indexPath.row]

        switch selectingVoiceFor {
        case .teacher:
            context.gameSetting.teacher = selectedVoice?.identifier ?? "unknown"
        case .assisant:
            context.gameSetting.assistant = selectedVoice?.identifier ?? "unknown"
        case .translator:
            context.gameSetting.translator = selectedVoice?.identifier ?? "unknown"
        }

        if originVoice == selectedVoice?.identifier {
            doneButton.isEnabled = false || isSpeedChanged
        } else {
            doneButton.isEnabled = true
        }

        let speed = isWithPracticeSpeedSection ?
                        context.gameSetting.practiceSpeed :
                        AVSpeechUtteranceDefaultSpeechRate
        _ = ttsSay(
            testSentence,
            speaker: selectedVoice?.identifier ?? "unknown",
            rate: speed,
            lang: selectingVoiceFor == .translator ? context.gameSetting.translationLang : gameLang
        )
        tableView.reloadData()
    }
}
