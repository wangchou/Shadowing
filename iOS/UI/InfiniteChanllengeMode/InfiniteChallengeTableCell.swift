//
//  InfiniteChallengeTableCell.swift
//  今話したい
//
//  Created by Wangchou Lu on 11/15/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import UIKit

private let i18n = I18n.shared

class InfiniteChallengeTableCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var syllablesCountLabel: UILabel!
    @IBOutlet weak var finishedRateLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!

    var level: Level = .lv0 {
        willSet(level) {
            titleLabel.text = level.title
            titleLabel.textColor = level.color
            syllablesCountLabel.text = "\(i18n.syllablesCount):\(level.minSyllablesCount)~\(level.maxSyllablesCount)"
            rankLabel.attributedText = getRankText(string: level.bestInfinteChallengeRank)
            finishedRateLabel.attributedText = getProgressText(string: level.bestInfinteChallengeProgress)
        }
    }
}
