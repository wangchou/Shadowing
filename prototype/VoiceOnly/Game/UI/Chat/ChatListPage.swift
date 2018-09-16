//
//  ChatListPage.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 9/5/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//
import UIKit

private let context = GameContext.shared

class ChatListPage: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        (view as? ChatListView)?.viewWillAppear()
    }
}
