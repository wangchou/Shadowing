//
//  DataPageViewController.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/26.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//
// from https://www.youtube.com/watch?v=9BKwrOoIOcA

import UIKit

class TopicSwipablePage: UIPageViewController {
    static let storyboardId = "MainSwipablePage"
    var pages = [UIViewController]()

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
        addPage("ShadowingListPage")
        addPage("GameContentDetailPage")
        let idx = RootContainerViewController.isShowSetting ? 0 : 1
        setViewControllers([pages[idx]], direction: .forward, animated: true, completion: nil)

        dataSource = self

        // https://stackoverflow.com/questions/43416456/using-uislider-inside-uipageviewcontroller
        for view in self.view.subviews where view is UIScrollView {
            (view as? UIScrollView)?.delaysContentTouches = false
        }
    }
}

extension TopicSwipablePage: UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = pages.index(of: viewController),
           index + 1 < pages.count {
            return pages[index + 1]
        }
        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = pages.index(of: viewController),
            index - 1 >= 0 {
            return pages[index - 1]
        }
        return nil
    }
}
