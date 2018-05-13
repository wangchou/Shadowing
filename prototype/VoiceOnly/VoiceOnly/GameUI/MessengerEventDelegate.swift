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
            onScore(score)
            
        case .lifeChanged:
            speedLabel.text = String(format: "%.2f 倍速", context.teachingRate * 2)
            
        case .playTimeUpdate:
            guard let seconds = event.int else { return }
            func add0(_ s: String) -> String{
                return s.count == 1 ? "0" + s : s
            }
            
            timeLabel.text = "\(add0((seconds/60).s)):\(add0((seconds%60).s))"
            
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
    
    private func onScore(_ score: Int) {
        var newText = "\(lastLabel.text!) \(score)分"
        newText = score == 100 ? "\(newText) ⭐️" : newText
        updateLastLabelText(newText, isLeft: false)
        
        if score < 60 {
            lastLabel.backgroundColor = myRed
        } else if score < 80 {
            lastLabel.backgroundColor = myOrange
        }
        
        sentenceCountLabel.text = "還有\(context.sentences.count - context.sentenceIndex - 1)句"
    }
}
