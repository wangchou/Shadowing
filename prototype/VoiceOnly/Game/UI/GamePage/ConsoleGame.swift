//
//  P10ViewController.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/05.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

// Prototype 10: black console
class ConsoleGame: UIViewController, GameEventDelegate {
    let game = SimpleGame.shared
    var score: Score = Score(value: 0)
    var tmpText: NSMutableAttributedString = colorText("")

    @IBOutlet weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = ""
        startEventObserving(self)
        game.start()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopEventObserving(self)
        game.stop()
    }

    @objc func onEventHappened(_ notification: Notification) {
        guard let event = notification.object as? Event else { return }

        switch event.type {
        case .sayStarted:
            guard let name = event.string else { return }
            switch name {
            case hattoriSan:
                cprint("---")
            default:
                return
            }

        case .stringSaid:
            var color: UIColor = .lightText
            color = game.state == .speakingJapanese ? myBlue : color
            if game.state != .scoreCalculated,
               let str = event.string {
                cprint(str, color, terminator: "")
            }

        case .sayEnded:
            cprint("")

        case .listenStarted:
            if let text = textView.attributedText.mutableCopy() as? NSMutableAttributedString {
                tmpText = text
            }

        case .stringRecognized, .listenEnded:
            guard let curText = tmpText.mutableCopy() as? NSMutableAttributedString else { return }
            guard var saidString = event.string else { return }
            if event.type == .listenEnded && saidString == "" {
               saidString = "聽不清楚"
            }
            curText.append(colorText(saidString, terminator: " "))
            textView.attributedText = curText

        case .scoreCalculated:
            if let score = event.score {
                self.score = score
                cprint(" \(score.text)", score.color, terminator: "")
            }
        case .gameStateChanged:
            if let state = event.gameState,
               state == .gameOver {
                launchStoryboard(self, "GameFinishedPage", isOverCurrent: true, animated: true)
            }

        default:
            return
        }
    }

    func scrollTextIntoView() {
        let range = NSRange(location: textView.attributedText.string.count - 1, length: 0)
        textView.scrollRangeToVisible(range)
    }

    // color print to self.textView
    func cprint(_ text: String, _ color: UIColor = .lightText, terminator: String = "\n") {
        if let newText = textView.attributedText.mutableCopy() as? NSMutableAttributedString {
            newText.append(colorText(text, color, terminator: terminator))
            textView.attributedText = newText
            scrollTextIntoView()
        } else {
            print("unwrap gg 999")
        }
    }
}
