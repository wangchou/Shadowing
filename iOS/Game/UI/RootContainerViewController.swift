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

        loadTopSentencesInfoDB()
        addSentences()
        loadGameHistory()
        loadGameSetting()
        loadGameMiscData()

        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            self.showMainPage()
        }
    }

    func showMainPage() {
        guard current != mainSwipablePage else { return }
        removeCurrent()
        current = mainSwipablePage
        showVC(current)
    }

    func showInfiniteChallengePage() {
        guard current != infiniteChallengeSwipablePage else { return }
        removeCurrent()
        current = infiniteChallengeSwipablePage
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
