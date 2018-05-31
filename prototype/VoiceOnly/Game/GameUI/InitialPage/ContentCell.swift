//
//  ContentCell.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/10.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

class ContentCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var progress: UILabel!
    @IBOutlet weak var rank: UILabel!

    var strockedRankText: String? = "" {
        willSet(string) {
            if let string = string {
                let color = getRankColor(rank: Rank(rawValue: string))
                rank.attributedText = getStrokeText(string, color)
            } else {
                rank.attributedText = getStrokeText("?", .lightText)
            }
        }
    }

    var strockedProgressText: String? = "" {
        willSet(string) {
            if let string = string {
                progress.attributedText = getStrokeText(string, .white)
            } else {
                progress.attributedText = getStrokeText("??%", .lightText)
            }
        }
    }
}
