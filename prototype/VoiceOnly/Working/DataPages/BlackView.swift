//
//  BlackView.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/27.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

private let context = GameContext.shared

extension String {
    func padWidthTo(_ width: Int) -> String {
        let padCount = max(width - self.count, 0)
        var leftPadSpace = ""
        for _ in 1...padCount { leftPadSpace += " " }

        return leftPadSpace + self
    }
}

class BlackView: UIView, ReloadableView {
    var gridSystem: GridSystem = GridSystem()
    var lineHeight: CGFloat {
        return gridSystem.step * 4
    }
    var font: UIFont = UIFont.systemFont(ofSize: 20)

    func viewWillAppear() {
        gridSystem = GridSystem(axis: .horizontal, gridCount: 48, bounds: self.frame)
        font = UIFont(name: "Menlo", size: lineHeight * 0.8) ?? font

        // grid system setting
        self.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.removeAllSubviews()
        addBackButton()

        // left side
        let player = context.gameCharacter
        addText(player.name, row: 1, column: 0)
        addText("\(player.gold) G".padWidthTo(7), row: 6, column: 0)

        // right side
        let rightColumnStart = 5
        addText("Lv.\(player.level)", row: 3, column: rightColumnStart)

        addText("HP:", row: 4, column: rightColumnStart)
        addText("\(player.maxHP)".padWidthTo(6), row: 4, column: rightColumnStart + 2)

        addText("EXP:", row: 5, column: rightColumnStart)
        addText("\(player.exp)".padWidthTo(6), row: 5, column: rightColumnStart + 2)
        addText("DEF:    13", row: 6, column: 5)

        let scrollView = UIScrollView()
        scrollView.backgroundColor = myGray.withAlphaComponent(0.7)
        scrollView.roundBorder()
        gridSystem.frame(scrollView, x: 1, y: 29, w: 46, h: 33)
        self.addSubview(scrollView)

        addText("説明はここにいます。", row: 16, column: 0)
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
        let gridWidth = 6
        let lineHeight = gridSystem.step * gridWidth.c

        backButton.setTitle("x", for: .normal)
        backButton.setTitleColor(.white, for: .normal)
        backButton.roundBorder(borderWidth: 1.5, cornerRadius: lineHeight/2, color: .black)
        backButton.backgroundColor = UIColor.gray
        backButton.titleLabel?.font = UIFont(name: "HiraMaruProN-W4", size: lineHeight * 0.85) ?? font
        backButton.contentVerticalAlignment = .top
        gridSystem.frame(backButton, x: -7, y: 4, w: gridWidth, h: gridWidth)
        self.addSubview(backButton)
        let backButtonTap = UITapGestureRecognizer(target: self, action: #selector(self.backButtonTapped))
        backButton.addGestureRecognizer(backButtonTap)
    }

    @objc func backButtonTapped() {
        UIApplication.getPresentedViewController()?.dismiss(animated: true, completion: nil)
        UIApplication.shared.statusBarStyle = .default
    }
}
