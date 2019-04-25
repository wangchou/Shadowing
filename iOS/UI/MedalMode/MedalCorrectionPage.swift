//
//  MedalSummaryPage.swift
//  今話したい
//
//  Created by Wangchou Lu on 4/24/31 H.
//  Copyright © 31 Heisei Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

private let context = GameContext.shared

class MedalCorrectionPage: UIViewController {
    static let id = "MedalCorrectionPage"
    var medalCorrectionPageView: MedalCorrectionPageView? {
        return (view as? MedalCorrectionPageView)
    }

    override func loadView() {
        view = MedalCorrectionPageView()
        view.frame = CGRect(x: 0, y: 0, width: screen.width, height: screen.height)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        medalCorrectionPageView?.viewWillAppear()
    }
}

class MedalCorrectionPageView: UIView, GridLayout, ReloadableView, GameEventDelegate {
    var topView: GridUIView!
    var tableView: UITableView!
    var gridCount: Int = 48
    var isWrongSelected: Bool = true
    var isGoodSelected: Bool = true
    var isCorrectSelected: Bool = false
    var sentences: [String] {
        return context.sentences
    }
    var selectedSentences: [String] = []
    var missedCount: Int {
        var count = 0
        for str in sentences {
            let score = sentenceScores[str]?.value ?? 0
            if score < 60 {
                count += 1
            }
        }
        return count
    }

    var goodCount: Int {
        var count = 0
        for str in sentences {
            let score = sentenceScores[str]?.value ?? 0
            if score > 60 && score < 80 {
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

    func viewWillAppear() {
        updateSelectedSentences()
        removeAllSubviews()
        renderTopView()
        addBottomTable()
        addBottomButtons()
    }

    private func updateSelectedSentences() {
        selectedSentences = sentences.filter {
            guard let score = sentenceScores[$0] else { return isWrongSelected }
            switch score.type {
            case .perfect, .great:
                return isCorrectSelected
            case .good:
                return isGoodSelected
            case .poor:
                return isWrongSelected
            }
        }
    }

    // listening to sentence practice event
    func onEventHappened(_ notification: Notification) {
        guard let event = notification.object as? Event else { print("convert event fail"); return }

        switch event.type {
        case .practiceEnded:
            renderTopView()
        default:
            return
        }
    }

    private func renderTopView() {
        topView?.removeFromSuperview()
        topView = GridUIView()
        topView.backgroundColor = rgb(60, 60, 60)
        layout(0, 0, gridCount, 18, topView)
        addSubview(topView)

        var y = 5
        topView.addText(x: 2, y: y, h: 4, text: i18n.todayAndLanguageReview, color: .white)

        let orangeCount = goodCount
        let redCount = missedCount
        let greenCount = sentences.count - orangeCount - redCount

        let x = 3
        y += 5

        func addCountBox(x: Int, y: Int,
                         title: String, count: Int, color: UIColor,
                         isSelected: Bool,
                         onClick: @escaping (() -> Void)) {
            let rect = topView.addRect(x: x, y: y, w: 9, h: 6, color: .black)
            rect.roundBorder(borderWidth: 1.5, cornerRadius: step, color: isSelected ? .white : .clear)
            topView.addText(x: x+1, y: y, w: 9, h: 2, text: title, color: .white)
            let label = topView.addText(x: x, y: y+1, w: 8, h: 5, text: "\(count)", color: color)
            label.textAlignment = .right
            rect.addTapGestureRecognizer(action: onClick)
        }

        addCountBox(x: x, y: y,
                    title: i18n.correct, count: greenCount, color: myGreen,
                    isSelected: isCorrectSelected) { [weak self] in
                        guard let self = self else { return }
                        self.isCorrectSelected = !self.isCorrectSelected
                        self.viewWillAppear()
                    }
        addCountBox(x: x+10, y: y,
                    title: i18n.good, count: orangeCount, color: myOrange,
                    isSelected: isGoodSelected) { [weak self] in
                        guard let self = self else { return }
                        self.isGoodSelected = !self.isGoodSelected
                        self.viewWillAppear()
                    }
        addCountBox(x: x+20, y: y,
                    title: i18n.wrong, count: redCount, color: myRed,
                    isSelected: isWrongSelected) { [weak self] in
                        guard let self = self else { return }
                        self.isWrongSelected = !self.isWrongSelected
                        self.viewWillAppear()
                    }

        topView.addRect(x: 34, y: y, w: 12, h: 6, color: UIColor.red.withAlphaComponent(0.7))
                .roundBorder(borderWidth: 0.5, cornerRadius: step, color: .clear)
    }

    private func addBottomTable() {
        tableView = UITableView()
        // https://stackoverflow.com/questions/25541786/custom-uitableviewcell-from-nib-in-swift
        tableView.register(UINib(nibName: "SentencesTableCell", bundle: nil),
                           forCellReuseIdentifier: SentencesTableCell.id)

        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.separatorColor = rgb(200, 200, 200)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.frame = CGRect(x: 0,
                                 y: topView.y1,
                                 width: screen.width,
                                 height: screen.height -
                                    topView.frame.height -
                                    bottomButtonHeight)
        addSubview(tableView)
    }

    private func addBottomButtons() {
        let buttonGreen = rgb(73, 160, 83)
        let buttonGray = buttonGreen.withSaturation(0)
        let buttonActionHeight = step * 6
        var bgRect = UIView()
        bgRect.frame = CGRect(x: 0,
                              y: tableView.y1,
                              width: screen.width,
                              height: bottomButtonHeight)
        bgRect.backgroundColor = buttonGreen
        addSubview(bgRect)
        var button = UIButton()
        button.frame = bgRect.frame
        button.frame.size.height = buttonActionHeight
        button.backgroundColor = buttonGreen
        button.setTitle("\(i18n.english) / \(i18n.japanese)", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .highlighted)
        button.titleLabel?.font = bottomButtonFont
        button.addTarget(self, action: #selector(onPeekButtonClicked), for: .touchUpInside)
        addSubview(button)

        bgRect = UIView()
        bgRect.frame = CGRect(x: 39 * step,
                              y: tableView.frame.origin.y + tableView.frame.height,
                              width: 9 * step,
                              height: bottomButtonHeight)
        bgRect.backgroundColor = buttonGray
        addSubview(bgRect)
        button = UIButton()
        button.frame = bgRect.frame
        button.frame.size.height = buttonActionHeight
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

        line = addRect(x: 39, y: 0, w: 1, h: 7, color: rgb(130, 130, 130))
        line.frame.size.width = 0.5
        line.frame.origin.y = button.y0
    }

    @objc func onPeekButtonClicked() {
        context.gameSetting.isShowTranslationInPractice = !context.gameSetting.isShowTranslationInPractice
        saveGameSetting()
        tableView.reloadData()
    }

    @objc func onCloseButtonClicked() {
        dismissVC()
    }

}

extension MedalCorrectionPageView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedSentences.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SentencesTableCell.id,
                                                 for: indexPath)
        guard let contentCell = cell as? SentencesTableCell else {
            print("detailCell convert error")
            return cell
        }
        contentCell.selectionStyle = .none

        let sentence = selectedSentences[indexPath.row]
        contentCell.update(sentence: sentence,
                           isShowTranslate: context.gameSetting.isShowTranslationInPractice)

        return contentCell
    }
}

extension MedalCorrectionPageView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
}
