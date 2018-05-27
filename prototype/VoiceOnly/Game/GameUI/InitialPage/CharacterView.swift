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
    var w = 120.c
    var step: CGFloat {
        return w/stepCount.c
    }
    var lineHeight: CGFloat {
        return step * 2
    }

    var font: UIFont {
        return UIFont(name: "Menlo", size: lineHeight * 0.8) ??
               UIFont.systemFont(ofSize: lineHeight * 0.8)
    }

    func viewWillAppear() {
        self.removeAllSubviews()
        w = self.frame.width
        addLabel("Lv.12", x: 2, y: 15)
        addLabel("白石恵", x: 2, y: 17)
        addLabel("HP: 123", x: 11, y: 15)

        addLabel("MP:  23", x: 11, y: 17)

        let imageView = UIView()
        imageView.backgroundColor = UIColor.brown
        imageView.frame = getFrameBy(x: 2, y: 2, w: 16, h: 12)
        self.addSubview(imageView)
    }

    func addLabel(_ text: String, x: Int, y: Int) {
        let label = UILabel()
        label.font = font
        label.text = text
        label.frame = getFrameBy(x: x, y: y, w: stepCount - x, h: 2)
        self.addSubview(label)
    }

    func getFrameBy(x: Int, y: Int, w: Int, h: Int) -> CGRect {
        return CGRect(
            x: x.c * step,
            y: y.c * step,
            width: w.c * step,
            height: h.c * step
        )
    }
}
