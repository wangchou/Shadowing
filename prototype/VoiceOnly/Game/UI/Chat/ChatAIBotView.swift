//
//  ChatBotPage.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 9/11/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit
import Promises
import Alamofire
import SwiftyJSON

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
        _ = meijia("請按著按鈕、然後說日文")
        updateFace(faceExpression)
        removeAllSubviews()
        addVoiceButton()
    }

    func listenAndReply() {
        listenJP(duration: 30)
            .then(getTalkAPIReply)
            .then { reply -> Promise<Void> in
                self.updateFace(.talking)
                self.voiceButton.isEnabled = false
                return hattori(reply)
            }.then {
                self.updateFace(.beforeTalk)
                self.voiceButton.isEnabled = true
            }
    }

    @objc func onButtonDown() {
        faceExpression = .listening
        voiceButton.backgroundColor = UIColor.red.withAlphaComponent(0.7)
        listenAndReply()
    }

    @objc func onButtonUp() {
        faceExpression = .beforeTalk
        voiceButton.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        stopListen()
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

func getTalkAPIReply(_ kanjiString: String) -> Promise<String> {
    let promise = Promise<String>.pending()
    let parameters = [
        "apikey": "DZZDjkWEiLdgnIehTB3cd7BXxcb0L3Ek",
        "query": kanjiString
    ]

    Alamofire.request(
        "https://api.a3rt.recruit-tech.co.jp/talk/v1/smalltalk",
        method: .post,
        parameters: parameters
        ).responseJSON { response in
            switch response.result {
            case .success:
                let json = JSON(response.result.value)
                promise.fulfill(json["results"][0]["reply"].stringValue)

            case .failure:
                promise.fulfill("")
            }
    }
    return promise
}
