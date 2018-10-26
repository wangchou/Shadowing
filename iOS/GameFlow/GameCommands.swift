//
//  GameCommand.swift
//  今話したい
//
//  Created by Wangchou Lu on 10/26/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//
import Foundation

// UI will post command to lower gameFlow layer
// Command is like "redux actions" or "browser click events"
enum CommandType {
    case resume
    case forceStopGame
    case pause
}

extension Notification.Name {
    static let commandHappened = Notification.Name("commandHappended")
}

struct Command {
    let type: CommandType
}

func postCommand (_ type: CommandType) {
    NotificationCenter.default.post(
        name: .commandHappened,
        object: Command(type: type)
    )
}

// for GameFlow watching commands from UI/User
@objc protocol GameCommandDelegate {
    @objc func onCommandHappened(_ notification: Notification)
}

func startCommandObserving(_ delegate: GameCommandDelegate) {
    NotificationCenter.default.addObserver(
        delegate,
        selector: #selector(delegate.onCommandHappened(_:)),
        name: .commandHappened,
        object: nil
    )
}

func stopCommandObserving(_ delegate: GameCommandDelegate) {
    NotificationCenter.default.removeObserver(delegate)
}
