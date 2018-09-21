//
//  DataPageViewController.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/26.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//
// from https://www.youtube.com/watch?v=9BKwrOoIOcA

import UIKit

private let engine = SpeechEngine.shared

class MainSwipablePage: UIPageViewController {

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
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: storyboardId)
            pages.append(vc)
        }
        addPage("SettingPage")
        addPage("ShadowingListPage")
        setViewControllers([pages[1]], direction: .forward, animated: true, completion: nil)

        dataSource = self
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension MainSwipablePage: UIPageViewControllerDataSource {

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

    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pages.count
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

}
