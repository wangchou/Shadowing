//
//  GameFinishedPage.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/22.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

private let context = GameContext.shared

class GameFinishedPage: UIViewController {
    static var last: GameFinishedPage?
    static let vcName = "GameFinishedPage"
    @IBOutlet var reportView: GameReportView!

    @IBOutlet var tableView: UITableView!
    @objc func injected() {
        #if DEBUG
            viewWillAppear(false)
        #endif
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(
            UINib(nibName: "SentencesTableCell", bundle: nil),
            forCellReuseIdentifier: "FinishedTableCell"
        )
        view.addTapGestureRecognizer {
            stopCountDown()
        }
        tableView.addTapGestureRecognizer {
            stopCountDown()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sortSentenceByScore()
        reportView.render()
        GameFinishedPage.last = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reportView.viewDidAppear()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SpeechEngine.shared.stopListeningAndSpeaking()
        reportView.viewDidDisappear()
        GameFinishedPage.last = nil
    }

    func sortSentenceByScore() {
        context.sentences.sort { chStr1, chStr2 in
            guard let record = context.gameRecord else { return true }
            guard let score1 = record.sentencesScore[chStr1.origin] else { return false }
            guard let score2 = record.sentencesScore[chStr2.origin] else { return true }

            return score1.value < score2.value
        }
    }
}

extension GameFinishedPage: UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return context.sentences.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FinishedTableCell", for: indexPath)
        guard let finishedCell = cell as? SentencesTableCell else { print("detailCell convert error"); return cell }
        let sentence = context.sentences[indexPath.row]

        finishedCell.update(sentence: sentence,
                            translationLang: context.gameMode == .topicMode ? .zh :
                                context.gameSetting.translationLang)

        return finishedCell
    }
}

extension GameFinishedPage: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if let cell = cell as? SentencesTableCell {
            cell.isSelected = false
            cell.practiceSentence()
        }
    }

    func scrollViewDidScroll(_: UIScrollView) {
        stopCountDown()
    }
}
