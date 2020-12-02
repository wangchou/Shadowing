//
//  hanashitaiTests.swift
//  hanashitaiTests
//
//  Created by Wangchou Lu on R 2/11/25.
//  Copyright © Reiwa 2 Lu, WangChou. All rights reserved.
//

@testable import hanashitai

import XCTest

class HanashitaiTests: XCTestCase {
//    override func setUpWithError() throws {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//
//    override func tearDownWithError() throws {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }

    func testSettingBackwardCompatiblity() throws {
        // 10317 = 1.03.17
        let setting10317json1 = """
            {
              "isMointoring" : true,
              "dailySentenceGoal" : 100,
              "isAutoSpeed" : false,
              "isShowTranslation" : false,
              "isSpeakTranslation" : true,
              "isUsingGuideVoice" : false,
              "practiceSpeed" : 0.490252286195755,
              "isShowTranslationInPractice" : false,
              "teacher" : "com.apple.ttsbundle.Daniel-compact",
              "assisant" : "com.apple.ttsbundle.Rishi-compact",
              "isUsingNarrator" : false,
              "icTopViewMode" : 0,
              "preferredSpeed" : 0.32167431712150574,
              "learningMode" : 3
            }
        """
        let setting10317json2 = """
            {
              "isMointoring" : true,
              "dailySentenceGoal" : 50,
              "isAutoSpeed" : true,
              "isShowTranslation" : false,
              "isSpeakTranslation" : true,
              "isUsingGuideVoice" : true,
              "practiceSpeed" : 0.34999999403953552,
              "isShowTranslationInPractice" : false,
              "teacher" : "com.apple.ttsbundle.Kyoko-premium",
              "assisant" : "com.apple.ttsbundle.Kyoko-premium",
              "isUsingNarrator" : true,
              "icTopViewMode" : 0,
              "preferredSpeed" : 0.44999998807907104,
              "learningMode" : 0
            }
        """

        // 10400 = 1.04.00 = v1.4.0
        let setting10400json = """
        {"isMointoring":true,"monitoringVolume":5,"translatorEn":"unknown","translatorZh":"com.apple.ttsbundle.Sin-Ji-compact","dailySentenceGoal":50,"gameSpeed":0.5975806713104248,"isShowTranslation":true,"isSpeakTranslation":false,"assistant":"unknown","isUsingGuideVoice":true,"practiceSpeed":0.52283656597137451,"isShowTranslationInPractice":false,"translationLang":3,"icTopViewMode":0,"isUsingNarrator":false,"isRepeatOne":false,"teacher":"com.apple.ttsbundle.Kyoko-compact","translatorJp":"unknown","learningMode":2}
        """

        let data1 = Data(setting10317json1.utf8)
        let data2 = Data(setting10317json2.utf8)
        let data3 = Data(setting10400json.utf8)

        do {
            let setting1 = try JSONDecoder().decode(GameSetting.self, from: data1)
            let setting2 = try JSONDecoder().decode(GameSetting.self, from: data2)
            let setting3 = try JSONDecoder().decode(GameSetting.self, from: data3)
            // print(setting1)
            // print(setting2)
            // print(setting3)
            XCTAssert(true)
        } catch {
            print(error)
            XCTAssert(false)
        }
    }

    func testGameHistoryBackwardCompatiblity() throws {
        let history10317json = """
        [{"perfectCount":3,"gameFlowMode":"shadowing","dataSetKey":"Medal Mode Key","level":0,"isNewRecord":false,"greatCount":0,"medalReward":20,"playDuration":19,"goodCount":0,"sentencesCount":3,"sentencesScore":{"彼は顔が広い。":{"value":100},"こっちへ来なさい!":{"value":100},"採点しましたか。":{"value":100}},"startedTime":627831051.19067395},{"perfectCount":3,"gameFlowMode":"shadowing","dataSetKey":"Medal Mode Key","level":0,"isNewRecord":false,"greatCount":0,"medalReward":30,"playDuration":13,"goodCount":0,"sentencesCount":3,"sentencesScore":{"無知は幸福。":{"value":100},"歩きましょうか。":{"value":100},"アヒルに似てるの。":{"value":100}},"startedTime":627830471.33077002},{"perfectCount":2,"gameFlowMode":"shadowing","dataSetKey":"Medal Mode Key","level":0,"isNewRecord":false,"greatCount":1,"medalReward":15,"playDuration":19,"goodCount":0,"sentencesCount":3,"sentencesScore":{"道を渡ろう。":{"value":100},"スキーに行かない?":{"value":80},"足にまめができた。":{"value":100}},"startedTime":627828959.51812601},{"perfectCount":1,"gameFlowMode":"shadowing","dataSetKey":"Medal Mode Key","level":0,"isNewRecord":false,"greatCount":1,"medalReward":5,"playDuration":22,"goodCount":1,"sentencesCount":3,"sentencesScore":{"彼はいい人です。":{"value":64},"だれが悪いのか。":{"value":100},"彼らはみんな来た。":{"value":81}},"startedTime":627554708.15929401},{"perfectCount":1,"goodCount":1,"dataSetKey":"Level DataSet Key 0","playDuration":16,"greatCount":0,"sentencesCount":3,"level":0,"startedTime":627554934.903597,"gameFlowMode":"shadowing","sentencesScore":{"聞こえますか。":{"value":100},"立ちなさい。":{"value":50},"キスして":{"value":66}},"isNewRecord":false},{"perfectCount":0,"goodCount":0,"dataSetKey":"すみません","playDuration":12,"greatCount":0,"sentencesCount":20,"level":0,"startedTime":627558531.90023303,"gameFlowMode":"shadowing","sentencesScore":{"":{"value":0}},"isNewRecord":false},{"perfectCount":0,"gameFlowMode":"shadowing","dataSetKey":"Medal Mode Key","level":0,"isNewRecord":false,"greatCount":2,"medalReward":3,"playDuration":14,"goodCount":1,"sentencesCount":3,"sentencesScore":{"すぐにうまくなるよ。":{"value":81},"鍵が見つからない。":{"value":64},"止めようとしても。":{"value":80}},"startedTime":628102967.30489004},{"perfectCount":0,"gameFlowMode":"shadowing","dataSetKey":"Medal Mode Key","level":0,"isNewRecord":false,"greatCount":1,"medalReward":-3,"playDuration":14,"goodCount":1,"sentencesCount":3,"sentencesScore":{"いや特にないわ。":{"value":80},"まあ、お気の毒に。":{"value":61},"だめ、行かないで。":{"value":58}},"startedTime":628102995.35679901},{"perfectCount":2,"gameFlowMode":"shadowing","dataSetKey":"Medal Mode Key","level":0,"isNewRecord":false,"greatCount":1,"medalReward":10,"playDuration":10,"goodCount":0,"sentencesCount":3,"sentencesScore":{"今日は晴れだ。":{"value":100},"幸福は買えない。":{"value":81},"足にまめができた。":{"value":100}},"startedTime":628103078.253829}]
        """

        do {
            let data1 = Data(history10317json.utf8)
            let history1 = try JSONDecoder().decode([GameRecord].self, from: data1)
            // print(history1)
            XCTAssert(true)
        } catch {
            print(error)
            XCTAssert(false)
        }
    }
}
