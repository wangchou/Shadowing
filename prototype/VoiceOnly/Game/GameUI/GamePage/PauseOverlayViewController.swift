//
//  PauseOverlayViewController.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/13.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

class PauseOverlayViewController: UIViewController {
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var resumeButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        finishButton.layer.borderColor = UIColor.lightText.cgColor
        finishButton.layer.borderWidth = 1.5
        finishButton.layer.cornerRadius = 15
        resumeButton.layer.borderColor = UIColor.lightText.cgColor
        resumeButton.layer.borderWidth = 1.5
        resumeButton.layer.cornerRadius = 15
    }

    @IBAction func finishButtonClicked(_ sender: Any) {
        SimpleGame.shared.stop()
        launchStoryboard(self, "ContentViewController")
    }

    @IBAction func resumeButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        postEvent(.resume)
    }
}
