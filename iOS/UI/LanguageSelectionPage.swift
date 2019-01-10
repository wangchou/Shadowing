//
//  LanguageSelectionPage.swift
//  今話したい
//
//  Created by Wangchou Lu on 11/23/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import UIKit

private let context = GameContext.shared

class LanguageSelectionPage: UITableViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var englishLabel: UILabel!
    @IBOutlet weak var japaneseLabel: UILabel!

    override func viewWillAppear(_ animated: Bool) {
        titleLabel.text = i18n.wantToSayLabel
        englishLabel.text = i18n.english
        japaneseLabel.text = i18n.japanese
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {

            if indexPath.row == 0 {
                gameLang = .en
            }
            if indexPath.row == 1 {
                gameLang = .jp
            }

            saveGameLang()
            loadGameHistory()
            loadGameSetting()
            loadGameMiscData()

            if gameLang == .en {
                rootViewController.showInfiniteChallengePage()
                context.contentTab = .infiniteChallenge
            } else {
                rootViewController.showMainPage()
            }
            rootViewController.reloadTableData()
        }
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return i18n.canChangeItLaterInSetting
    }
}
