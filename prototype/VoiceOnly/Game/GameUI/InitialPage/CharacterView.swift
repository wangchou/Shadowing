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
    var gridSystem: GridSystem = GridSystem(gridCount: gridCount)

    func viewWillAppear() {
        gridSystem = GridSystem(gridCount: gridCount, axisBound: self.frame.width)
        gridSystem.view =  self
        self.backgroundColor = .clear
        self.removeAllSubviews()
        self.roundBorder()

        // bg view
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.yellow.withAlphaComponent(0.5)
        gridSystem.frame(0, 0, 20, 20, backgroundView)
        self.addSubview(backgroundView)

        // status bar
        let statusLayer = UIView()
        statusLayer.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        gridSystem.frame(0, 12, 20, 8, statusLayer)
        self.addSubview(statusLayer)

        let gameCharacter = context.gameCharacter
        addText(1, 13, "Lv.\(gameCharacter.level) \(gameCharacter.name)")
        addText(1, 16, "HP： \(gameCharacter.remainingHP)/\(gameCharacter.maxHP)")
    }

    func addText(_ x: Int, _ y: Int, _ text: String, h: Int = 3) {
        let font = UIFont(name: "Menlo", size: h.c * gridSystem.step * 0.8) ??
                     UIFont.systemFont(ofSize: 20)
        gridSystem.addText(x: x, y: y, w: gridCount - x, h: h, text: text, font: font, color: myWhite)
    }

}
