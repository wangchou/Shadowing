//
//  FakeKey.swift
//  sentencesVerifier
//
//  Created by Wangchou Lu on 10/14/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation
// https://stackoverflow.com/questions/27484330/simulate-keypress-using-swift
class FakeKey {
    static func send(_ keyCode: CGKeyCode, useCommandFlag: Bool) {
        let sourceRef = CGEventSource(stateID: .combinedSessionState)

        if sourceRef == nil {
            NSLog("FakeKey: No event source")
            return
        }

        let keyDownEvent = CGEvent(keyboardEventSource: sourceRef,
                                   virtualKey: keyCode,
                                   keyDown: true)
        if useCommandFlag {
            keyDownEvent?.flags = .maskCommand
        }

        let keyUpEvent = CGEvent(keyboardEventSource: sourceRef,
                                 virtualKey: keyCode,
                                 keyDown: false)

        keyDownEvent?.post(tap: .cghidEventTap)
        keyUpEvent?.post(tap: .cghidEventTap)
    }
}
