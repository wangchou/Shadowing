//
//  I18n.swift
//  今話したい
//
//  Created by Wangchou Lu on 10/26/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation

class I18n {
    static let shared = I18n()

    private init() {}

    var langCode: String? {
        return Locale.current.languageCode
    }

    var isJa: Bool {
        return langCode == "ja"
    }

    var isZh: Bool {
        return langCode == "zh"
    }

    var autoSpeedLabel: String {
        if isJa || isZh { return "自動速度" }
        return "Auto Speed"
    }

    var translationLabel: String {
        if isJa { return "翻訳の表示" }
        if isZh { return "顯示翻譯" }
        return "Show Translation"
    }
    var guideVoiceLabel: String {
        if isJa { return "ガイド音声" }
        if isZh { return "引導朗讀" }
        return "Guide Voice"
    }
    var narratorLabel: String {
        if isJa { return "はじめの説明" }
        if isZh { return "開始語音說明" }
        return "Initial Descriptions"
    }
    var monitoringLabel: String {
        if isJa { return "モニタリング（有線イヤホンのみ）"}
        if isZh { return "即時監聽(有線耳機 Only)" }
        return "Wired Monitoring"
    }
    var gotoIOSSettingButtonTitle: String {
        if isJa { return "iPhone設定へ" }
        if isZh { return "前往iPhone設定中心" }
        return "Go to iPhone Setting Center"
    }
    var defaultText: String {
        if isJa { return "デフォルト" }
        if isZh { return "預設" }
        return "Default"
    }
    var voiceNotAvailableTitle: String {
        return isJa ? "選らんた声はまだダウンロードされていません" : "你選的語音還未下載"
    }
    var voiceNotAvailableMessage: String {
        let lang = gameLang == .jp ? japanese : english
        if isJa { return "もっと声をダウンロードしましょう\n「設定」>「一般」>「アクセシビリティ」>「スピーチ」 >「声」>「\(lang)」の順に選択します。" }
        if isZh { return "更多語音選項: \n 請前往手機的「設定 > 一般 > 輔助使用 > 語音 > 聲音 > \(lang)」下載" }
        return "Download more voices:\nGo to Settings > General > Accessibility > Speech > Voice > \(lang)"
    }
    var voiceNotAvailableOKButton: String {
        return isJa ? "わかった" : "知道了"
    }

    var settingSectionGameSpeed: String {
        if isJa { return "ゲーム時の読み上げ速度"}
        if isZh { return "遊戲時的朗讀速度" }
        return "Speaking Speed (in Game)"
    }
    var settingSectionPracticeSpeed: String {
        if isJa { return  "練習時の読み上げ速度" }
        if isZh { return "練習時的朗讀速度" }
        return "Speaking Speed (in Practice)"
    }
    var gameSetting: String {
        if isJa { return "ゲーム設定" }
        if isZh { return "遊戲設定" }
        return "Game Settings"
    }
    var micAndSpeechPermission: String {
        if isJa { return "マイクと音声認識のアクセス権限" }
        if isZh { return "麥克風與語音辨識權限" }
        return "Mic and Recognition Permissions"
    }

    var gameOver: String {
        if isJa { return "ゲーム終了" }
        if isZh { return "遊戲結束" }
        return "Game Over"
    }

    var gameStartedWithGuideVoice: String {
        if isJa { return "私のあとに繰り返してください。" }
        if isZh { return "我說完\(langToSpeak)後，請跟著說～" }
        return "Please repeat after me."
    }

    var reachDailyGoal: String {
        if gameLang == .jp { return "おめでとう。あなたは今日素晴らしい仕事をしました。" }
        return "Congratulations. You did a great job today."
    }

    var gameStartedWithoutGuideVoice: String {
        if isJa { return "\(langToSpeak)の文を読んていってください。" }
        if isZh { return "請唸出對應的\(langToSpeak)。" }
        return "Please speak showed sentences."
    }

    var dailyGoal: String {
        if isJa { return "毎日の目標" }
        if isZh { return "每天的目標" }
        return "Daily Sentences Goal"
    }

    var sentenceUnit: String {
        if isJa { return "文" }
        if isZh { return "句" }
        return ""
    }

    var textToSpeech: String {
        if isJa { return "音声合成" }
        if isZh { return "語音合成" }
        return "Text to Speech"
    }
    var teacherLabel: String {
        if gameLang == .jp {
            if isJa { return "日本語先生" }
            if isZh { return "日文老師" }
            return "Japanese Teacher"
        }

        if isJa { return "英語先生" }
        if isZh { return "英文老師" }
        return "English Teacher"
    }
    var assistantLabel: String {
        if gameLang == .jp {
            if isJa { return "日本語アシスタント" }
            if isZh { return "日文助理" }
            return "Japanese Assisant"
        }
        if isJa { return "英語アシスタント" }
        if isZh { return "英文助理" }
        return "English Assisant"
    }
    var enhancedVoice: String {
        if isJa { return "(拡張)" }
        if isZh { return "(高品質)" }
        return "(Enhanced)"
    }
    var cannotReachServer: String {
        return isJa ? "サーバーに接続できません" : "連不到主機"
    }

    var gotoIOSCenterTitle: String {
        if isJa { return "マイクと音声認識のアクセス権限がありません。iPhoneの設定へ行きますか？" }
        if isZh { return "麥克風或語音辨識的權限不足。前往iPhone設定中心嗎？" }
        return "Microphone or Speech Recognization permission is not granted. Do you like go to iOS Setting to set it"
    }

    var gotoIOSCenterOKTitle: String {
        if isJa { return "設定へ行きます" }
        if isZh { return "前往iPhone設定中心" }
        return "Go to iOS Setting"
    }

    var gotoIOSCenterCancelTitle: String {
        if isJa { return "キャンセル"}
        if isZh { return "取消" }
        return "Cancel"
    }

    var speechErrorMessage: String {
        if isJa { return "音声をAppleに送信中にエラーが発生しました。" }
        if isZh { return "傳送聲音往Apple時，錯誤發生。"}
        return "An error occurred when transmitting voice to Apple."
    }

    var continueGameButtonTitle: String {
        if isJa { return "つづく" }
        if isZh { return "回到遊戲"}
        return "Back to Game"
    }

    var finishGameButtonTitle: String {
        if isJa { return "ゲームを終る" }
        if isZh { return "結束遊戲"}
        return "Stop Game"
    }

    var langToSpeak: String {
        switch gameLang {
        case .jp:
            return japanese
        case .en:
            return english
        }
    }

    var cancel: String {
        if isJa { return "キャンセル" }
        if isZh { return "取消" }
        return "Cancel"
    }

    var done: String {
        if isJa { return "完了" }
        if isZh { return "完成" }
        return "Done"
    }

    var wantToSayLabel: String {
        if isJa { return "今話したいのは" }
        if isZh { return "我現在想說" }
        return "It's time to speak "
    }

    var setting: String {
        if isJa || isZh { return "設  定"}
        return "Setting"
    }

    var chinese: String {
        if isJa { return "中国語" }
        if isZh { return "中文" }
        return "Chinese"
    }

    var japanese: String {
        if isJa { return "日本語" }
        if isZh { return "日文" }
        return "Japanese"
    }

    var english: String {
        if isJa { return "英語" }
        if isZh { return "英文" }
        return "English"
    }

    var englishOrJapanese: String {
        return "\(english) / \(japanese)"
    }

    var chineseOrJapanese: String {
        return "\(chinese) / \(japanese)"
    }

    func getLangDescription(langAndRegion: String) -> String {
        let pairs = langAndRegion.split(separator: "-")
                                 .map { substring in substring.s}
        let lang = pairs[0] == "ja" ? japanese : english
        let region = getRegion(region: pairs[1])
        if region == "" { return lang }
        return "\(lang) (\(region))"
    }

    func getRegion(region: String) -> String {
        if region == "US" { return us }
        if region == "GB" { return gb }
        if region == "IE" { return ie }
        if region == "AU" { return au }
        if region == "ZA" { return za }
        return ""
    }

    var us: String {
        if isJa { return "アメリカ" }
        if isZh { return "美國" }
        return "American"
    }

    var gb: String {
        if isJa { return "英国" }
        if isZh { return "英國" }
        return "United Kingdom"
    }

    var au: String {
        if isJa { return "アオースラリア" }
        if isZh { return "澳洲" }
        return "Australia"
    }
    var ie: String {
        if isJa { return "アイルランド" }
        if isZh { return "愛爾蘭" }
        return "Ireland"
    }
    var za: String {
        if isJa { return "南アフリカ" }
        if isZh { return "南非" }
        return "South Africa"
    }

    var syllablesCount: String {
        if isZh { return gameLang == .jp ? "假名數" : "音節數" }
        return gameLang == .jp ? "仮名数" : "音節数"
    }

    var sentencesCount: String {
        if isZh { return "句數"}
        return "句数"
    }

    var topicPageTitile: String {
        return "\(languageInJa) - 話題"
    }

    var infiniteChallengeTitle: String {
        return "\(languageInJa) - 無限挑戦"
    }

    var languageInJa: String {
        return gameLang == .jp ? "日本語" : "英語"
    }

    var language: String {
        if gameLang == .jp {
            return japanese
        }
        return english
    }
}
