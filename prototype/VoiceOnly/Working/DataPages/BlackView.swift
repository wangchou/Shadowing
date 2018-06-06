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

class BlackView: UIView, ReloadableView, GridLayout {
    let gridCount: Int = 48
    let axis: GridAxis = .horizontal
    var lineHeight: CGFloat {
        return step * 4
    }
    var fontSize: CGFloat {
        return lineHeight * 0.8
    }
    var font: UIFont {
        return UIFont(name: "Menlo", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }

    func viewWillAppear() {
        backgroundColor = UIColor.black.withAlphaComponent(0.8)
        frame = CGRect(x: 0, y: 0, width: screen.width, height: screen.height)
        removeAllSubviews()
        addBackButton()
        renderPlayer()
        renderItems()
    }

    func renderPlayer() {
        let player = context.gameCharacter
        addLabel(1, 0, player.name)
        addLabel(6, 0, "\(player.gold) G".padWidthTo(7))

        addLabel(3, 5, "Lv. \(player.level)")

        addLabel(4, 5, "HP:")
        addLabel(4, 7, "\(player.maxHP)".padWidthTo(6))

        addLabel(5, 5, "EXP:")
        addLabel(5, 7, "\(player.exp)".padWidthTo(6))

        addLabel(6, 5, "DEF:    13")
    }

    func addLabel(_ row: Int, _ column: Int, _ text: String) {
        addText(x: column * 4 + 4, y: row * 4, w: 40, h: 4, text: text, font: font, color: myLightText)
    }

    func renderItems() {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = myGray.withAlphaComponent(0.7)
        scrollView.roundBorder()
        layout(1, 29, 46, 33, scrollView)
        addSubview(scrollView)
        addLabel(16, 0, "説明はここにいます。")
    }

    func addBackButton() {
        let backButton = UIButton()
        let gridWidth = 6
        let lineHeight = step * gridWidth.c

        backButton.setTitle("x", for: .normal)
        backButton.setTitleColor(.white, for: .normal)
        backButton.roundBorder(borderWidth: 1.5, cornerRadius: lineHeight/2, color: .black)
        backButton.backgroundColor = UIColor.gray
        backButton.titleLabel?.font = UIFont(name: "HiraMaruProN-W4", size: lineHeight * 0.85) ?? font
        backButton.contentVerticalAlignment = .top
        layout(-7, 4, gridWidth, gridWidth, backButton)
        addSubview(backButton)
        let backButtonTap = UITapGestureRecognizer(target: self, action: #selector(self.backButtonTapped))
        backButton.addGestureRecognizer(backButtonTap)
    }

    @objc func backButtonTapped() {
        UIApplication.getPresentedViewController()?.dismiss(animated: true, completion: nil)
    }
}
