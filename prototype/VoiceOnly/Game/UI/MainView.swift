//
//  MainView.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 9/5/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

private let context = GameContext.shared

class MainView: UIView, ReloadableView, GridLayout {
    let gridCount: Int = 48
    let axis: GridAxis = .horizontal
    let spacing: CGFloat = 0
    var lineHeight: CGFloat {
        return step * 6
    }
    var fontSize: CGFloat {
        return lineHeight
    }
    var font: UIFont {
        return MyFont.regular(ofSize: fontSize)
    }

    func viewWillAppear() {
        self.layer.contents = UIImage(named: "MainScreen.png")?.cgImage
        frame = CGRect(x: 0, y: 0, width: screen.width, height: screen.height)
        removeAllSubviews()
        addRoundButton(5, 50, "話 題", #selector(self.wataiButtonClicked))
        addRoundButton(27, 50, "会 話", #selector(self.kaiwaiButtonClicked))
    }

    func addRoundButton(_ x: Int, _ y: Int, _ text: String, _ selector: Selector?) {
        addRoundRect(x: x, y: y, w: 18, h: 18, borderColor: .black, radius: 10, backgroundColor: UIColor.white.withAlphaComponent(0.5))

        addLabel(x, y, text) { label in
            label.sizeToFit()
            label.centerIn(self.getFrame(x, y, 18, 18))
        }

        let buttonRect = UIView()
        layout(x, y, 18, 18, buttonRect)
        let buttonTap = UITapGestureRecognizer(target: self, action: selector)
        buttonRect.addGestureRecognizer(buttonTap)
        self.addSubview(buttonRect)
    }

    @objc func wataiButtonClicked() {
        if let vc = UIApplication.getPresentedViewController() {
            launchStoryboard(vc, "ShadowingListPage")
        }
    }
    @objc func kaiwaiButtonClicked() {print(1)}

    func addLabel(_ x: Int, _ y: Int, _ text: String, completion: ((UIView) -> Void)? = nil) {
        addText(x: x, y: y, w: 18, h: 6, text: text, font: font, color: .black, completion: completion)
    }
}
