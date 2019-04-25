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

class MedalCorrectionPageView: UIView, GridLayout, ReloadableView {
    var topView: UIView!
    var tableView: UITableView!
    var gridCount: Int = 48
    var sentences: [String] {
        return context.sentences
    }
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

    func viewWillAppear() {
        removeAllSubviews()
        addTopView()
        addBottomTable()
        addBottomButtons()
    }

    private func addTopView() {
        topView = UIView()
        topView.backgroundColor = rgb(60, 60, 60)
        layout(0, 0, gridCount, 16, topView)
        addSubview(topView)

        addText(x: 2, y: 3, h: 4, text: i18n.todayAndLanguageReview, color: .white)

        let orangeCount = goodCount
        let redCount = missedCount
        let greenCount = sentences.count - orangeCount - redCount

        let x = 3
        let y = 8

        func addCountBox(x: Int, y: Int, title: String, count: Int, color: UIColor) {
            let rect = addRect(x: x, y: y, w: 9, h: 6, color: .black)
            rect.roundBorder(borderWidth: 0.5, cornerRadius: step, color: .clear)
            addText(x: x+1, y: y, w: 9, h: 2, text: title, color: .white)
            let label = addText(x: x, y: y+1, w: 8, h: 5, text: "\(count)", color: color)
            label.textAlignment = .right
        }

        addCountBox(x: x, y: y, title: i18n.correct, count: greenCount, color: myGreen)
        addCountBox(x: x+10, y: y, title: i18n.good, count: orangeCount, color: myOrange)
        addCountBox(x: x+20, y: y, title: i18n.wrong, count: redCount, color: myRed)

        addRect(x: 34, y: 8, w: 12, h: 6, color: UIColor.red.withAlphaComponent(0.7))
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
                                    step * 7)
        addSubview(tableView)
    }

    private func addBottomButtons() {
        var button = UIButton()
        button.frame = CGRect(x: 0,
                              y: tableView.frame.origin.y + tableView.frame.height,
                              width: screen.width,
                              height: step * 7)
        button.backgroundColor = rgb(73, 160, 83)
        button.setTitle("\(i18n.english) / \(i18n.japanese)", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .highlighted)
        button.addTarget(self, action: #selector(onPeekButtonClicked), for: .touchUpInside)
        addSubview(button)

        button = UIButton()
        button.frame = CGRect(x: 41 * step,
                              y: tableView.frame.origin.y + tableView.frame.height,
                              width: 7 * step,
                              height: step * 7)
        button.backgroundColor = rgb(73, 160, 83).withSaturation(0)
        button.setTitle("X", for: .normal)
        button.setTitleColor(.lightText, for: .normal)
        button.setTitleColor(UIColor.lightText.withAlphaComponent(0.5), for: .highlighted)
        button.addTarget(self, action: #selector(onCloseButtonClicked), for: .touchUpInside)
        addSubview(button)

        var line = addRect(x: 0, y: 0, w: 48, h: 1, color: .darkGray)
        line.frame.size.height = 0.5
        line.frame.origin.y = button.y0

        line = addRect(x: 41, y: 0, w: 1, h: 7, color: rgb(130, 130, 130))
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
        return context.sentences.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SentencesTableCell.id,
                                                 for: indexPath)
        guard let contentCell = cell as? SentencesTableCell else {
            print("detailCell convert error")
            return cell
        }
        contentCell.selectionStyle = .none

        let sentence = context.sentences[indexPath.row]
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
