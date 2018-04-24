//
//  P1ViewController.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/04/24.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

class P2ViewController: UIViewController {
    let audioController: AudioController = AudioController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("P2 viewDidLoad")
        audioController.start()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        audioController.stop()
        print("P2 viewDidDisappear")
    }
}
