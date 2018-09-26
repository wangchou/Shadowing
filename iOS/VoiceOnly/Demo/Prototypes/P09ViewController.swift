//
//  P9ViewController.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/05.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

private let context = GameContext.shared
// Prototype 9: article reader
class P09ViewController: UIViewController, GameEventDelegate {
    let game = VoiceOnlyGame.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        startEventObserving(self)
        game.start()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopEventObserving(self)
        game.stop()
    }

    @objc func onEventHappened(_ notification: Notification) {
        guard let event = notification.object as? Event else { return }
        print(context.gameState, event.type)
    }

}
