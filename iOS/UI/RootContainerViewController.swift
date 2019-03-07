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

class RootContainerViewController: UIViewController {
    static var isShowSetting = false

    var current: UIViewController!
    var splashScreen: UIViewController!
    var languageSelectionScreen: UIViewController!
    var topicSwipablePage: TopicSwipablePage!
    var infiniteChallengeSwipablePage: InfiniteChallengeSwipablePage!

    override func viewDidLoad() {
        super.viewDidLoad()
        splashScreen = getVC("LaunchScreen")

        // swiftlint:disable force_cast
        topicSwipablePage = (getVC(TopicSwipablePage.storyboardId) as! TopicSwipablePage)
        infiniteChallengeSwipablePage = (getVC(InfiniteChallengeSwipablePage.storyboardId) as! InfiniteChallengeSwipablePage)
        // swiftlint:enable force_cast

        current = splashScreen

        showVC(splashScreen)

        loadGameLang()
        loadTopSentencesInfoDB()
        loadDataSets()
        loadGameHistory()
        loadGameSetting()
        loadGameMiscData()

        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            self.showInitialPage()
        }
    }

    private func showInitialPage() {
        if gameLang == .unset {
            languageSelectionScreen = getVC("InitialLanguageSelectionScreen")
            showVC(languageSelectionScreen)
            return
        }

        if gameLang.isSupportTopicMode {
            showMainPage()
        } else {
            showInfiniteChallengePage()
        }
    }

    func showMainPage(isShowSetting: Bool = false) {
        guard current != topicSwipablePage else { return }
        removeCurrent()
        current = topicSwipablePage
        let sp: TopicSwipablePage! = topicSwipablePage
        if !sp.pages.isEmpty {
            let idx = isShowSetting ? 0 : 1
            sp.setViewControllers([sp.pages[idx]], direction: .reverse, animated: false, completion: nil)
        }
        showVC(current)
    }

    func showInfiniteChallengePage(isShowSetting: Bool = false) {
        guard current != infiniteChallengeSwipablePage else { return }
        removeCurrent()
        current = infiniteChallengeSwipablePage
        let sp: InfiniteChallengeSwipablePage! = infiniteChallengeSwipablePage
        if !sp.pages.isEmpty {
            let idx = isShowSetting ? 0 : 1
            sp.setViewControllers([sp.pages[idx]], direction: .reverse, animated: false, completion: nil)
        }

        showVC(current)
    }

    func reloadTableData() {
        let sp0 = topicSwipablePage!
        if !sp0.pages.isEmpty,
           let listPage = (sp0.pages[1] as? TopicsListPage),
            listPage.isLoaded {
            listPage.sentencesTableView.reloadData()
        }
        let sp1 = infiniteChallengeSwipablePage!
        if !sp1.pages.isEmpty,
            let listPage = (sp1.pages[1] as? InfiniteChallengeListPage),
            listPage.isLoaded {
            listPage.tableView.reloadData()
        }
    }

    func rerenderTopView() {
        let sp0: TopicSwipablePage! = topicSwipablePage
        if !sp0.pages.isEmpty,
            let listPage = (sp0.pages[1] as? TopicsListPage) {
            listPage.topChartView.viewWillAppear()
            listPage.topChartView.animateProgress()
        }
        let sp1: InfiniteChallengeSwipablePage! = infiniteChallengeSwipablePage
        if !sp1.pages.isEmpty,
            let listPage = (sp1.pages[1] as? InfiniteChallengeListPage) {
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
