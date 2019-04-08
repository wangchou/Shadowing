//
//  RootContainerViewController.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 10/18/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit
import Speech
import Promises

class RootContainerViewController: UIViewController {
    static var isShowSetting = false

    var current: UIViewController!
    var splashScreen: SplashScreenViewController!
    var topicSwipablePage: TopicSwipablePage!
    var infiniteChallengeSwipablePage: InfiniteChallengeSwipablePage!

    override func viewDidLoad() {
        super.viewDidLoad()

        // swiftlint:disable force_cast
        splashScreen = (getVC("LaunchScreen") as! SplashScreenViewController)
        topicSwipablePage = (getVC(TopicSwipablePage.storyboardId) as! TopicSwipablePage)
        infiniteChallengeSwipablePage = (getVC(InfiniteChallengeSwipablePage.storyboardId) as! InfiniteChallengeSwipablePage)
        // swiftlint:enable force_cast

        current = splashScreen

        showVC(splashScreen)

        splashScreen.launched.always { [weak self] in
            self?.loadStartupData()
            self?.showInitialPage()
        }
    }

    private func loadStartupData() {
        let t1 = getNow()
        loadGameLang()
        loadGameSetting()
        loadMedalCount()

        loadTopicSentenceDB()
        loadSentenceDB()
        loadDataSets()

        loadGameHistory()
        loadGameMiscData(isLoadKana: true, isAsync: true)
        print("\nstartup load time: \(getNow() - t1)")
    }

    private func showInitialPage() {
        if gameLang.isSupportTopicMode {
            showMainPage(idx: 1)
        } else {
            showInfiniteChallengePage(idx: 1)
        }
    }

    func showMainPage(idx: Int) {
        guard current != topicSwipablePage else { return }
        removeCurrent()
        current = topicSwipablePage
        let sp: TopicSwipablePage! = topicSwipablePage
        if sp.isPagesReady {
           sp.setViewControllers([sp.pages[idx]], direction: .reverse, animated: false, completion: nil)
        } else {
            TopicSwipablePage.initialIdx = idx
        }
        showVC(current)
    }

    func showInfiniteChallengePage(idx: Int) {
        guard current != infiniteChallengeSwipablePage else { return }
        removeCurrent()
        current = infiniteChallengeSwipablePage
        let sp: InfiniteChallengeSwipablePage! = infiniteChallengeSwipablePage
        if sp.isPagesReady {
           sp.setViewControllers([sp.pages[idx]], direction: .reverse, animated: false, completion: nil)
        } else {
            InfiniteChallengeSwipablePage.initialIdx = idx
        }

        showVC(current)
    }

    func reloadTableData() {
        if let listPage = topicSwipablePage.listPage,
            listPage.sentencesTableView != nil {
            listPage.sentencesTableView.reloadData()
        }
        if let listPage = infiniteChallengeSwipablePage.listPage,
            listPage.tableView != nil {
            listPage.tableView.reloadData()
        }
    }

    func rerenderTopView() {
        if let listPage = topicSwipablePage.listPage {
            listPage.topChartView.viewWillAppear()
            listPage.topChartView.animateProgress()
        }
        if let listPage = infiniteChallengeSwipablePage.listPage {
            listPage.topChartView.viewWillAppear()
        }
    }

    private func showVC(_ vc: UIViewController) {
        addChild(vc)
        vc.view.frame = view.bounds
        view.addSubview(vc.view)
        vc.didMove(toParent: self)
    }

    private func removeCurrent() {
        current.willMove(toParent: nil)
        current.view.removeFromSuperview()
        current.removeFromParent()
    }
}
