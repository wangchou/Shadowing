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

@IBDesignable
class CharacterView: UIView, ReloadableView, GridLayout {
    var gridCount: Int = 20
    var axis: GridAxis = .horizontal
    var spacing: CGFloat = 0
    var imageView: UIImageView?

    func viewWillAppear() {
        backgroundColor = .clear
        removeAllSubviews()
        roundBorder(borderWidth: 1.5, cornerRadius: step, color: UIColor.black.withAlphaComponent(0.6))

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
    }

    func addLabel(_ x: Int, _ y: Int, _ text: String, h: Int = 3) {
        let font = UIFont(name: "Menlo", size: h.c * step * 0.7) ??
                     UIFont.systemFont(ofSize: 20)
        addText(x: x, y: y, w: gridCount - x, h: h, text: text, font: font, color: myWhite)
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        viewWillAppear()
    }
}
