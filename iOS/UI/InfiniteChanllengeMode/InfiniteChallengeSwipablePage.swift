//
//  DataPageViewController.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/26.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//
// from https://www.youtube.com/watch?v=9BKwrOoIOcA

import UIKit

class InfiniteChallengeSwipablePage: UIPageViewController {
    static let storyboardId = "InfiniteChallengeSwipablePage"
    static var initialIdx = 1
    var pages = [UIViewController]()

    var isPagesReady: Bool { return pages.count >= 4}

    var settingPage: SettingPage? {
        return !isPagesReady ? nil : pages[0] as? SettingPage
    }
    var medalPage: MedalPage? {
        return !isPagesReady ? nil : pages[1] as? MedalPage
    }
    var listPage: InfiniteChallengeListPage? {
        return !isPagesReady ? nil : pages[2] as? InfiniteChallengeListPage
    }
    var detailPage: InfiniteChallengePage? {
        return !isPagesReady ? nil : pages[3] as? InfiniteChallengePage
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        for v in view.subviews where v is UIScrollView {
            v.frame = view.bounds
            break
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        func addPage(_ storyboardId: String) {
            pages.append(getVC(storyboardId))
        }
        addPage("SettingPage")
        addPage("MedalPage")
        addPage("InfiniteChallengeListPage")
        addPage("InfiniteChallengePage")
        let idx = RootContainerViewController.isShowSetting ? 0 : InfiniteChallengeSwipablePage.initialIdx
        setViewControllers([pages[idx]], direction: .forward, animated: true, completion: nil)

        dataSource = self

        // https://stackoverflow.com/questions/43416456/using-uislider-inside-uipageviewcontroller
        for view in self.view.subviews where view is UIScrollView {
            (view as? UIScrollView)?.delaysContentTouches = false
        }
    }
}

extension InfiniteChallengeSwipablePage: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = pages.firstIndex(of: viewController),
            index + 1 < pages.count {
            return pages[index + 1]
        }
        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = pages.firstIndex(of: viewController),
            index - 1 >= 0 {
            return pages[index - 1]
        }
        return nil
    }
}
