//
//  ContentCell.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/10.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

func getStrokeText(_ string: String, _ color: UIColor) -> NSMutableAttributedString {
    let text = NSMutableAttributedString(string: string)
    text.addAttributes([
            .strokeColor: UIColor.black,
            .strokeWidth: -1,
            .foregroundColor: color,
            .font: UIFont.boldSystemFont(ofSize: 32)
        ],
        range: NSMakeRange(0, text.length)
    )
    return text
}

class ContentCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var progress: UILabel!
    @IBOutlet weak var rank: UILabel!
    
    var strockedRankText: String? = "" {
        willSet(string) {
            if let string = string {
                rank.attributedText = getStrokeText(string, myRed)
            } else {
                rank.attributedText = getStrokeText("?", .lightText)
            }
        }
    }
    
    var strockedProgressText: String? = "" {
        willSet(string) {
            if let string = string {
                progress.attributedText = getStrokeText(string, myGreen)
            } else {
                progress.attributedText = getStrokeText("??%", .lightText)
            }
        }
    }
}

