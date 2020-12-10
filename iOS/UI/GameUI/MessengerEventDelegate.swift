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
        #if DEBUG
        let watchTypes: [EventType] = [.sayStarted, .speakEnded, .scoreCalculated]
        if let gameState = event.gameState {
            // print("\n== \(gameState.rawValue) ==")
            if gameState == .speakingTranslation {
                print("\n---")
            }
        } else if watchTypes.contains(event.type) {
            print(//event.type,
                  event.string ?? "",
                  event.range ?? "",
                  event.int ?? "",
                  event.score ?? "")
        }
        #endif

        switch event.type {
        case .sayStarted:
            guard let text = event.string else { return }
            if context.gameState == .speakTitle ||
                context.gameState == .speakInitialDescription {
                addLabel(rubyAttrStr(text))
            }
            speakStartTime = getNow()

        case .willSpeakRange:
            guard let newRange = event.range else { return }
            if context.gameSetting.isShowOriginal,
               context.gameState == .speakingTargetString {
                lastLabel.updateHighlightRange(newRange: newRange,
                                               targetString: context.targetString,
                                               voiceRate: context.teachingSpeed)
            }

        case .speakEnded:
            if context.gameSetting.isShowOriginal,
               context.gameState == .speakingTargetString {
                lastLabel.attributedText = context.targetAttrString
            }
            context.speakDuration = Float(getNow() - speakStartTime)

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

        case .gamePaused:
            if context.gameState == .speakingTargetString {
                lastLabel.attributedText = context.targetAttrString
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
                if context.gameSetting.isShowTranslation {
                    let attrText = rubyAttrStr(context.translation)
                    prescrolling(attrText)
                    addLabel(attrText)
                } else {
                    prescrolling(context.targetAttrString)
                    addLabel(context.targetAttrString)
                }
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

        // print("'\(context.userSaidString)'")

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
