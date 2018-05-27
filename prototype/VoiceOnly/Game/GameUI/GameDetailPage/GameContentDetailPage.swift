//
//  GameContentDetailPage.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/13.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit
import Promises

private let context = GameContext.shared

class GameContentDetailPage: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var challengeButton: UIButton!

    @IBOutlet weak var perfectCountLabel: UILabel!
    @IBOutlet weak var greatCountLabel: UILabel!
    @IBOutlet weak var goodCountLabel: UILabel!
    @IBOutlet weak var missedCountLabel: UILabel!

    @IBOutlet weak var phoneButton: UIButton!

    @IBOutlet weak var messengerButton: UIButton!

    @IBOutlet weak var consoleButton: UIButton!

    @IBOutlet weak var readerButton: UIButton!

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        updateGameModeSelection()
        titleLabel.text = context.dataSetKey
        if let gameRecord = findBestRecord(key: context.dataSetKey) {
            rankLabel.text = gameRecord.rank.rawValue
            progressLabel.text = gameRecord.progress
            perfectCountLabel.text = gameRecord.perfectCount.s
            greatCountLabel.text = gameRecord.greatCount.s
            goodCountLabel.text = gameRecord.goodCount.s
            missedCountLabel.text = (context.sentences.count - gameRecord.perfectCount - gameRecord.greatCount - gameRecord.goodCount).s
        } else {
            rankLabel.text = "?"
            progressLabel.text = "??%"
            perfectCountLabel.text = 0.s
            greatCountLabel.text = 0.s
            goodCountLabel.text = 0.s
            missedCountLabel.text = 0.s
        }

        // load furigana
        all(context.sentences.map {$0.furiganaAttributedString}).then {_ in
            self.tableView.reloadData()
        }
    }

    @IBAction func backButtonClicked(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }

    @IBAction func challenge(_ sender: Any) {
        switch context.gameMode {
        case .phone:
            launchStoryboard(self, "PhoneGame")
        case .messenger:
            launchStoryboard(self, "MessengerGame")
        case .console:
            launchStoryboard(self, "ConsoleGame")
        default:
            print("\(context.gameMode) game mode is not implemented yet")
        }
    }

    @IBAction func phoneButtonClicked(_ sender: Any) {
        context.gameMode = .phone
        updateGameModeSelection()
    }

    @IBAction func messengerButtonClicked(_ sender: Any) {
        context.gameMode = .messenger
        updateGameModeSelection()
    }

    @IBAction func consoleButtonClicked(_ sender: Any) {
        context.gameMode = .console
        updateGameModeSelection()
    }

    @IBAction func readerButtonClicked(_ sender: Any) {
        context.gameMode = .reader
        updateGameModeSelection()
    }

    func updateGameModeSelection() {
        let mode = context.gameMode
        phoneButton.layer.borderWidth = mode == .phone ? 1.5 : 0
        messengerButton.layer.borderWidth = mode == .messenger ? 1.5 : 0
        consoleButton.layer.borderWidth = mode == .console ? 1.5 : 0
        readerButton.layer.borderWidth = mode == .reader ? 1.5 : 0
    }

}

extension GameContentDetailPage: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return context.sentences.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "SentenceCell", for: indexPath)
        guard let detailCell = cell as? GameDetailTableCell else { print("detailCell convert error"); return cell }
        let sentence = context.sentences[indexPath.row]

        if let tokenInfos = kanaTokenInfosCacheDictionary[sentence] {
            detailCell.furiganaLabel.attributedText = getFuriganaString(tokenInfos: tokenInfos)
        } else {
            detailCell.furiganaLabel.text = sentence
        }

        if let gameRecord = findBestRecord(key: context.dataSetKey),
           let score = gameRecord.sentencesScore[sentence] {
            detailCell.miscLabel.text = score.valueText
            detailCell.miscLabel.textColor = score.color
        } else {
            detailCell.miscLabel.text = "無分"
            detailCell.miscLabel.textColor = .lightGray
        }

        return detailCell
    }
}
