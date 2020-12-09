//
//  DataPageViewController.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/26.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//
// from https://www.youtube.com/watch?v=9BKwrOoIOcA

import UIKit

class SwipablePage: UIPageViewController {
    //var idx = 1
    var isTopic = true
    var pages = [UIViewController]()

    var isPagesReady: Bool { return pages.count >= 4 }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        for v in view.subviews where v is UIScrollView {
            v.frame = view.bounds
            break
        }
    }

    func reload() {
        dataSource = nil
        dataSource = self
    }

    func prepare(idx: Int, mode: UITabMode) {
        pages = []
        pages.append(rootViewController.settingPage)
        pages.append(rootViewController.medalPage)
        switch mode {
        case .topics:
            pages.append(rootViewController.topicListPage)
            pages.append(rootViewController.topicDetailPage)
        case .infiniteChallenge:
            pages.append(rootViewController.icListPage)
            pages.append(rootViewController.icDetailPage)
        }

        setViewControllers([pages[idx]], direction: .forward, animated: false, completion: nil)

        dataSource = self

        // https://stackoverflow.com/questions/43416456/using-uislider-inside-uipageviewcontroller
        for view in view.subviews where view is UIScrollView {
            (view as? UIScrollView)?.delaysContentTouches = false
        }
        isTopic = false
    }
}

extension SwipablePage: UIPageViewControllerDataSource {
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
