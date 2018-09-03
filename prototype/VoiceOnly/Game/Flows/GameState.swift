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
    case speakingTargetString
    case listening
    case stringRecognized
    case repeatingWhatSaid
    case scoreCalculated
    case speakingScore
    case sentenceSessionEnded
    case gameOver
}

protocol Game {
    func start()
    func stop()
}
