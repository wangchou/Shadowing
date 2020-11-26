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
            print(setting1)
            print(setting2)
            print(setting3)
            XCTAssert(true)
        } catch {
            print(error)
            XCTAssert(false)
        }
    }

    func testGameHistoryBackwardCompatiblity() throws {
        let history10317json = ""
    }
}
