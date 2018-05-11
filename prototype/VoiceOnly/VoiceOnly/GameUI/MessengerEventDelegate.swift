//
//  MessengerEventDelegate.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/11.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

fileprivate let context = GameContext.shared

extension Messenger: GameEventDelegate {
    @objc func onEventHappened(_ notification: Notification) {
        let event = notification.object as! Event
        
        switch event.type {
        case .sayStarted:
            guard let name = event.string else { return }
            if name == MeiJia || name == Hattori {
                addLabel("")
            }
            
        case .stringSaid:
            guard let saidWord = event.string else { return }
            if game.state == .speakingJapanese || game.state == .stopped {
                updateLastLabelText(lastLabel.text! + saidWord)
            }
            
        case .listenStarted:
            addLabel("...", isLeft: false)
            
        case .stringRecognized, .listenEnded:
            guard var saidString = event.string else { return }
            saidString = saidString == "" ? "聽不清楚" : saidString
            updateLastLabelText(saidString, isLeft: false)
            
        case .scoreCalculated:
            guard let score = event.int else { return }
            var newText = "\(lastLabel.text!) \(score)分"
            newText = score == 100 ? "\(newText) ⭐️" : newText
            updateLastLabelText(newText, isLeft: false)
            
            if score < 60 {
                lastLabel.backgroundColor = myRed
            } else if score < 80 {
                lastLabel.backgroundColor = myOrange
            }
            
        case .gameStateChanged:
            if game.state == .gameOver {
                addLabel("遊戲結束。")
            }
            
            if game.state == .mainScreen {
                launchStoryboard(self, "ContentViewController")
            }
        default:
            return
        }
    }
}
