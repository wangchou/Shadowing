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
    var current: UIViewController!
    var splashScreen: UIViewController!
    var languageSelectionScreen: UIViewController!
    var mainSwipablePage: MainSwipablePage!
    var infiniteChallengeSwipablePage: InfiniteChallengeSwipablePage!

    override func viewDidLoad() {
        super.viewDidLoad()

        IAPHelper.shared.requsestProducts()

        //print(SFSpeechRecognizer.supportedLocales())

        splashScreen = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "LaunchScreen")

        mainSwipablePage = (UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: MainSwipablePage.storyboardId) as! MainSwipablePage)

        infiniteChallengeSwipablePage = (UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: InfiniteChallengeSwipablePage.storyboardId) as! InfiniteChallengeSwipablePage)
        current = splashScreen
        showVC(splashScreen)

        loadGameLang()
        loadTopSentencesInfoDB()
        loadDataSets()
        loadGameHistory()
        loadGameSetting()
        loadGameMiscData()

        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            if gameLang == .unset {
                self.languageSelectionScreen = UIStoryboard(name: "Main", bundle: nil)
                    .instantiateViewController(withIdentifier: "InitialLanguageSelectionScreen")
                self.showVC(self.languageSelectionScreen)
                return
            }

            if gameLang.isSupportTopicMode {
                self.showMainPage()
            } else {
                self.showInfiniteChallengePage()
            }
        }
    }

    func showMainPage() {
        guard current != mainSwipablePage else { return }
        removeCurrent()
        current = mainSwipablePage
        showVC(current)
    }

    func showInfiniteChallengePage(isShowSetting: Bool = false) {
        guard current != infiniteChallengeSwipablePage else { return }
        removeCurrent()
        current = infiniteChallengeSwipablePage
        let sp: InfiniteChallengeSwipablePage! = infiniteChallengeSwipablePage
        if isShowSetting && !sp.pages.isEmpty {
            sp.setViewControllers([sp.pages[0]], direction: .reverse, animated: false, completion: nil)
        }

        showVC(current)
    }

    func reloadTableData() {
        let sp0: MainSwipablePage! = mainSwipablePage
        if !sp0.pages.isEmpty,
           let listPage = (sp0.pages[1] as? ShadowingListPage) {
            listPage.sentencesTableView.reloadData()
        }
        let sp1: InfiniteChallengeSwipablePage! = infiniteChallengeSwipablePage
        if !sp1.pages.isEmpty,
            let listPage = (sp1.pages[1] as? InfiniteChallengeListPage) {
            listPage.tableView.reloadData()
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
