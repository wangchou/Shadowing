//
//  MessengerEventDelegate.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/11.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

private let context = GameContext.shared

extension Messenger: GameEventDelegate {
    @objc func onEventHappened(_ notification: Notification) {
        guard let event = notification.object as? Event else { print("convert event fail"); return }

        switch event.type {
        case .sayStarted:
            guard let text = event.string else { return }
            if game.state == .stopped {
                addLabel(rubyAttrStr(text))
            }
            if game.state == .speakingJapanese {
                if let tokenInfos = kanaTokenInfosCacheDictionary[text] {
                    addLabel(getFuriganaString(tokenInfos: tokenInfos))
                } else {
                    addLabel(rubyAttrStr(text))
                }
            }

        case .listenStarted:
            addLabel(rubyAttrStr("..."), isLeft: false)

        case .scoreCalculated:
            guard let score = event.score else { return }
            onScore(score)

        case .lifeChanged:
            speedLabel.text = String(format: "%.2f 倍速", context.teachingRate * 2)

        case .playTimeUpdate:
            guard let seconds = event.int else { return }
            func add0(_ s: String) -> String {
                return s.count == 1 ? "0" + s : s
            }

            timeLabel.text = "\(add0((seconds/60).s)):\(add0((seconds%60).s))"

        case .gameStateChanged:
            if game.state == .gameOver {
                stopEventObserving(self)
                addLabel(rubyAttrStr("遊戲結束。"))
                launchStoryboard(self, "GameFinishedPage", animated: true)
            }

        case .resume:
            game.resume()

        default:
            return
        }
    }

    private func onScore(_ score: Score) {
        let attributed = NSMutableAttributedString()
        if let tokenInfos = kanaTokenInfosCacheDictionary[context.userSaidString] {
            attributed.append(getFuriganaString(tokenInfos: tokenInfos))
        } else {
            attributed.append(rubyAttrStr(context.userSaidString))
        }

        if attributed.string == "" {
            attributed.append(rubyAttrStr("聽不清楚"))
        }

        attributed.append(rubyAttrStr(" \(score.valueText) \(score.type == .perfect ? "⭐️": "")"))

        updateLastLabelText(attributed, isLeft: false)

        lastLabel.backgroundColor = score.color
        sentenceCountLabel.text = "還有\(context.sentences.count - context.sentenceIndex - 1)句"
    }
}
