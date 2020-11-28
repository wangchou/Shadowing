//
//  SentencesTableCell+GameEventDelegate.swift
//  hanashitai
//
//  Created by Wangchou Lu on R 2/11/28.
//  Copyright © Reiwa 2 Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

private let context = GameContext.shared

extension SentencesTableCell: GameEventDelegate {
    @objc func onEventHappened(_ notification: Notification) {
        guard let event = notification.object as? Event else {
            print("convert event fail")
            return
        }

        switch event.type {
        case .willSpeakRange:
            guard let newRange = event.range else { return }
            if !context.gameSetting.isShowTranslationInPractice {
                sentenceLabel.updateHighlightRange(newRange: newRange,
                                                   targetString: targetString,
                                                   voiceRate: context.gameSetting.practiceSpeed)
            }
        default:
            ()
        }
    }
}
