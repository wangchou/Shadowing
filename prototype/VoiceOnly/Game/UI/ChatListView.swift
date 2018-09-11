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

class ChatListView: UIView, ReloadableView, GridLayout {
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
        self.layer.contents = UIImage(named: "ChatListScreen.png")?.cgImage
        frame = CGRect(x: 0, y: 0, width: screen.width, height: screen.height)
        removeAllSubviews()
        addDevelopingLabel()
        addRoundButton(4, 60, "001", #selector(self.oneButtonClicked))
        addRoundButton(27, 60, "002", #selector(self.twoButtonClicked))
    }

    func addRoundButton(_ x: Int, _ y: Int, _ text: String, _ selector: Selector?) {
        let buttonSize = 18
        addRoundRect(x: x, y: y, w: buttonSize, h: buttonSize, borderColor: .black, radius: 10, backgroundColor: UIColor.white.withAlphaComponent(0.5))

        addLabel(x, y, text) { label in
            label.sizeToFit()
            label.centerIn(self.getFrame(x, y, buttonSize, buttonSize))
        }

        let buttonRect = UIView()
        layout(x, y, buttonSize, buttonSize, buttonRect)
        let buttonTap = UITapGestureRecognizer(target: self, action: selector)
        buttonRect.addGestureRecognizer(buttonTap)
        self.addSubview(buttonRect)
    }

    @objc func oneButtonClicked() {
        if let vc = UIApplication.getPresentedViewController() {
            launchStoryboard(vc, "ChatGame")
        }
    }
    @objc func twoButtonClicked() {
        if let vc = UIApplication.getPresentedViewController() {
            launchStoryboard(vc, "ChatGame")
        }
    }

    func addLabel(_ x: Int, _ y: Int, _ text: String, completion: ((UIView) -> Void)? = nil) {
        addText(x: x, y: y, w: 18, h: 6, text: text, font: font, color: .black, completion: completion)
    }

    func addDevelopingLabel() {
        let label = UILabel()
        label.font = MyFont.bold(ofSize: 32)
        label.textColor = UIColor.black
        label.text = " 会話モード工事中 "
        label.roundBorder(borderWidth: 3, cornerRadius: 5)
        label.backgroundColor = rgb(248, 220, 32)
        layout(4, 45, 41, 10, label)
        self.addSubview(label)
    }
}
