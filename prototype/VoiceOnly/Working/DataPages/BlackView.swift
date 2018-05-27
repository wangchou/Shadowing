//
//  BlackView.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/27.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

class BlackView: UIView {
    var gridSystem: GridSystem = GridSystem()

    func viewWillAppear() {
        gridSystem = GridSystem(axis: .horizontal, gridCount: 48, bounds: self.frame)
        // grid system setting
        self.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        self.removeAllSubviews()
        addBackButton()
    }

    func addBackButton() {
        let backButton = UIButton()
        backButton.setTitle("X", for: .normal)
        backButton.titleLabel?.font = MyFont.systemFont(ofSize: gridSystem.step * 4)
        backButton.titleLabel?.textColor = myLightText
        gridSystem.frame(backButton, x: -4, y: 2, w: 3, h: 3)
        self.addSubview(backButton)
        let backButtonTap = UITapGestureRecognizer(target: self, action: #selector(self.backButtonTapped))
        backButton.addGestureRecognizer(backButtonTap)
    }

    @objc func backButtonTapped() {
        UIApplication.getPresentedViewController()?.dismiss(animated: true, completion: nil)
    }
}
