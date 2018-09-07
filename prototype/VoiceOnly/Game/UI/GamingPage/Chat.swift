//
//  Chat.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 9/6/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

private let context = GameContext.shared

// Prototype 8: messenger / line interface
class Chat: UIViewController {
    let game = ChatFlow.shared
    var chatView: ChatView? {
        return (view as? ChatView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        chatView?.viewWillAppear()
        start()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        end()
    }

    func start() {
        startEventObserving(self)
        game.start()
    }

    func end() {
        stopEventObserving(self)
        game.stop()
    }

}

extension Chat: GameEventDelegate {
    @objc func onEventHappened(_ notification: Notification) {
        guard let event = notification.object as? Event else { print("convert event fail"); return }

        switch event.type {
        case .sayStarted:
            guard let text = event.string else { return }
            if context.gameState == .stopped {
                chatView?.faceExpression = .beforeTalk
            } else if context.score.value >= 80 {
                chatView?.faceExpression = .talking
            } else if context.userSaidString == "" {
                chatView?.faceExpression = .cannotHear
            } else {
                chatView?.faceExpression = .wrong
            }
            chatView?.nextString = ""

        case .listenStarted:
            chatView?.faceExpression = .listening
            chatView?.nextString = context.targetString
//            if let tokenInfos = kanaTokenInfosCacheDictionary[text] {
//                //addLabel(getFuriganaString(tokenInfos: tokenInfos), isLeft: false)
//            } else {
//                    //addLabel(rubyAttrStr(text), isLeft: false)
//            }

        case .scoreCalculated:
            guard let score = event.score else { return }
            print("分數", score)

        case .lifeChanged:
            return

        case .playTimeUpdate:
            guard let seconds = event.int else { return }
            func add0(_ s: String) -> String {
                return s.count == 1 ? "0" + s : s
            }

        case .gameStateChanged:
            if context.gameState == .gameOver {
                stopEventObserving(self)
                launchStoryboard(self, "MainPage", isOverCurrent: false, animated: true)
            }

        case .resume:
            game.resume()

        default:
            return
        }
    }
}
