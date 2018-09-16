//
//  GameFinishedTableCell.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/22.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit
import Promises

class GameFinishedTableCell: UITableViewCell {
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var sentenceLabel: FuriganaLabel!
    @IBOutlet weak var userSaidSentenceLabel: FuriganaLabel!
    @IBOutlet weak var practiceButton: UIButton!

    var tableView: UITableView? {
        var view = superview
        while let tmpView = view, tmpView.isKind(of: UITableView.self) == false {
            view = tmpView.superview
        }
        return view as? UITableView
    }

    @IBAction func practiceButtonTapped(_ sender: Any) {
        guard let targetString = scoreLabel.text else { return }

        tableView?.beginUpdates()
        userSaidSentenceLabel.text = " "
        userSaidSentenceLabel.backgroundColor = UIColor.white
        userSaidSentenceLabel.isHidden = false
        let startTime = getNow()
        tableView?.endUpdates()

        Game.speakString(string: targetString)
            .then { () -> Promise<String> in
                let duration = getNow() - startTime + 0.4
                self.tableView?.beginUpdates()
                self.userSaidSentenceLabel.text = "listening..."
                self.userSaidSentenceLabel.textColor = UIColor.red
                self.tableView?.endUpdates()
                return listen(duration: duration, langCode: targetString.langCode)
            }.then { userSaidSentence -> Promise<Score> in
                self.tableView?.beginUpdates()
                userSaidSentences[targetString] = userSaidSentence
                self.userSaidSentenceLabel.textColor = UIColor.black
                if let tokenInfos = kanaTokenInfosCacheDictionary[userSaidSentence] {
                    self.userSaidSentenceLabel.attributedText = getFuriganaString(tokenInfos: tokenInfos)
                } else {
                    self.userSaidSentenceLabel.text = userSaidSentence
                }
                self.tableView?.endUpdates()
                return calculateScore(targetString, userSaidSentence)
            }.then { score in
                self.scoreLabel.text = score.valueText
                self.scoreLabel.textColor = score.color
                self.userSaidSentenceLabel.backgroundColor = score.color
                self.userSaidSentenceLabel.isHidden = score.type == .perfect ? true : false
            }
    }
}
