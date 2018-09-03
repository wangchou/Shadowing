//
//  CommonFlow.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 9/3/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation

import Promises

private let pauseDuration = 0.4
private let context = GameContext.shared

func speakTargetString() -> Promise<Void> {
    context.gameState = .speakingTargetString
    let speakStartedTime = getNow()
    return hattori(context.targetString).then {
        context.speakDuration = getNow() - speakStartedTime
    }
}

func listen() -> Promise<Void> {
    context.gameState = .listening
    return listenJP(duration: context.speakDuration + pauseDuration)
        .then(saveUserSaidString)
}

private func saveUserSaidString(userSaidString: String) -> Promise<Void> {
    context.gameState = .stringRecognized
    context.userSaidString = userSaidString
    return fulfilledVoidPromise()
}

func getScore() -> Promise<Void> {
    return calculateScore(context.targetString, context.userSaidString)
        .then(saveScore)
}

private func saveScore(score: Score) -> Promise<Void> {
    context.gameState = .scoreCalculated
    context.score = score
    updateGameRecord(score: score)
    return fulfilledVoidPromise()
}

func updateGameRecord(score: Score) {
    context.gameRecord?.sentencesScore[context.targetString] = score

    switch score.type {
    case .perfect:
        context.gameRecord?.perfectCount += 1
    case .great:
        context.gameRecord?.greatCount += 1
    case .good:
        context.gameRecord?.goodCount += 1
    default:
        ()
    }
}
