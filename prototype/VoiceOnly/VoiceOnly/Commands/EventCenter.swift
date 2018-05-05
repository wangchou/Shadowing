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

    func observe(_ type: EventType) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onAll(_:)),
            name: type,
            object: nil
        )
    }
    
    init() {
        observe(.stringSaid)
        observe(.sayEnded)
        observe(.listenStarted)
        observe(.stringRecognized)
        observe(.listenEnded)
        observe(.scoreCalculated)
        observe(.gameStateChanged)
    }
    
    @objc func onAll(_ event: Event) {
        switch event.name {
        case .gameStateChanged:
            onGameStateChanged(event)
        default:
            return
        }
    }
    
    // SayCommand
    func onSayStarted(_ event: Event) {
        (event.object as! SayCommand).log()
    }
    
    func onStringSaid(_ event: Event) {
        print(event.object as! String, terminator: "")
    }
    
    func onSayEnded(_ event: Event) {
        print("")
    }
    
    // ListenCommand
    func onListenStarted(_ event: Event) {
        print("hear <<< ", terminator: "")
    }
    
    func onStringRecognized(_ event: Event) {
        //print(event.object as! String, terminator: "")
    }
    
    func onListenEnded(_ event: Event) {
        print(event.object as! String)
    }
    
    // onScore
    func onScoreCalculated(_ event: Event) {
        print("score calculated: \(event.object as! Int)")
    }
    
    func onGameStateChanged(_ event: Event) {
        print("= game state changed: \(event.object as! GameState) =")
    }
}

