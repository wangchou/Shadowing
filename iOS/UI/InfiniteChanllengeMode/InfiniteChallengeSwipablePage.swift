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
    static var initialIdx = 1
    var pages = [UIViewController]()

    var isPagesReady: Bool { return pages.count >= 4 }

    var settingPage: SettingPage? {
        return !isPagesReady ? nil : pages[0] as? SettingPage
    }

    var medalPage: MedalPage? {
        return !isPagesReady ? nil : pages[1] as? MedalPage
    }

    var listPage: InfiniteChallengeListPage? {
        return !isPagesReady ? nil : pages[2] as? InfiniteChallengeListPage
    }

    var detailPage: InfiniteChallengeDetailPage? {
        return !isPagesReady ? nil : pages[3] as? InfiniteChallengeDetailPage
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        for v in view.subviews where v is UIScrollView {
            v.frame = view.bounds
            break
        }
    }

    func clear() {
        pages = []
    }

    func prepare() {
        clear()
        pages.append(rootViewController.settingPage)
        pages.append(rootViewController.medalPage)
        pages.append(rootViewController.icListPage)
        pages.append(rootViewController.icDetailPage)

        let idx = RootContainerViewController.isShowSetting ? 0 : InfiniteChallengeSwipablePage.initialIdx
        setViewControllers([pages[idx]], direction: .forward, animated: true, completion: nil)

        dataSource = self

        // https://stackoverflow.com/questions/43416456/using-uislider-inside-uipageviewcontroller
        for view in view.subviews where view is UIScrollView {
            (view as? UIScrollView)?.delaysContentTouches = false
        }
    }
}

extension InfiniteChallengeSwipablePage: UIPageViewControllerDataSource {
    func pageViewController(_: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = pages.firstIndex(of: viewController),
           index + 1 < pages.count {
            return pages[index + 1]
        }
        return nil
    }

    func pageViewController(_: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = pages.firstIndex(of: viewController),
           index - 1 >= 0 {
            return pages[index - 1]
        }
        return nil
    }
}
