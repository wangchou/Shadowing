//
//  EventCenter.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/04.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation

enum EventType {
    // tts
    case sayStarted
    case stringSaid
    case sayEnded

    // speech recognition
    case listenStarted
    case stringRecognized
    case listenEnded

    case scoreCalculated
    case lifeChanged
    case gameStateChanged

    case playTimeUpdate
    case resume
}

struct Event {
    let type: EventType

    // only accept three types of data for type safety
    let string: String?
    let int: Int?
    let gameState: GameState?
}

extension Notification.Name {
    static let eventHappened = Notification.Name("eventHappended")
}

func postEvent (_ type: EventType, string: String? = nil, int: Int? = nil, gameState: GameState? = nil) {
    NotificationCenter.default.post(
        name: .eventHappened,
        object: Event(type: type, string: string, int: int, gameState: gameState)
    )
}

// for Game UI watching events
@objc protocol GameEventDelegate {
    @objc func onEventHappened(_ notification: Notification)
}

func startEventObserving(_ delegate: GameEventDelegate) {
    NotificationCenter.default.addObserver(
        delegate,
        selector: #selector(delegate.onEventHappened(_:)),
        name: .eventHappened,
        object: nil
    )
}

func stopEventObserving(_ delegate: GameEventDelegate) {
    NotificationCenter.default.removeObserver(delegate)
}
