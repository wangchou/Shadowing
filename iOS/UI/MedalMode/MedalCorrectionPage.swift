//
//  MedalSummaryPage.swift
//  今話したい
//
//  Created by Wangchou Lu on 4/24/31 H.
//  Copyright © 31 Heisei Lu, WangChou. All rights reserved.
//

import AVFoundation
import Foundation
import Promises
import UIKit

private let context = GameContext.shared

class MedalCorrectionPage: UIViewController {
    static let id = "MedalCorrectionPage"
    var medalCorrectionPageView: MedalCorrectionPageView? {
        return (view as? MedalCorrectionPageView)
    }

    override func loadView() {
        view = MedalCorrectionPageView()
        medalCorrectionPageView?.vc = self
        view.frame = CGRect(x: 0, y: 0, width: screen.width, height: screen.height)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        medalCorrectionPageView?.render()
    }
}

class MedalCorrectionPageView: UIView, GridLayout, ReloadableView, GameEventDelegate {
    var topView: GridUIView!
    var tableView: UITableView!
    var gridCount: Int = 48
    var vc: MedalCorrectionPage?
    var sentences: [Sentence] {
        return context.sentences
    }

    var sortedSentences: [Sentence] = []
    var missedCount: Int {
        var count = 0
        for s in sentences {
            let score = sentenceScores[s.origin]?.value ?? 0
            if score < 60 {
                count += 1
            }
        }
        return count
    }

    var goodCount: Int {
        var count = 0
        for s in sentences {
            let score = sentenceScores[s.origin]?.value ?? 0
            if score >= 60, score < 80 {
                count += 1
            }
        }
        return count
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        startEventObserving(self)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        startEventObserving(self)
    }

    deinit {
        stopEventObserving(self)
    }

    func render() {
        all([waitKanaInfoLoaded,
             waitSentenceScoresLoaded]).then { [weak self] _ in
            DispatchQueue.main.async {
                self?.removeAllSubviews()
                self?.renderTopView()
                self?.addBottomTable()
                self?.addBottomButtons()
            }
        }
    }

    func renderTopView() {
        topView?.removeFromSuperview()
        topView = GridUIView()
        topView.backgroundColor = darkBackground
        layout(0, 0, gridCount, 15 + topPaddedY, topView)
        addSubview(topView)

        var y = topPaddedY
        let titleAttrText = NSMutableAttributedString()
        let fontSize = getFontSize(h: 5)
        titleAttrText.append(colorText(i18n.today,
                                       rgb(240, 240, 240),
                                       fontSize: fontSize))
        titleAttrText.append(colorText(" (\(i18n.language))",
                                       rgb(160, 160, 160),
                                       fontSize: fontSize))
        topView.addAttrText(x: 2, y: y, h: 5, text: titleAttrText)

        let orangeCount = goodCount
        let redCount = missedCount
        let greenCount = sentences.count - orangeCount - redCount

        let x = 3
        y += 7

        func addCountBox(x: Int, y: Int,
                         title: String, count: Int, color: UIColor) {
            let rect = topView.addRect(x: x, y: y, w: 9, h: 6, color: .black)
            rect.roundBorder(radius: step)
            let typeLabel = topView.addText(x: x + 1, y: y, w: 9, h: 2,
                            text: title,
                            font: MyFont.regular(ofSize: step * 1.7),
                            color: .white)
            let label = topView.addText(x: x, y: y + 1, w: 8, h: 5, text: "\(count)", color: color)
            label.textAlignment = .right

            if #available(iOS 13, *) {
                typeLabel.frame.origin.y += 1
                label.frame.origin.y += 2
            }
        }

        addCountBox(x: x, y: y,
                    title: i18n.correct, count: greenCount, color: myGreen)
        addCountBox(x: x + 11, y: y,
                    title: i18n.good, count: orangeCount, color: myOrange)
        addCountBox(x: x + 22, y: y,
                    title: i18n.wrong, count: redCount, color: myRed)

        var button = UIButton()
        button.setIconImage(named: "baseline_sort_black_\(iconSize)")
        button.setStyle(style: .darkOption, step: step)
        button.addTapGestureRecognizer { [weak self] in
            self?.render()
        }
        layout(37, y, 9, 6, button)
        topView.addSubview(button)

        button = UIButton()
        let title = String(format: "%.2fx", context.gameSetting.practiceSpeed * 2)
        button.setStyle(style: .darkOption, step: step)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = MyFont.regular(ofSize: step * 2.8)
        button.addTapGestureRecognizer { [weak self] in
            VoiceSelectionPage.fromPage = self?.vc
            VoiceSelectionPage.selectingVoiceFor = .teacher
            VoiceSelectionPage.selectedVoice = AVSpeechSynthesisVoice(identifier: context.gameSetting.teacher) ??
                getDefaultVoice(language: gameLang.defaultCode)
            launchVC(VoiceSelectionPage.id)
        }
        layout(37, y - 6, 9, 4, button)
        topView.addSubview(button)
    }

    // MARK: - Practice Game Related

    // listening to sentence practice event
    func onEventHappened(_ notification: Notification) {
        guard let event = notification.object as? Event else { print("convert event fail"); return }

        switch event.type {
        case .practiceSentenceCalculated:
            renderTopView()
        default:
            return
        }
    }

    private func addBottomTable() {
        sortedSentences = sentences.sorted {
            (sentenceScores[$0.origin]?.value ?? 0) < (sentenceScores[$1.origin]?.value ?? 0)
        }

        tableView = UITableView()
        // https://stackoverflow.com/questions/25541786/custom-uitableviewcell-from-nib-in-swift
        tableView.register(UINib(nibName: "SentencesTableCell", bundle: nil),
                           forCellReuseIdentifier: SentencesTableCell.id)
        tableView.delaysContentTouches = true
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.separatorColor = rgb(200, 200, 200)
        tableView.frame = CGRect(x: 0,
                                 y: topView.y1,
                                 width: screen.width,
                                 height: screen.height -
                                     topView.frame.height -
                                     bottomButtonHeight)
        tableView.dataSource = self
        addSubview(tableView)
    }

    private func addBottomButtons() {
        let buttonGreen = rgb(73, 160, 83)
        let buttonGray = buttonGreen.withSaturation(0)
        var bgRect = UIView()
        bgRect.frame = CGRect(x: 0,
                              y: tableView.y1,
                              width: 39 * step,
                              height: bottomButtonHeight)
        bgRect.backgroundColor = buttonGreen
        addSubview(bgRect)
        var button = UIButton()
        button.frame = bgRect.frame
        button.frame.size.height = bottomButtonTextAreaHeight
        button.backgroundColor = buttonGreen
        button.setTitle("\(i18n.language) / \(i18n.translation)", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(buttonForegroundGray, for: .highlighted)
        button.titleLabel?.font = bottomButtonFont
        button.addTarget(self, action: #selector(onPeekButtonClicked), for: .touchUpInside)
        addSubview(button)

        bgRect = UIView()
        bgRect.frame = CGRect(x: 39 * step,
                              y: tableView.y1,
                              width: 9 * step,
                              height: bottomButtonHeight)
        bgRect.backgroundColor = buttonGray
        addSubview(bgRect)
        button = UIButton()
        button.frame = bgRect.frame
        button.frame.size.height = bottomButtonTextAreaHeight
        button.backgroundColor = buttonGray
        button.titleLabel?.font = bottomButtonFont
        button.setTitle("X", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(UIColor.lightText.withAlphaComponent(0.5), for: .highlighted)
        button.addTarget(self, action: #selector(onCloseButtonClicked), for: .touchUpInside)
        addSubview(button)

        var line = addRect(x: 0, y: 0, w: 48, h: 1, color: .darkGray)
        line.frame.size.height = 0.5
        line.frame.origin.y = button.y0

        line = addRect(x: 39, y: 0, w: 1, h: 10, color: rgb(130, 130, 130))
        line.frame.size.width = 0.5
        line.frame.origin.y = button.y0
    }

    @objc func onPeekButtonClicked() {
        context.gameSetting.isShowTranslationInPractice = !context.gameSetting.isShowTranslationInPractice
        saveGameSetting()
        tableView.reloadData()
    }

    @objc func onCloseButtonClicked() {
        rootViewController.updateWhenEnterForeground()
        dismissVC()
    }
}

extension MedalCorrectionPageView: UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return sortedSentences.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: SentencesTableCell.id, for: indexPath) as! SentencesTableCell
        // swiftlint:enable force_cast
        cell.selectionStyle = .none

        let sentence = sortedSentences[indexPath.row]

        cell.update(sentence: sentence,
                    isShowTranslate: context.gameSetting.isShowTranslationInPractice)

        return cell
    }
}
