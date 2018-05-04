//
//  EventCenter.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/04.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let sayStarted = Notification.Name("sayStarted")
    static let stringSaid = Notification.Name("stringSaid")
    static let sayEnded = Notification.Name("sayEnded")
}

func postEvent (_ name: Notification.Name, _ object: Any) {
    NotificationCenter.default.post(name: name, object: object)
}

class EventCenter {
    static let shared = EventCenter()
    
    init() {
        observe(.sayStarted, selector: #selector(onSayStarted(notification:)))
        observe(.stringSaid, selector: #selector(onStringSaid(notification:)))
        observe(.sayEnded, selector: #selector(onSayEnded(notification:)))
    }
    
    func observe(_ name: Notification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(
            self,
            selector: selector,
            name: name,
            object: nil
        )
    }
    
    @objc func onSayStarted(notification: Notification) {
        (notification.object as! SayCommand).log()
    }
    
    @objc func onStringSaid(notification: Notification) {
        print(notification.object as! String, terminator: "")
    }
    
    @objc func onSayEnded(notification: Notification) {
        print("")
    }
}

