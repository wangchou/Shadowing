//
//  EventCenter.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/04.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation

enum EventType{
    case sayStarted
    case stringSaid
    case sayEnded
    case listenStarted
    case stringRecognized
    case listenEnded
    case scoreCalculated
    case gameStateChanged
}

struct Event {
    let type: EventType
    let object: Any
}

extension Notification.Name {
    static let eventHappened = Notification.Name("eventHappended")
}

@objc protocol EventDelegate {
    @objc func onEventHappened(_ notification: Notification)
}


func postEvent (_ type: EventType, _ object: Any) {
    NotificationCenter.default.post(
        name: .eventHappened,
        object: Event(type: type, object: object)
    )
}

func startEventObserving(_ delegate: EventDelegate) {
    NotificationCenter.default.addObserver(
        delegate,
        selector: #selector(delegate.onEventHappened(_:)),
        name: .eventHappened,
        object: nil
    )
}

func stopEventObserving(_ delegate: EventDelegate) {
    NotificationCenter.default.removeObserver(delegate)
}
