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
        topicSwipablePage = TopicSwipablePage(transitionStyle: .scroll, navigationOrientation: .horizontal)
        infiniteChallengeSwipablePage = InfiniteChallengeSwipablePage(transitionStyle: .scroll, navigationOrientation: .horizontal)
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
        loadGameMiscData(isLoadKana: true)
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

    func rerenderTopView(updateByRecords: Bool = false) {
        if let listPage = topicSwipablePage.listPage {
            if updateByRecords { listPage.topChartView?.updateByRecords() }
            listPage.topChartView?.renderWithoutUpdateData()
        }
        if let listPage = infiniteChallengeSwipablePage.listPage {
            if updateByRecords { listPage.topChartView?.updateByRecords() }
            listPage.topChartView?.renderWithoutUpdateData()
        }
    }

    func updateWhenEnterForeground() {
        if let pageVC = current as? UIPageViewController {
            if let vc = pageVC.viewControllers?[0] {
                if let vc = vc as? MedalPage {
                    vc.medalPageView?.render()
                }
                if let vc = vc as? TopicsListPage {
                    vc.topChartView?.render()
                    vc.topChartView?.animateProgress()
                }
                if let vc = vc as? InfiniteChallengeListPage {
                    vc.topChartView?.render()
                    vc.topChartView?.animateProgress()
                }
            }
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
