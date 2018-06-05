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

private var gridSystem: GridSystem = GridSystem(gridCount: 48)
private let lineHeight: CGFloat = gridSystem.step * 4
private let fontSize = lineHeight * 0.8
private let font: UIFont = UIFont(name: "Menlo", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)

class BlackView: UIView, ReloadableView {
    func viewWillAppear() {
        backgroundColor = UIColor.black.withAlphaComponent(0.8)
        frame = CGRect(x: 0, y: 0, width: screen.width, height: screen.height)
        gridSystem.view = self
        removeAllSubviews()
        addBackButton()
        renderPlayer()
        renderItems()
    }

    func renderPlayer() {
        let player = context.gameCharacter
        addText(1, 0, player.name)
        addText(6, 0, "\(player.gold) G".padWidthTo(7))

        addText(3, 5, "Lv. \(player.level)")

        addText(4, 5, "HP:")
        addText(4, 7, "\(player.maxHP)".padWidthTo(6))

        addText(5, 5, "EXP:")
        addText(5, 7, "\(player.exp)".padWidthTo(6))

        addText(6, 5, "DEF:    13")
    }

    func addText(_ row: Int, _ column: Int, _ text: String) {
        gridSystem.addText(x: column * 4 + 4, y: row * 4, w: 40, h: 4, text: text, font: font, color: myLightText)
    }

    func renderItems() {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = myGray.withAlphaComponent(0.7)
        scrollView.roundBorder()
        gridSystem.frame(1, 29, 46, 33, scrollView)
        addSubview(scrollView)

        addText(16, 0, "説明はここにいます。")
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
        gridSystem.frame(-7, 4, gridWidth, gridWidth, backButton)
        self.addSubview(backButton)
        let backButtonTap = UITapGestureRecognizer(target: self, action: #selector(self.backButtonTapped))
        backButton.addGestureRecognizer(backButtonTap)
    }

    @objc func backButtonTapped() {
        UIApplication.getPresentedViewController()?.dismiss(animated: true, completion: nil)
        UIApplication.shared.statusBarStyle = .default
    }
}
