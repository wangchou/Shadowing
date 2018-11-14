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
    var splashScreen: UIViewController!
    var mainSwipablePage: MainSwipablePage!
    var infiniteChallengeSwipablePage: InfiniteChallengeSwipablePage!

    override func viewDidLoad() {
        super.viewDidLoad()

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
        if isShowSetting &&
           !infiniteChallengeSwipablePage.pages.isEmpty {
            infiniteChallengeSwipablePage.setViewControllers([infiniteChallengeSwipablePage.pages[0]], direction: .reverse, animated: false, completion: nil)
        }

        showVC(current)
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
