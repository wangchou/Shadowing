//
//  PauseOverlayViewController.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/13.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

private let context = GameContext.shared

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
        ShadowingFlow.shared.stop()
        if context.gameFlowMode == .shadowing {
            launchStoryboard(self, "ShadowingListPage")
        } else {
            launchStoryboard(self, "MainPage")
        }
    }

    @IBAction func resumeButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        postEvent(.resume)
    }
}
