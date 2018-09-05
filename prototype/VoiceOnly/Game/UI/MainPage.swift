//
//  MainPage.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 9/5/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//
import UIKit

private let context = GameContext.shared

class MainPage: UIViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (view as? MainView)?.viewWillAppear()
    }
}
