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
    var lineHeight: CGFloat {
        return gridSystem.step * 4
    }
    var font: UIFont = UIFont.systemFont(ofSize: 20)

    func viewWillAppear() {
        font = UIFont(name: "Menlo", size: lineHeight * 0.8) ?? font
        gridSystem = GridSystem(axis: .horizontal, gridCount: 48, bounds: self.frame)
        // grid system setting
        self.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        self.removeAllSubviews()
        addBackButton()
        addText("涼宮ハルヒ", row: 0, column: 0)
        addText("HP:    121", row: 1, column: 6)
        addText("MP:    121", row: 2, column: 6)
        addText("EXP: 12121", row: 3, column: 6)
        addText("STR:    21", row: 4, column: 6)
        addText("DEF:    13", row: 5, column: 6)
        addText("Lv. 11", row: 4, column: 1)
        addText("10022 G", row: 5, column: 1)

        let scrollView = UIScrollView()
        scrollView.backgroundColor = myOrange
        scrollView.roundBorder()
        gridSystem.frame(scrollView, x: 0, y: 24, w: 48, h: 33)
        self.addSubview(scrollView)

        addText("説明はここにいます。", row: 15, column: 0)
    }

    func addText(_ text: String, row: Int, column: Int) {
        let label = UILabel()
        label.font = font
        label.textColor = myLightText
        label.text = text
        gridSystem.frame(label, x: column * 4 + 4, y: row * 4, w: 40, h: 4)
        self.addSubview(label)
    }

    func addBackButton() {
        let backButton = UIButton()
        backButton.setTitle("X", for: .normal)
        backButton.titleLabel?.font = MyFont.systemFont(ofSize: gridSystem.step * 4)
        backButton.titleLabel?.textColor = myLightText
        gridSystem.frame(backButton, x: -6, y: 0, w: 4, h: 4)
        self.addSubview(backButton)
        let backButtonTap = UITapGestureRecognizer(target: self, action: #selector(self.backButtonTapped))
        backButton.addGestureRecognizer(backButtonTap)
    }

    @objc func backButtonTapped() {
        UIApplication.getPresentedViewController()?.dismiss(animated: true, completion: nil)
    }
}
