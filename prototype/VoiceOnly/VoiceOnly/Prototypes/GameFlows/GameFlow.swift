//
//  GameFlow.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/05.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation

enum GameState {
    case stopped
    case speakingJapanese
    case listening
    case stringRecognized
    case repeatingWhatSaid
    case scoreCalculated
    case speakingScore
    case sentenceSessionEnded
}

protocol GameFlow {
    var state: GameState { get set}
    func play()
    func stop()
}
