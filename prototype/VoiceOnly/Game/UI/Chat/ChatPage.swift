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

class ChatPage: UIViewController {
    let game = ChatFlow.shared
    var tmpText: NSMutableAttributedString = colorText("", fontSize: 20)
    var chatView: ChatView? {
        return (view as? ChatView)
    }
    var textView: UITextView? {
        return chatView?.textView
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
        let screenTapped = UITapGestureRecognizer(target: self, action: #selector(onScreenTapped))
        chatView?.addGestureRecognizer(screenTapped)
    }

    func end() {
        stopEventObserving(self)
        game.stop()
    }

    func cprint(_ text: String, _ color: UIColor = .lightText, terminator: String = "\n") {
        chatView?.cprint(text, color, terminator: terminator)
    }

    @objc func onScreenTapped() {
        game.pause()
        launchStoryboard(self, "PauseOverlay", isOverCurrent: true)
    }
}

extension ChatPage: GameEventDelegate {
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
            chatView?.updateSentenceLabel()

        case .listenStarted:
            chatView?.updateSentenceLabel()
            chatView?.faceExpression = .listening
            cprint(context.targetString)
            if let text = textView?.attributedText.mutableCopy() as? NSMutableAttributedString {
                tmpText = text
                print(text.string)
            }

        case .stringRecognized, .listenEnded:
            guard let curText = tmpText.mutableCopy() as? NSMutableAttributedString else { return }
            guard var saidString = event.string else { return }
            if event.type == .listenEnded && saidString == "" {
                saidString = "聽不清楚"
            }
            curText.append(colorText(saidString, terminator: " ", fontSize: 20))
            textView?.attributedText = curText
            chatView?.scrollTextIntoView()

        case .scoreCalculated:
            if let score = event.score {
                cprint(" \(score.valueText)", score.color)
                cprint("---")
            }

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
                launchStoryboard(self, "SwipeMainPage", isOverCurrent: false, animated: true)
            }

        case .resume:
            game.resume()

        default:
            return
        }
    }
}
