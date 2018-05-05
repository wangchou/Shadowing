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

func postEvent (_ type: EventType, _ object: Any) {
    NotificationCenter.default.post(
        name: .eventHappened,
        object: Event(type: type, object: object)
    )
}

class EventCenter {
    static let shared = EventCenter()
    
    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onEventHappened(_:)),
            name: .eventHappened,
            object: nil
        )
    }
    
    @objc func onEventHappened(_ notification: Notification) {
        let event = notification.object as! Event
        switch event.type {
        case .sayStarted:
            (event.object as! SayCommand).log()
        case .stringSaid:
            print(event.object as! String, terminator: "")
        case .sayEnded:
            print("")
        case .listenStarted:
            print("hear <<< ", terminator: "")
        case .listenEnded:
            print(event.object as! String)
        case .scoreCalculated:
            print("score calculated: \(event.object as! Int)")
        case .gameStateChanged:
            onGameStateChanged(event)
        default:
            return
        }
    }
    
    func onGameStateChanged(_ event: Event) {
        print("= game state changed: \(event.object as! GameState) =")
    }
}

