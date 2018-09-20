//
//  SentencesTest.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/12.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import Promises

private let context = GameContext.shared
private let engine = SpeechEngine.shared

// 用 iphone 線控耳機、並把耳機放到麥克風旁邊、耳機聲音開到最大
// 測試 siri 能不能辨識他自己說的日文
class SentencesTestGame: Game {
    static let shared = SentencesTestGame()

    var startTime: Double = 0
    var sentences = n5
    var index = 0
    var targetString = ""
    var saidString = ""

    var gameState: GameState = .stopped

    override func start() {
        engine.start()
        context.life = 100
        testNext()
    }

    func testNext() {
        guard index < sentences.count else { return }
        targetString = sentences[index]

        startTime = getNow()
        teacherSay(targetString).then({ () -> Promise<String> in
            let duration = getNow() - self.startTime + Double(pauseDuration)
            let p1 = engine.listen(duration: duration)
            usleep(100000)
            _ = teacherSay(self.targetString)
            return p1
        }).then({ saidString -> Promise<Score> in
            self.saidString = saidString
            return calculateScore(self.targetString, saidString)
        }).then({ score in
            print(score.value, self.targetString, self.saidString)
            self.index += 1
            self.testNext()
        }).catch({ error in
            print(error)
        })
    }
}
