//
//  CharacterView.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/25.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

// square view, w == h
// 20 x 20 grid system
private let gridCount = 20
private let context = GameContext.shared

class CharacterView: UIView, ReloadableView, GridLayout {
    var gridCount: Int = 20
    var axis: GridAxis = .horizontal
    var imageView: UIImageView?

    func viewWillAppear() {
        backgroundColor = .clear
        removeAllSubviews()
        roundBorder()

        // bg view
        imageView = UIImageView()
        guard let imageView = imageView else { return }
        layout(0, 0, 20, 20, imageView)
        imageView.backgroundColor = myBlue.withAlphaComponent(0.2)

        if let image = context.characterImage {
            imageView.image = image
            imageView.contentMode = .scaleAspectFill
        }

        addSubview(imageView)

        addRect(x: 0, y: 12, w: 20, h: 8, color: UIColor.black.withAlphaComponent(0.5))

        let gameCharacter = context.gameCharacter
        addLabel(1, 13, "Lv.\(gameCharacter.level) \(gameCharacter.name)")
        addLabel(1, 16, "HP： \(gameCharacter.remainingHP)/\(gameCharacter.maxHP)")
    }

    func addLabel(_ x: Int, _ y: Int, _ text: String, h: Int = 3) {
        let font = UIFont(name: "Menlo", size: h.c * step * 0.8) ??
                     UIFont.systemFont(ofSize: 20)
        addText(x: x, y: y, w: gridCount - x, h: h, text: text, font: font, color: myWhite)
    }
}
