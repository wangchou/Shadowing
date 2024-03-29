//
//  InfiniteChallengePage.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 10/8/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

private let context = GameContext.shared

class InfiniteChallengeDetailPage: UIViewController {
    static var last: InfiniteChallengeDetailPage?
    @IBOutlet var topBarView: TopBarView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var blockView: UIView!
    @IBOutlet var blockInfo: UILabel!
    @IBOutlet var translationButton: UIButton!
    @IBOutlet var infoView: ICInfoView!
    var topBarTitle: String {
        return i18n.language + " - " + level.title
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

    override func viewDidLoad() {
        super.viewDidLoad()
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
        infoView.render()
        tableView.reloadData()
        InfiniteChallengeDetailPage.last = self

        // add block screen
        blockView.isHidden = false

        guard level != .lv0 else { blockView.isHidden = true; return }

        let lastLevel = allLevels[(allLevels.firstIndex(of: level) ?? 0) - 1]
        if let lastLevelBestRecord = findBestRecord(dataSetKey: lastLevel.infinteChallengeDatasetKey),
           lastLevelBestRecord.p >= lastLevel.lockPercentage {
            blockView.isHidden = true
        }
        blockInfo.text = "「\(lastLevel.title)」< \(lastLevel.lockPercentage.i)%"
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        InfiniteChallengeDetailPage.last = nil
    }

    func afterGameUpdate() {
        infoView.render()
        tableView.reloadData()
    }

    func updateUI() {
        translationButton.setTitle(i18n.translationOrOriginal, for: .normal)
        translationButton.setTitle(i18n.translationOrOriginal, for: .highlighted)
        translationButton.titleLabel?.font = getBottomButtonFont()
        translationButton.setTitleColor(.white, for: .highlighted)
        translationButton.showsTouchWhenHighlighted = true
        if topBarRightText == "" {
            topBarView.rightButton.isHidden = true
        } else {
            topBarView.rightButton.setIconImage(named: "round_arrow_forward_ios_black_48pt", title: topBarRightText, isIconOnLeft: false)
        }

        topBarView.leftButton.setIconImage(named: "round_arrow_back_ios_black_48pt", title: topBarLeftText)

        topBarView.titleLabel.text = topBarTitle
    }

    @IBAction func onTranslationButtonClicked(_: Any) {
        context.gameSetting.isShowTranslationInPractice = !context.gameSetting.isShowTranslationInPractice
        saveGameSetting()
        tableView.reloadData()
    }
}

extension InfiniteChallengeDetailPage: UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        if let sentences = lastInfiniteChallengeSentences[level] {
            return sentences.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ICContentTableCell", for: indexPath)
        guard let contentCell = cell as? SentencesTableCell else { print("detailCell convert error"); return cell }

        if let strings = lastInfiniteChallengeSentences[level] {
            let sentences = strings.map { str -> Sentence in
                getSentenceByString(str)
            }
            contentCell.update(sentence: sentences[indexPath.row],
                               isShowTranslate: context.gameSetting.isShowTranslationInPractice,
                               translationLang: context.gameSetting.translationLang)
        }

        return contentCell
    }
}

extension InfiniteChallengeDetailPage: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if let cell = cell as? SentencesTableCell {
            cell.isSelected = false
            cell.practiceSentence()
        }
    }
}
