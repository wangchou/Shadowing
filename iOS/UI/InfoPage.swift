//
//  InfoPage.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 10/20/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import UIKit

class InfoPage: UIViewController {
    @IBOutlet weak var closeButton: UIButton!
    override func viewDidLoad() {
        closeButton.roundBorder(radius: 25)

    }
    @IBAction func onCloseButtonClicked(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
