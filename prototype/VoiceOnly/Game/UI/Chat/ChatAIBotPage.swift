//
//  ChatAIBotPage.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 9/11/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit
class ChatAIBotPage: UIViewController {
    var chatAIBotView: ChatAIBotView? {
        return (view as? ChatAIBotView)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        chatAIBotView?.viewWillAppear()
    }
}
