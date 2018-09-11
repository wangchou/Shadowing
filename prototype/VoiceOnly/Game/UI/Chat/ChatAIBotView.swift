//
//  ChatBotPage.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 9/11/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

class ChatAIBotView: UIView, ReloadableView, GridLayout {
    let gridCount: Int = 48
    let axis: GridAxis = .horizontal
    let spacing: CGFloat = 0
    var voiceButton: UIButton!
    var pFaceExpression: FaceExpression = .beforeTalk
    var faceExpression: FaceExpression {
        get {
            return pFaceExpression
        }
        set {
            pFaceExpression = newValue
            updateFace(newValue)
        }
    }

    var lineHeight: CGFloat {
        return step * 3
    }

    var fontSize: CGFloat {
        return lineHeight
    }

    var font: UIFont {
        return MyFont.regular(ofSize: fontSize)
    }

    func viewWillAppear() {
        updateFace(faceExpression)
        removeAllSubviews()
        addVoiceButton()
    }

    @objc func onButtonDown() {
        updateFace(.listening)
        voiceButton.backgroundColor = UIColor.red.withAlphaComponent(0.7)
    }

    @objc func onButtonUp() {
        updateFace(.beforeTalk)
        voiceButton.backgroundColor = UIColor.black.withAlphaComponent(0.7)
    }

    func addVoiceButton() {
        let buttonWidth = 15
        voiceButton = UIButton()
        self.addSubview(voiceButton)
        self.layout(18, 67, buttonWidth, buttonWidth, voiceButton)
        voiceButton.roundBorder(borderWidth: 2, cornerRadius: buttonWidth.c / 2 * self.step, color: UIColor.white)
        voiceButton.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        voiceButton.addTarget(self, action: #selector(self.onButtonDown), for: .touchDown)
        voiceButton.addTarget(self, action: #selector(self.onButtonUp), for: .touchUpInside)
        voiceButton.addTarget(self, action: #selector(self.onButtonUp), for: .touchUpOutside)
    }

    func updateFace(_ expression: FaceExpression) {
        layer.contents = UIImage(named: expression.rawValue)?.cgImage
    }
}
