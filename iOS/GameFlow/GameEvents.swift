//
//  EventCenter.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/04.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation

// lower layer like tts, speechRecognition, gameFlow will postEvent to GameUI(Messenger)
enum EventType {
    case sayStarted
    case willSpeakRange
    case speakEnded
    case listenStarted
    case listenStopped

    case scoreCalculated
    case gameStateChanged

    case playTimeUpdate
    case levelMeterUpdate

    case gameResume
}

struct Event {
    let type: EventType

    // only accept four types of data for type safety
    let string: String?
    let int: Int?
    let gameState: GameState?
    let score: Score?
    let range: NSRange?
}

extension Notification.Name {
    static let eventHappened = Notification.Name("eventHappended")
}

func postEvent (
    _ type: EventType,
    string: String? = nil,
    int: Int? = nil,
    gameState: GameState? = nil,
    score: Score? = nil,
    range: NSRange? = nil) {
    NotificationCenter.default.post(
        name: .eventHappened,
        object: Event(type: type, string: string, int: int, gameState: gameState, score: score, range: range)
    )
}

// for Game UI watching events from lower layers
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
