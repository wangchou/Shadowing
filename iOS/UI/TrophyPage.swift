//
//  TrophyPage.swift
//  今話したい
//
//  Created by Wangchou Lu on 3/26/31 H.
//  Copyright © 31 Heisei Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

class TrophyPage: UIViewController {

    @IBOutlet weak var trophyPageView: TrophyPageView!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        trophyPageView.viewWillAppear()
    }
}
