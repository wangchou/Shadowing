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
class CharacterView: UIView, ReloadableView {
    var gridSystem: GridSystem = GridSystem()

    func viewWillAppear() {
        self.backgroundColor = .clear
        gridSystem = GridSystem(axis: .horizontal, gridCount: gridCount, bounds: frame)
        self.removeAllSubviews()
        self.roundBorder()

        // bg view
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.brown
        gridSystem.frame(backgroundView, x: 0, y: 0, w: 20, h: 20)
        self.addSubview(backgroundView)

        // status bar
        let statusLayer = UIView()
        statusLayer.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        gridSystem.frame(statusLayer, x: 0, y: 12, w: 20, h: 8)

        self.addSubview(statusLayer)
        let gameCharacter = context.gameCharacter
        addText("Lv.\(gameCharacter.level) \(gameCharacter.name)", x: 1, y: 13)
        addText("HP： \(gameCharacter.remainingHP)/\(gameCharacter.maxHP)", x: 1, y: 16)
    }

    func addText(_ text: String, x: Int, y: Int, lineHeight: Int = 3) {
        let label = UILabel()
        label.font = UIFont(name: "Menlo", size: lineHeight.c * gridSystem.step * 0.7) ??
                     UIFont.systemFont(ofSize: 20)
        label.text = text
        label.textColor = myWhite
        gridSystem.frame(label, x: x, y: y, w: gridCount - x, h: lineHeight)
        self.addSubview(label)
    }

}
