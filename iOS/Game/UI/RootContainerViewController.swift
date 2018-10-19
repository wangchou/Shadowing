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
    var current: UIPageViewController!
    var mainSwipablePage: MainSwipablePage!
    var infiniteChallengeSwipablePage: InfiniteChallengeSwipablePage!

    override func viewDidLoad() {
        super.viewDidLoad()
        mainSwipablePage = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: MainSwipablePage.storyboardId) as! MainSwipablePage

        infiniteChallengeSwipablePage = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: InfiniteChallengeSwipablePage.storyboardId) as! InfiniteChallengeSwipablePage
        current = mainSwipablePage
        addCurrent()

//        // memory leak test
//        var repeatTime = 30
//        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
//            guard repeatTime > 0 else { return }
//            repeatTime -= 1
//            if self.current == self.mainSwipablePage {
//                self.showInfiniteChallengePage()
//            } else {
//                self.showMainPage()
//            }
//        }
    }

    func showMainPage() {
        guard current != mainSwipablePage else { return }
        removeCurrent()
        current = mainSwipablePage
        addCurrent()
    }

    func showInfiniteChallengePage() {
        guard current != infiniteChallengeSwipablePage else { return }
        removeCurrent()
        current = infiniteChallengeSwipablePage
        addCurrent()
    }

    private func addCurrent() {
        addChild(current)
        current.view.frame = view.bounds
        view.addSubview(current.view)
        current.didMove(toParent: self)
    }

    private func removeCurrent() {
        current.willMove(toParent: nil)
        current.view.removeFromSuperview()
        current.removeFromParent()
    }

}
