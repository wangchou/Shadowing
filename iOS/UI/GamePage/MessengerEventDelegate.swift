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
private let i18n = I18n.shared
private var tmpRangeQueue: [NSRange] = []

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
//                print(Date().timeIntervalSince1970, context.targetString, context.targetString.substring(with: newRange)?.s)
                tmpRangeQueue.append(newRange)
                let duration = Double(0.15 / (2 * context.teachingRate))

                Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
                    if !tmpRangeQueue.isEmpty {
                        tmpRangeQueue.removeFirst()
                    }
                }
                let allRange: NSRange = tmpRangeQueue.reduce(tmpRangeQueue[0], {allR, curR in
                    return allR.union(curR)
                })
//                print("\tallRange:", context.targetString.substring(with: allRange)?.s)

                var attrText = NSMutableAttributedString()

                if context.targetString.jpnType != .noKanjiAndNumber,
                    let tokenInfos = kanaTokenInfosCacheDictionary[context.targetString] {
                    let fixedRange = getRangeWithParticleFix(tokenInfos: tokenInfos, allRange: allRange)
//                    if let fixedRange = fixedRange {
//                        print("\tfixedRange:", context.targetString.substring(with: fixedRange)?.s)
//                    }
                    attrText = getFuriganaString(tokenInfos: tokenInfos, highlightRange: fixedRange)
                } else {
                    attrText.append(rubyAttrStr(context.targetString))
                    attrText.addAttribute(.backgroundColor, value: highlightColor, range: allRange)
                    var whiteRange = NSRange(location: allRange.upperBound, length: context.targetString.count - allRange.upperBound)
                    attrText.addAttribute(.backgroundColor, value: UIColor.clear, range: whiteRange)

                }
                lastLabel.attributedText = attrText
            }

        case .speakEnded:
            if !context.gameSetting.isShowTranslation,
                context.gameState == .speakingTargetString {
                lastLabel.attributedText = context.targetAttrString
            }
        case .listenStarted:
            addLabel(rubyAttrStr("..."), pos: .right)

        case .scoreCalculated:
            DispatchQueue.main.async {
                self.levelMeterValueBar.frame.size.height = 0
            }
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
            speedLabel.text = String(format: "%.2f 倍速", context.teachingRate * 2)

        case .levelMeterUpdate:
            guard let micLevel = event.int else { return }
            DispatchQueue.main.async {
                let height = CGFloat(20.0 * micLevel.f / 100.0)
                self.levelMeterValueBar.frame.size.height = height
                self.levelMeterValueBar.frame.origin.y = 6 + 20 - height
            }

        case .gameStateChanged:
            if context.gameState == .gameOver {
                stopEventObserving(self)
                addLabel(rubyAttrStr("遊戲結束。"))

                // prevent alerting block present
                isAlerting.always {
                    launchStoryboard(self, "GameFinishedPage", isOverCurrent: true, animated: true)
                }
            }

            if context.gameState == .speakingTranslation {
                tmpRangeQueue = []
                let text = context.targetString
                var translationsDict = (gameLang == .jp && context.contentTab == .topics) ?
                    chTranslations : translations
                var attrText: NSAttributedString
                if context.gameSetting.isShowTranslation,
                    let translation = translationsDict[text] {
                    attrText = rubyAttrStr(translation)
                } else {
                    attrText = context.targetAttrString
                }
                prescrolling(attrText)
                addLabel(attrText)
            }

            if context.gameState == .forceStopped {
                dismiss(animated: false)
            }

            if context.gameState == .echoMethod {
                addLabel(rubyAttrStr(i18n.listenToEcho), pos: .center)
            }
        }
    }

    // The iOS tts speak japanese always report willSpeak before particle or mark
    // ex: when speaking 鴨川沿いには遊歩道があります
    // the tts spoke "鴨川沿いには", but the delegate always report "鴨川沿い"
    // then it reports "には遊歩道"
    // so this function will remove prefix particle range and extend suffix particle range
    //
    // known unfixable bug:
    //      pass to tts:  あした、晴れるかな
    //      targetString: 明日、晴れるかな
    //      ttsKanaFix will sometimes make the range is wrong
    func getRangeWithParticleFix(tokenInfos: [[String]], allRange: NSRange?) -> NSRange? {

        guard let r = allRange else { return nil }
        var lowerBound = r.lowerBound
        var upperBound = min(r.upperBound, context.targetString.count)
        var currentIndex = 0
        var isPrefixParticleRemoved = false
        var isPrefixSubVerbRemoved = false
        var isParticleSuffixExtended = false

        for i in 0..<tokenInfos.count {
            let part = tokenInfos[i]
            let partLen = part[0].count
            let isParticle = part[1] == "助詞" || part[1] == "記号" || part[1] == "助動詞"
            let isVerbLike = part[1] == "動詞" || part[1] == "形容詞"

            // fix: "お掛けに" なりませんか
            if part[1] == "接頭詞",
               currentIndex >= lowerBound,
               currentIndex + partLen == upperBound,
               i < tokenInfos.count - 1 {
                upperBound += tokenInfos[i+1][0].count
            }
            if  i > 0,
                tokenInfos[i-1][1] == "接頭詞",
                currentIndex == lowerBound {
                lowerBound -= tokenInfos[i-1][0].count
            }

            // prefix particle remove
            // ex: "が降りそう" の　"が"
            func trimPrefixParticle() {
                if !isPrefixParticleRemoved,
                    currentIndex <= lowerBound,
                    currentIndex + partLen > lowerBound,
                    currentIndex + partLen < upperBound {
                    if isParticle {
                        lowerBound = currentIndex + partLen
                    } else {
                        isPrefixParticleRemoved = true
                    }
                }
            }

            // prefix subVerb remove
            // ex: "が降りそう" の　"り"
            func trimPrefixSubVerb() {
                if !isPrefixSubVerbRemoved,
                    currentIndex < lowerBound,
                    currentIndex + partLen >= lowerBound,
                    currentIndex + partLen < upperBound {
                    if isVerbLike {
                        lowerBound = currentIndex + partLen
                    } else {
                        isPrefixSubVerbRemoved = true
                    }
                }

            }

            // for "っています" subVerb + Particle + others
            trimPrefixSubVerb()
            trimPrefixParticle()
            trimPrefixSubVerb()

            // suffix particle extend
            if !isParticleSuffixExtended,
                currentIndex >= upperBound {
                if isParticle {
                    upperBound = currentIndex + partLen
                } else {
                    isParticleSuffixExtended = true
                }
            }

            currentIndex += partLen
        }

        guard upperBound >= lowerBound else { return nil }
        return NSRange(location: lowerBound, length: upperBound - lowerBound)
    }

    private func onScore(_ score: Score) {
        let attributed = NSMutableAttributedString()
        if let tokenInfos = kanaTokenInfosCacheDictionary[context.userSaidString],
           gameLang == .jp {
            attributed.append(getFuriganaString(tokenInfos: tokenInfos))
        } else {
            attributed.append(rubyAttrStr(context.userSaidString))
        }

        print(context.userSaidString)

        if attributed.string == "" {
            attributed.append(rubyAttrStr(i18n.iCannotHearYou))
        }

        attributed.append(rubyAttrStr(" \(score.valueText) \(score.type == .perfect ? "💯": "")"))

        updateLastLabelText(attributed, pos: .right)

        lastLabel.backgroundColor = score.color
        sentenceCountLabel.text = "\(i18n.remaining)\(context.sentences.count - context.sentenceIndex - 1)\(i18n.sentenceUnit)"
    }
}
