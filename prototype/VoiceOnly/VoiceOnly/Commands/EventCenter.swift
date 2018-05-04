//
//  EventCenter.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/04.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation

typealias Event = Notification
typealias EventType = Notification.Name

func postEvent (_ type: EventType, _ object: Any) {
    NotificationCenter.default.post(name: type, object: object)
}

fileprivate typealias EventDelegate = EventCenter

fileprivate extension Selector {
    static let sayStarted = #selector(EventDelegate.onSayStarted(_:))
    static let stringSaid = #selector(EventDelegate.onStringSaid(_:))
    static let sayEnded = #selector(EventDelegate.onSayEnded(_:))
    static let listenStarted = #selector(EventDelegate.onListenEnded(_:))
    static let stringRecognized = #selector(EventDelegate.onStringRecognized(_:))
    static let listenEnded = #selector(EventDelegate.onListenEnded(_:))
    static let scoreCalculated = #selector(EventDelegate.onScoreCalculated(_:))
}

class EventCenter {
    static let shared = EventCenter()
    
    init() {
        observe(.sayStarted, .sayStarted)
        observe(.stringSaid, .stringSaid)
        observe(.sayEnded, .sayEnded)
        observe(.listenStarted, .listenStarted)
        observe(.stringRecognized, .stringRecognized)
        observe(.listenEnded, .listenEnded)
        observe(.scoreCalculated, .scoreCalculated)
    }
    
    func observe(_ type: EventType, _ eventHandler: Selector) {
        NotificationCenter.default.addObserver(
            self,
            selector: eventHandler,
            name: type,
            object: nil
        )
    }
    
    // SayCommand
    @objc func onSayStarted(_ event: Event) {
        (event.object as! SayCommand).log()
    }
    
    @objc func onStringSaid(_ event: Event) {
        print(event.object as! String, terminator: "")
    }
    
    @objc func onSayEnded(_ event: Event) {
        print("")
    }
    
    // ListenCommand
    @objc func onListenStarted(_ event: Event) {
        print("hear <<< ", terminator: "")
    }
    
    @objc func onStringRecognized(_ event: Event) {
        //print(event.object as! String, terminator: "")
    }
    
    @objc func onListenEnded(_ event: Event) {
        print(event.object as! String)
    }
    
    // onScore
    @objc func onScoreCalculated(_ event: Event) {
        print("score calculated: \(event.object as! Int)")
    }
}

