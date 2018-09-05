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

class BlackView: UIView, ReloadableView, GridLayout {
    let gridCount: Int = 48
    let axis: GridAxis = .horizontal
    let spacing: CGFloat = 0
    var lineHeight: CGFloat {
        return step * 3
    }
    var fontSize: CGFloat {
        return lineHeight * 0.8
    }
    var font: UIFont {
        return UIFont(name: "Menlo", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }

    func viewWillAppear() {
        backgroundColor = UIColor.black.withAlphaComponent(0.85)
        frame = CGRect(x: 0, y: 0, width: screen.width, height: screen.height)
        removeAllSubviews()

        renderPlayer()
        renderItems()

        addBackButton()
    }

    func renderPlayer() {
        let player = context.gameCharacter

        var x = 2
        var y = 3
        addPicture(x: x, y: y, w: 21)

        y += 22
        addRoundRect(x: x, y: y, w: 21, h: 5, borderColor: .white, backgroundColor: UIColor.black.withAlphaComponent(0.5))
        addLabel(x+2, y+1, player.name) { label in
            label.sizeToFit()
            label.centerIn(self.getFrame(x, y, 21, 5))
        }

        // right side
        y = 10
        x = 25
        addRoundRect(x: x, y: y, w: 21, h: 5, borderColor: .white, backgroundColor: UIColor.black.withAlphaComponent(0.5))
        addLabel(x+2, y+1, "100 G".padWidthTo(12))

        y = 16
        addRoundRect(x: x, y: y, w: 21, h: 14, borderColor: .white, radius: step * 3, backgroundColor: UIColor.black.withAlphaComponent(0.5))

        addLabel(x+2, y+1, "Level: \(player.level)")
        addLabel(x+2, y+4, "HP :" + "\(player.remainingHP)/\(player.maxHP)".padWidthTo(8))
        addLabel(x+2, y+7, "DEF:" + "22".padWidthTo(8))
        addLabel(x+2, y+10, "EXP:" + "\(player.exp)".padWidthTo(8) )
    }

    func addPicture(x: Int, y: Int, w: Int) {
        let imageView = UIImageView()
        layout(x, y, w, w, imageView)
        imageView.backgroundColor = myBlue.withAlphaComponent(0.2)
        imageView.roundBorder(borderWidth: 0, cornerRadius: step*3, color: .clear)

        if let image = context.characterImage {
            imageView.image = image
            imageView.contentMode = .scaleAspectFill
        }

        addSubview(imageView)
    }

    func addLabel(_ x: Int, _ y: Int, _ text: String, completion: ((UIView) -> Void)? = nil) {
        addText(x: x, y: y, w: 40, h: 3, text: text, font: font, color: myLightText, completion: completion)
    }

    func renderItems() {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = myGray.withAlphaComponent(0.7)
        scrollView.roundBorder()
        layout(2, 32, 44, 33, scrollView)
        addSubview(scrollView)
        addLabel(2, 66, "説明はここにいます。")
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
        layout(-7, 3, gridWidth, gridWidth, backButton)
        addSubview(backButton)
        let backButtonTap = UITapGestureRecognizer(target: self, action: #selector(self.backButtonTapped))
        backButton.addGestureRecognizer(backButtonTap)
    }

    @objc func backButtonTapped() {
        UIApplication.getPresentedViewController()?.dismiss(animated: true, completion: nil)
    }
}
