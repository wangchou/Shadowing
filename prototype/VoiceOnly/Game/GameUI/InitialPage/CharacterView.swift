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

    var lineHeight: CGFloat {
        return gridSystem.step * 3
    }

    var font: UIFont = UIFont.systemFont(ofSize: 20)

    func viewWillAppear() {
        self.backgroundColor = .clear
        gridSystem = GridSystem(axis: .horizontal, gridCount: 20, bounds: frame)
        font = UIFont(name: "Menlo", size: lineHeight * 0.7) ?? font
        self.removeAllSubviews()
        let imageView = UIView()
        imageView.backgroundColor = UIColor.brown
        gridSystem.frame(imageView, x: 0, y: 1, w: 19, h: 18)
        self.addSubview(imageView)

        let statusLayer = UIView()
        statusLayer.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        gridSystem.frame(statusLayer, x: 0, y: 13, w: 19, h: 6)

        self.addSubview(statusLayer)

        addText(" Lv.12", x: 0, y: 13)
        addText(" 白石恵", x: 0, y: 16)
        addText(" HP 123", x: 9, y: 13)
        addText(" MP  23", x: 9, y: 16)
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
