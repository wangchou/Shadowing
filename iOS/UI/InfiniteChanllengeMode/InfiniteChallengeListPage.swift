//
//  InfiniteChallengeListPage.swift
//  今話したい
//
//  Created by Wangchou Lu on 11/15/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import UIKit

private let i18n = I18n.shared

class InfiniteChallengeListPage: UIViewController {
    @IBOutlet weak var topBarView: TopBarView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomBarView: BottomBarView!
    @IBOutlet weak var tableBottomConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        topBarView.rightButton.isHidden = true
        bottomBarView.contentTab = .infiniteChallenge
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if gameLang.isSupportTopicMode {
            tableBottomConstraint.constant = -50
            bottomBarView.isHidden = false
        } else {
            bottomBarView.isHidden = true
            tableBottomConstraint.constant = 0
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        viewWillLayoutSubviews()
        super.viewWillAppear(animated)
        bottomBarView.contentTab = .infiniteChallenge
        topBarView.titleLabel.text = i18n.infiniteChallengeTitle
    }
}

extension InfiniteChallengeListPage: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allLevels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InfiniteChallengeTableCell", for: indexPath)
        guard let challengeCell = cell as? InfiniteChallengeTableCell else { print("challengeCell convert error"); return cell }
        challengeCell.level = allLevels[indexPath.row]
        return challengeCell
    }
}

extension InfiniteChallengeListPage: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let infiniteChallengeSwipablePage = (rootViewController.current as? UIPageViewController) as? InfiniteChallengeSwipablePage,
            let infiniteChallengePage = infiniteChallengeSwipablePage.pages[2] as? InfiniteChallengePage {
            infiniteChallengePage.level = allLevels[indexPath.row]
        }
        (rootViewController.current as? UIPageViewController)?.goToNextPage()
    }
}
