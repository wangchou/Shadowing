//
//  MedalPage.swift
//  今話したい
//
//  Created by Wangchou Lu on 3/26/31 H.
//  Copyright © 31 Heisei Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

class MedalPage: UIViewController {

    @IBOutlet weak var medalPageView: MedalPageView!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        medalPageView.viewWillAppear()
    }
}
