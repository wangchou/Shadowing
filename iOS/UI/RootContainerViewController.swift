//
//  RootContainerViewController.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 10/18/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation
import Promises
import Speech
import UIKit

class RootContainerViewController: UIViewController {
    static var isLoaded = Promise<Void>.pending()
    static var isShowSetting = false

    var current: UIViewController!
    var splashScreen: SplashScreenViewController!
    var topicSwipablePage: TopicSwipablePage!
    var infiniteChallengeSwipablePage: InfiniteChallengeSwipablePage!

    override func viewDidLoad() {
        super.viewDidLoad()

        // swiftlint:disable force_cast
        splashScreen = (getVC("LaunchScreen") as! SplashScreenViewController)
        transition(to: splashScreen)
        // swiftlint:enable force_cast

        topicSwipablePage = TopicSwipablePage(transitionStyle: .scroll, navigationOrientation: .horizontal)
        infiniteChallengeSwipablePage = InfiniteChallengeSwipablePage(transitionStyle: .scroll, navigationOrientation: .horizontal)

        splashScreen.launched.always { [weak self] in
            self?.loadStartupData()
            self?.showInitialPage()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    private func loadStartupData() {
        let t1 = getNow()
        initDB()
        loadGameLang()
        loadGameSetting()
        SpeechEngine.shared.preloadTTSVoice()

        loadMedalCount()

        loadTopicSentenceDB()
        loadDifficultyInfo()
        buildDataSets()

        loadGameHistory()
        loadGameMiscData(isLoadKana: true)
        print("\nstartup load time: \(getNow() - t1)")
    }

    private func showInitialPage() {
        if gameLang.isSupportTopicMode {
            showTopicPage(idx: 1)
        } else {
            showInfiniteChallengePage(idx: 1)
        }
    }

    func showTopicPage(idx: Int) {
        guard current != topicSwipablePage else { return }
        let sp: TopicSwipablePage! = topicSwipablePage
        if sp.isPagesReady {
            sp.setViewControllers([sp.pages[idx]], direction: .reverse, animated: false, completion: nil)
        } else {
            TopicSwipablePage.initialIdx = idx
        }
        transition(to: sp)
    }

    func showInfiniteChallengePage(idx: Int) {
        guard current != infiniteChallengeSwipablePage else { return }
        let sp: InfiniteChallengeSwipablePage! = infiniteChallengeSwipablePage
        if sp.isPagesReady {
            sp.setViewControllers([sp.pages[idx]], direction: .reverse, animated: false, completion: nil)
        } else {
            InfiniteChallengeSwipablePage.initialIdx = idx
        }

        transition(to: sp)
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

    func transition(to vc: UIViewController) {
        // create new
        addChild(vc)
        vc.view.frame = view.bounds
        view.addSubview(vc.view)
        vc.didMove(toParent: self)

        current = vc

        //print(children)
        // remove old
//        old?.willMove(toParent: nil)
//        old?.view.removeFromSuperview()
//        old?.removeFromParent()
    }
}
