//
//  InfiniteChallengeTableCell.swift
//  今話したい
//
//  Created by Wangchou Lu on 11/15/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import UIKit

class InfiniteChallengeTableCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var finishedRateLabel: UILabel!
    @IBOutlet var rankLabel: UILabel!

    @IBOutlet var rankTitleLabel: UILabel!

    @IBOutlet var finishedRateTitleLabel: UILabel!
    var level: Level = .lv0 {
        willSet(level) {
            titleLabel.text = level.title
            titleLabel.textColor = level.color
            rankLabel.attributedText = getRankText(string: level.bestInfinteChallengeRank)
            finishedRateLabel.attributedText = getProgressText(string: level.bestInfinteChallengeProgress)
            rankTitleLabel.text = i18n.rank
            finishedRateTitleLabel.text = i18n.completeness
        }
    }
}
