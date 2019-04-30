//
//  VoiceSelectionViewController.swift
//  今話したい
//
//  Created by Wangchou Lu on 11/14/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import UIKit
import AVFoundation

private let context = GameContext.shared

enum SelectingVoiceFor {
    case teacher, assisant
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

    @IBOutlet weak var downloadVoiceTextView: UITextView!
    var selectingVoiceFor: SelectingVoiceFor {
        return VoiceSelectionPage.selectingVoiceFor
    }
    var voices: [AVSpeechSynthesisVoice] {
        return getAvailableVoice(prefix: gameLang.prefix)
    }
    var voicesGrouped: [[AVSpeechSynthesisVoice]] {
        var voiceDictByLanguage: [String: [AVSpeechSynthesisVoice]] = [:]
        voices.forEach { v in
            if voiceDictByLanguage[v.language] != nil {
                voiceDictByLanguage[v.language]?.append(v)
            } else {
                voiceDictByLanguage[v.language] = [v]
            }
        }
        var voicesGrouped: [[AVSpeechSynthesisVoice]] = []
        for key in voiceDictByLanguage.keys.sorted() {
            voicesGrouped.append(
                voiceDictByLanguage[key]!.sorted {
                    return $0.name < $1.name
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
            if selectingVoiceFor == .assisant {
                return "\(Score(value: 100).text), \(Score(value: 80).text), \(Score(value: 60).text), \(Score(value: 0).text) "
            }

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

    @IBOutlet weak var cancelButton: UIButton!

    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var practiceSpeedLabel: UILabel!
    @IBOutlet weak var practiceSpeedSlider: UISlider!
    @IBOutlet weak var practiceSpeedValueLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        doneButton.isEnabled = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        titleLabel.text = selectingVoiceFor == .teacher ? i18n.teacherLabel : i18n.assistantLabel
        doneButton.setTitle(i18n.done, for: .normal)
        cancelButton.setTitle(i18n.cancel, for: .normal)
        downloadVoiceTextView.text = i18n.voiceNotAvailableMessage
        if !isWithPracticeSpeedSection {
            tableView.tableHeaderView = nil
        } else {
            practiceSpeedSlider.value = context.gameSetting.practiceSpeed
            practiceSpeedValueLabel.text = String(format: "%.2fx", context.gameSetting.practiceSpeed * 2)
            practiceSpeedLabel.text = i18n.settingSectionPracticeSpeed
        }
    }

    @IBAction func onCancelButtonClicked(_ sender: Any) {
        self.dismiss(animated: true)
    }

    @IBAction func practiceSpeedSliderValueChanged(_ sender: Any) {
        context.gameSetting.practiceSpeed = practiceSpeedSlider.value
        saveGameSetting()
        practiceSpeedValueLabel.text = String(format: "%.2fx", practiceSpeedSlider.value * 2)
        let speedText = String(format: "%.2f", context.gameSetting.practiceSpeed * 2)
        _ = teacherSay("\(i18n.speedIs)\(speedText)です", rate: context.gameSetting.practiceSpeed)
        doneButton.isEnabled = true
        isSpeedChanged = true
    }

    @IBAction func onDoneButtonClicked(_ sender: Any) {
        self.dismiss(animated: true)
        if selectingVoiceFor == .teacher {
            context.gameSetting.teacher = selectedVoice?.identifier ?? "unknown"
        } else {
            context.gameSetting.assisant = selectedVoice?.identifier ?? "unknown"
        }
        if let settingPage = VoiceSelectionPage.fromPage as? SettingPage {
            settingPage.viewWillAppear(false)
        }
        if let correctionPage = VoiceSelectionPage.fromPage as? MedalCorrectionPage {
            correctionPage.medalCorrectionPageView?.renderTopView()
        }
        saveGameSetting()
    }
}

extension VoiceSelectionPage: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return voicesGrouped.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return voicesGrouped[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VoiceTableCell", for: indexPath)
        guard let voiceCell = cell as? VoiceTableCell else { print("voiceCell convert error"); return cell }
        let voice = voicesGrouped[indexPath.section][indexPath.row]
        voiceCell.nameLabel.text = voice.name
        if voice == selectedVoice {
            voiceCell.accessoryType = .checkmark
        } else {
            voiceCell.accessoryType = .none
        }
        return voiceCell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return i18n.getLangDescription(langAndRegion: voicesGrouped[section][0].language)
    }
}

extension VoiceSelectionPage: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedVoice = voicesGrouped[indexPath.section][indexPath.row]
        let originalVoiceId = selectingVoiceFor == .teacher ?
            context.gameSetting.teacher : context.gameSetting.assisant
        if originalVoiceId == selectedVoice?.identifier {
            doneButton.isEnabled = false || isSpeedChanged
        } else {
            doneButton.isEnabled = true
        }

        let speed = isWithPracticeSpeedSection ? context.gameSetting.practiceSpeed :
                                                 AVSpeechUtteranceDefaultSpeechRate
        _ = ttsSay(
            testSentence,
            speaker: selectedVoice?.identifier ?? "unknown",
            rate: speed
        )
        tableView.reloadData()
    }
}
