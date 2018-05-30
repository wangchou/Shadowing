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
private let stepCount = 20
class CharacterView: UIView {
    var gridSystem: GridSystem = GridSystem()
    var backgroundView: UIView!

    var lineHeight: CGFloat {
        return gridSystem.step * 3
    }

    var font: UIFont = UIFont.systemFont(ofSize: 20)

    func viewWillAppear() {
        self.backgroundColor = .clear
        gridSystem = GridSystem(axis: .horizontal, gridCount: 20, bounds: frame)
        font = UIFont(name: "Menlo", size: lineHeight * 0.7) ?? font
        self.removeAllSubviews()
        self.roundBorder()

        // bg view
        backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.brown
        gridSystem.frame(backgroundView, x: 0, y: 0, w: 20, h: 20)
        self.addSubview(backgroundView)

        // status bar
        let statusLayer = UIView()
        statusLayer.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        gridSystem.frame(statusLayer, x: 0, y: 12, w: 20, h: 8)

        self.addSubview(statusLayer)
        addText("Lv.12 涼宮ハルヒ", x: 1, y: 13)
        addText("HP： 105/123", x: 1, y: 16)
    }

    func addText(_ text: String, x: Int, y: Int) {
        let label = UILabel()
        label.font = font
        label.text = text
        label.textColor = myWhite
        gridSystem.frame(label, x: x, y: y, w: stepCount - x, h: 3)
        self.addSubview(label)
    }

}
