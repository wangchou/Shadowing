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
            if context.gameState == .justStarted {
                addLabel(rubyAttrStr(text))
            }

        case .willSpeakRange:
            guard let newRange = event.range else { return }
            if !context.gameSetting.isShowTranslation,
                context.gameState == .speakingTargetString {
                lastLabel.updateHighlightRange(newRange: newRange,
                                               targetString: context.targetString,
                                               voiceRate: context.teachingRate)
            }

        case .speakEnded:
            if !context.gameSetting.isShowTranslation,
                context.gameState == .speakingTargetString {
                lastLabel.attributedText = context.targetAttrString
            }
        case .listenStarted:
            addLabel(rubyAttrStr("..."), pos: .right)
            FuriganaLabel.clearHighlighRange()

        case .listenStopped:
            DispatchQueue.main.async {
                self.levelMeterHeightConstraint.constant = 0
            }

        case .scoreCalculated:
            DispatchQueue.main.async {
                self.levelMeterHeightConstraint.constant = 0
            }
            guard let score = event.score else { return }
            onScore(score)
            messengerBar.render()

        case .playTimeUpdate:
            guard event.int != nil else { return }
            func add0(_ s: String) -> String {
                return s.count == 1 ? "0" + s : s
            }

        case .levelMeterUpdate:
            guard let micLevel = event.int else { return }
            DispatchQueue.main.async {
                let height = CGFloat(20.0 * micLevel.f / 100.0)
                self.levelMeterHeightConstraint.constant = height
            }

        case .gameResume:
            messengerBar.isGameStopped = false
            messengerBar.render()

        case .practiceSentenceCalculated:
            return

        case .gameStateChanged:
            if context.gameState == .gameOver {
                stopEventObserving(self)
                addLabel(rubyAttrStr(i18n.gameOver))

                // prevent alerting block present
                isAlerting.always {
                    if context.gameMode != .medalMode {
                        launchVC(GameFinishedPage.vcName, self)
                    } else {
                        launchVC(MedalGameFinishedPage.id, self)
                    }
                }
            }

            if context.gameState == .speakingTranslation {
                FuriganaLabel.clearHighlighRange()
                var attrText: NSAttributedString
                if context.gameSetting.isShowTranslation {
                    attrText = rubyAttrStr(context.translation)
                } else {
                    attrText = context.targetAttrString
                }
                prescrolling(attrText)
                addLabel(attrText)
            }

            if context.gameState == .echoMethod {
                addLabel(rubyAttrStr(i18n.listenToEcho), pos: .center)
            }
        }
    }

    private func onScore(_ score: Score) {
        let attributed = NSMutableAttributedString()
        if let tokenInfos = kanaTokenInfosCacheDictionary[context.userSaidString],
            gameLang == .ja {
            attributed.append(getFuriganaString(tokenInfos: tokenInfos))
        } else {
            attributed.append(rubyAttrStr(context.userSaidString))
        }

        print(context.userSaidString)

        if attributed.string == "" {
            attributed.append(rubyAttrStr(i18n.iCannotHearYou))
            if !SpeechEngine.shared.isInstallTapSuceeced {
                SpeechEngine.shared.restart()
            }
        }

        attributed.append(rubyAttrStr(" \(score.valueText) \(score.type == .perfect ? "💯　" : "")"))

        updateLastLabelText(attributed, pos: .right)

        var color = score.color
        if color == myRed {
            color = myRed.withBrightness(1.15)
        }
        lastLabel.backgroundColor = color
    }
}
