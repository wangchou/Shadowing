//
//  SplashScreenViewController.swift
//  今話したい
//
//  Created by Wangchou Lu on 4/8/31 H.
//  Copyright © 31 Heisei Lu, WangChou. All rights reserved.
//

import Promises
import UIKit

class SplashScreenViewController: UIViewController {
    var launched = Promise<Void>.pending()
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        launched.fulfill(())
    }
}
