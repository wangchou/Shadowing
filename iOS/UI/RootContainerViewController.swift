//
//  RootContainerViewController.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 10/18/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

class RootContainerViewController: UIViewController {
    var current: UIViewController!
    var splashScreen: SplashScreenViewController!
    var swipablePage: SwipablePage!
    var settingPage: SettingPage!
    var medalPage: MedalPage!
    var topicListPage: TopicListPage!
    var topicDetailPage: TopicDetailPage!
    var icListPage: InfiniteChallengeListPage!
    var icDetailPage: InfiniteChallengeDetailPage!

    override func viewDidLoad() {
        super.viewDidLoad()
        pt("rootVC \(#function) - \(#line)")

        splashScreen = getVC("LaunchScreen") as? SplashScreenViewController
        transition(to: splashScreen)

        settingPage = getVC("SettingPage") as? SettingPage
        medalPage = getVC("MedalPage") as? MedalPage

        topicListPage = getVC("TopicListPage") as? TopicListPage
        topicDetailPage = getVC("TopicDetailPage") as? TopicDetailPage
        icListPage = getVC("InfiniteChallengeListPage") as? InfiniteChallengeListPage
        icDetailPage = getVC("InfiniteChallengeDetailPage") as? InfiniteChallengeDetailPage

        swipablePage = SwipablePage(transitionStyle: .scroll, navigationOrientation: .horizontal)

        splashScreen.launched.always { [weak self] in
            pt("rootVC \(#function) - \(#line)")
            self?.loadStartupData()
            self?.showInitialPage()
            pt("rootVC \(#function) - \(#line)")
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        pt("rootVC \(#function) - \(#line)")
    }

    private func loadStartupData() {
        initDB()
        loadGameLang()
        loadGameSetting()

        SpeechEngine.shared.preloadTTSVoice(voiceIds: [
            GameContext.shared.gameSetting.teacher,
            GameContext.shared.gameSetting.assistant
        ])

        loadMedalCount()
        loadTopicSentenceDB()
        loadDifficultyInfo()
        buildDataSets()

        loadGameHistory()
        loadGameMiscData(isLoadKana: true)
    }

    private func showInitialPage() {
        showSwipablePage(idx: 1, tabMode: gameLang.isSupportTopicMode ? .topics : .infiniteChallenge)
    }

    func showSwipablePage(idx: Int, tabMode: UITabMode) {
        let sp: SwipablePage! = swipablePage
        let isSameTabMode = GameContext.shared.bottomTab == tabMode
        GameContext.shared.bottomTab = tabMode
        if !sp.isPagesReady {
            sp.prepare(idx: idx, mode: tabMode)
            transition(to: sp)
        } else if !isSameTabMode {
            sp.prepare(idx: idx, mode: tabMode)
            sp.reload()
        } else {
            sp.setViewControllers([sp.pages[idx]], direction: .reverse, animated: true, completion: nil)
        }
    }

    func reloadTableData() {
        if let listPage = topicListPage {
            listPage.sentencesTableView?.reloadData()
        }
        if let listPage = icListPage {
            listPage.tableView?.reloadData()
        }
    }

    func rerenderTopView(updateByRecords: Bool = false) {
        if let listPage = topicListPage {
            if updateByRecords { listPage.topChartView?.updateByRecords() }
            listPage.topChartView?.renderWithoutUpdateData()
        }
        if let listPage = icListPage {
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
                if let vc = vc as? TopicListPage {
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

        let old = current
        current = vc

        //print(children)
        // remove old
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
            DispatchQueue.main.async {
                old?.willMove(toParent: nil)
                old?.view.removeFromSuperview()
                old?.removeFromParent()
            }
        }
    }
}
