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

class EventCenter {
    static let shared = EventCenter()
    
    init() {
        observe(.sayStarted, #selector(onSayStarted(_:)))
        observe(.stringSaid, #selector(onStringSaid(_:)))
        observe(.sayEnded, #selector(onSayEnded(_:)))
        observe(.listenStarted, #selector(onListenStarted(_:)))
        observe(.stringRecognized, #selector(onStringRecognized(_:)))
        observe(.listenEnded, #selector(onListenEnded(_:)))
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
}

