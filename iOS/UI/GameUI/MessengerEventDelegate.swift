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
                tmpRangeQueue.append(newRange)
                let duration = Double(0.15 / (2 * context.teachingRate))

                Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
                    if !tmpRangeQueue.isEmpty {
                        tmpRangeQueue.removeFirst()
                    }
                }
                let allRange: NSRange = tmpRangeQueue.reduce(tmpRangeQueue[0]) { allR, curR in
                    allR.union(curR)
                }

                var attrText = NSMutableAttributedString()

                if let tokenInfos = kanaTokenInfosCacheDictionary[context.targetString] {
                    let fixedRange = getRangeWithParticleFix(tokenInfos: tokenInfos, allRange: allRange)
                    attrText = getFuriganaString(tokenInfos: tokenInfos, highlightRange: fixedRange)
                    if let fixedRange = fixedRange {
                        attrText.addAttributes([.hightlightBackgroundFillColor: highlightColor],
                                               range: fixedRange)
                    }
                } else {
                    attrText.append(rubyAttrStr(context.targetString))
                    attrText.addAttributes([
                        .hightlightBackgroundFillColor: highlightColor
                    ], range: allRange)
                    let whiteRange = NSRange(location: allRange.upperBound, length: context.targetString.count - allRange.upperBound)
                    attrText.addAttribute(.hightlightBackgroundFillColor, value: UIColor.clear, range: whiteRange)
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
            guard let seconds = event.int else { return }
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
                tmpRangeQueue = []
                let text = context.targetString
                let translationsDict = (gameLang == .jp && context.gameMode == .topicMode) ?
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
        var isWordExpanded = false

        for i in 0 ..< tokenInfos.count {
            let part = tokenInfos[i]
            let partLen = part[0].count
            let isParticle = part[1] == "助詞" || part[1] == "記号" || part[1] == "助動詞"
            let isVerbLike = part[1] == "動詞" || part[1] == "形容詞"

            // fix: "お掛けに" なりませんか
            if part[1] == "接頭詞",
                currentIndex >= lowerBound,
                currentIndex + partLen == upperBound,
                i < tokenInfos.count - 1 {
                upperBound += tokenInfos[i + 1][0].count
            }
            if i > 0,
                tokenInfos[i - 1][1] == "接頭詞",
                currentIndex == lowerBound {
                lowerBound -= tokenInfos[i - 1][0].count
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

            // fixed to whole word
            // "有給休假"，只 highlight "休假" 時 => 改 highlight 整個字
            func expandWholeWord() {
                if  currentIndex <= lowerBound,
                    lowerBound < currentIndex + partLen {
                    lowerBound = currentIndex
                }

                if  !isWordExpanded,
                    currentIndex < upperBound,
                    upperBound < currentIndex + partLen {
                    upperBound = currentIndex + partLen
                    isWordExpanded = true
                }
            }

            // for "っています" subVerb + Particle + others
            trimPrefixSubVerb()
            trimPrefixParticle()
            trimPrefixSubVerb()
            expandWholeWord()

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

        guard upperBound >= lowerBound,
              upperBound <= context.targetString.count,
              lowerBound <= context.targetString.count,
              upperBound >= 0,
              lowerBound >= 0 else {
                print("something went wrong on highlight bounds")
                return nil
        }
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
