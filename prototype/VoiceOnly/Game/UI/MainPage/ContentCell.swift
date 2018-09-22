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
    @IBOutlet weak var titleLabel: FuriganaLabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!

    var strockedRankText: String? = "" {
        willSet(string) {
            if let string = string,
               let rank = Rank(rawValue: string) {
                rankLabel.attributedText = getStrokeText(string, rank.color)
            } else {
                rankLabel.attributedText = getStrokeText("?", .lightText)
            }
        }
    }

    var strockedProgressText: String? = "" {
        willSet(string) {
            let attrText = NSMutableAttributedString()
            if let string = string {
                attrText.append(getStrokeText(string, .darkGray))
                attrText.append(getStrokeText("%", .darkGray, strokeWidth: 0, strokColor: .black, font: UIFont.boldSystemFont(ofSize: 12)))
                progressLabel.attributedText = attrText
            } else {
                attrText.append(getStrokeText("??", .lightText))
                attrText.append(getStrokeText("%", .darkGray, strokeWidth: 0, strokColor: .black, font: UIFont.boldSystemFont(ofSize: 12)))
                progressLabel.attributedText = attrText
            }
        }
    }
}
