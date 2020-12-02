//
//  InfiniteChallengeListPage.swift
//  今話したい
//
//  Created by Wangchou Lu on 11/15/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import UIKit

private let context = GameContext.shared

class InfiniteChallengeListPage: UIViewController {
    @IBOutlet var topBarView: TopBarView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var bottomBarView: BottomBarView!
    @IBOutlet var tableBottomConstraint: NSLayoutConstraint!

    @IBOutlet var topChartView: TopChartView!

    override func viewDidLoad() {
        super.viewDidLoad()

        bottomBarView.contentTab = .infiniteChallenge

        topBarView.rightButton.setIconImage(named: "outline_info_black_48pt", isIconOnLeft: false)
        if Locale.current.languageCode == "zh" {
            topBarView.customOnRightButtonClicked = {
                launchVC("InfoPage", self)
            }
        } else {
            topBarView.rightButton.isHidden = true
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        showHideBottomBar()
    }

    private func showHideBottomBar() {
        if gameLang.isSupportTopicMode {
            tableBottomConstraint.constant = -50
            bottomBarView.isHidden = false
        } else {
            bottomBarView.isHidden = true
            tableBottomConstraint.constant = 0
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showHideBottomBar()
        context.gameMode = .infiniteChallengeMode
        if IAPHelper.shared.products.isEmpty {
            IAPHelper.shared.requsestProducts()
        }
        bottomBarView.contentTab = .infiniteChallenge
        topBarView.titleLabel.text = i18n.infiniteChallengeTitle
        topChartView.prepareForDailyGoalAppear()
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
            DispatchQueue.main.async {
                self.topChartView.render()
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
}

extension InfiniteChallengeListPage: UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
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
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let swipablePage = rootViewController.current as? InfiniteChallengeSwipablePage,
           let infiniteChallengePage = swipablePage.detailPage {
            infiniteChallengePage.level = allLevels[indexPath.row]
        }

        (rootViewController.current as? UIPageViewController)?.goToNextPage { _ in
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "InfiniteChallengeTableCell", for: indexPath)
            cell.isSelected = false
        }
    }
}
