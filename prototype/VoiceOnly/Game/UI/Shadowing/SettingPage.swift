//
//  SettingPage.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 9/21/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

class SettingPage: UIViewController {
    @IBOutlet weak var topBarView: TopBarView!

    override func viewDidLoad() {
        super.viewDidLoad()
        topBarView.titleLabel.text = "設定"
        topBarView.leftButton.isHidden = true
    }
}
