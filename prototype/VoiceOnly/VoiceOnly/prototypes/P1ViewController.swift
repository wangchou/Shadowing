//
//  P1ViewController.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/04/24.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

class P1ViewController: UIViewController {
    var audio = AudioController.shared
    var flow = FlowController.shared
    override func viewDidLoad() {
        super.viewDidLoad()
        print("P1 viewDidLoad")
        audio.start()
        flow.repeatAfterMe()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("P1 viewDidDisappear")
        audio.stop()
    }
}
