//
//  P8ViewController.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/05.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

// Prototype 8: messenger / line interface
class P08ViewController: UIViewController, GameEventDelegate {
    let game = VoiceOnlyGame.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startEventObserving(self)
        game.play()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopEventObserving(self)
        game.stop()
    }
    
    @objc func onEventHappened(_ notification: Notification) {
        let event = notification.object as! Event
        print(game.state, event.type)
    }
    
}
