//
//  CharacterStatusPageController.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/27.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

class CharacterPageController: UIViewController {
    @IBOutlet var blackView: BlackView!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        blackView.viewWillAppear()
    }
}
