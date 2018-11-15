//
//  InfiniteChanllengePage.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 10/8/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

private let context = GameContext.shared
private let i18n = I18n.shared

class InfiniteChallengePage: UIViewController {
    @IBOutlet weak var topBarView: TopBarView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var blockView: UIView!
    @IBOutlet weak var blockInfo: UILabel!
    @IBOutlet weak var translationButton: UIButton!
    var topBarTitle: String {
        return i18n.languageInJa + " - " + level.title
    }
    var topBarLeftText: String = ""
    var topBarRightText: String = ""
    var level: Level = .lv0
    var minKanaCount: Int {
        return level.minSyllablesCount
    }
    var maxKanaCount: Int {
        return level.maxSyllablesCount
    }
    @IBOutlet weak var infoView: ICInfoView!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadSentenceDB()
        tableView.register(
            UINib(nibName: "SentencesTableCell", bundle: nil),
            forCellReuseIdentifier: "ICContentTableCell"
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
        infoView.level = level
        infoView.minKanaCount = minKanaCount
        infoView.maxKanaCount = maxKanaCount
        infoView.sentencesCount = getSentenceCount(minKanaCount: minKanaCount, maxKanaCount: maxKanaCount)
        infoView.viewWillAppear()

        // add block screen
        blockView.isHidden = false

        guard level != .lv0 else { blockView.isHidden = true; return }

        let lastLevel = allLevels[(allLevels.firstIndex(of: level) ?? 0) - 1]
        if let lastLevelBestRecord = findBestRecord(key: lastLevel.infinteChallengeDatasetKey),
           lastLevelBestRecord.p >= 80 {
            blockView.isHidden = true
        }

        blockInfo.text = "「\(lastLevel.title)」B判定以上解鎖。"
        tableView.reloadData()
    }

    func updateUI() {
        if topBarRightText == "" {
            topBarView.rightButton.isHidden = true
        } else {
            topBarView.rightButton.setIconImage(named: "round_arrow_forward_ios_black_48pt", title: topBarRightText, isIconOnLeft: false)
        }

        topBarView.leftButton.setIconImage(named: "round_arrow_back_ios_black_48pt", title: topBarLeftText)

        topBarView.titleLabel.text = topBarTitle
    }
    @IBAction func onTranslationButtonClicked(_ sender: Any) {
        context.gameSetting.isUsingTranslation = !context.gameSetting.isUsingTranslation
        saveGameSetting()
        tableView.reloadData()
    }
}

extension InfiniteChallengePage: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sentences = lastInfiniteChallengeSentences[self.level] {
            return sentences.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "ICContentTableCell", for: indexPath)
        guard let contentCell = cell as? SentencesTableCell else { print("detailCell convert error"); return cell }

        if let sentences = lastInfiniteChallengeSentences[self.level] {
            contentCell.update(sentence: sentences[indexPath.row], isShowTranslate: context.gameSetting.isUsingTranslation)
        }

        return contentCell
    }
}

extension InfiniteChallengePage: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if let cell = cell as? SentencesTableCell {
            cell.practiceSentence()
        }
    }
}
