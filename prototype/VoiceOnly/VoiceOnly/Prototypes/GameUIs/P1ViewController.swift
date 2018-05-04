//
//  P1ViewController.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/04/24.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

// Prototype 1: 全語音、只能用講電話的方式
class P1ViewController: UIViewController {
    let game = VoiceOnlyFlow.shared
    let eventCenter = EventCenter.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        game.play()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        game.stop()
    }
}
