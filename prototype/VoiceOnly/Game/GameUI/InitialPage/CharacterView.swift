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
        return gridSystem.step * 2
    }

    var font: UIFont = UIFont.systemFont(ofSize: 20)

    func viewWillAppear() {
        font = UIFont(name: "Menlo", size: lineHeight * 0.8) ?? font
        gridSystem = GridSystem(axis: .horizontal, gridCount: 20, bounds: frame)
        self.removeAllSubviews()

        addText("Lv.12", x: 2, y: 15)
        addText("白石恵", x: 2, y: 17)
        addText("HP: 123", x: 11, y: 15)

        addText("MP:  23", x: 11, y: 17)

        let imageView = UIView()
        imageView.backgroundColor = UIColor.brown
        gridSystem.frame(imageView, x: 2, y: 2, w: 16, h: 12)
        self.addSubview(imageView)
    }

    func addText(_ text: String, x: Int, y: Int) {
        let label = UILabel()
        label.font = font
        label.text = text
        gridSystem.frame(label, x: x, y: y, w: stepCount - x, h: 2)
        self.addSubview(label)
    }

}
