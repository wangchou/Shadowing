//
//  ChatView.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 9/6/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

private let context = GameContext.shared

enum FaceExpression: String {
    case beforeTalk = "beforeTalk.png"
    case talking = "talking.png"
    case wrong = "wrong.png"
    case listening = "listening.png"
    case cannotHear = "cannotHear.png"
}

class ChatView: UIView, ReloadableView, GridLayout {
    let gridCount: Int = 48
    let axis: GridAxis = .horizontal
    let spacing: CGFloat = 0
    var pNextString: String = "等下請唸框框中的台詞"
    var nextString: String {
        get {
            return pNextString
        }
        set {
            pNextString = newValue
            viewWillAppear()
        }
    }
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
        addDialog(4, 63, nextString)
        addLabel(4, 58, "\(context.sentenceIndex + 1)/\(context.sentences.count)")
    }

    func updateFace(_ expression: FaceExpression) {
        layer.contents = UIImage(named: expression.rawValue)?.cgImage
    }

    func addDialog(_ x: Int, _ y: Int, _ text: String) {
        addRoundRect(x: x, y: y, w: 42, h: 18, borderColor: .black, radius: 10, backgroundColor: UIColor.white.withAlphaComponent(0.5))

        addLabel(x, y, text) { label in
            label.sizeToFit()
            label.centerIn(self.getFrame(x, y, 42, 18))
        }
    }

    func addLabel(_ x: Int, _ y: Int, _ text: String, completion: ((UIView) -> Void)? = nil) {
        addText(x: x, y: y, w: 18, h: 6, text: text, font: font, color: .black, completion: completion)
    }
}