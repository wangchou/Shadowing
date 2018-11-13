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
        if isJa { return "中国語翻訳" }
        if isZh { return "中文翻譯" }
        return "Chinese Translation"
    }
    var guideVoiceLabel: String {
        if isJa { return "ガイド音声" }
        if isZh { return "日文引導朗讀" }
        return "Guide Voice"
    }
    var narratorLabel: String {
        if isJa { return "ゲーム中国語説明" }
        if isZh { return "遊戲開始中文說明" }
        return "Chinese Descriptions"
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
        if isJa { return "iPhoneの「設定 > 一般 > アクセシビリティ > スピーチ > 声 > 日本語」で、ダウンロードしましょう。" }
        if isZh { return "請於手機的「設定 > 一般 > 輔助使用 > 語音 > 聲音 > 日文」下載相關語音。" }
        return "Download new voice via Settings > General > Accessibility > Speech > Voice > Japanese"
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
    var japaneseTeacher: String {
        if isJa { return "日本語先生" }
        if isZh { return "日文老師" }
        return "Japanese Teacher"
    }
    var japaneseAssistant: String {
        if isJa { return "日本語アシスタント" }
        if isZh { return "日文助理" }
        return "Japanese Assisant"
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

    var settingTitle: String {
        if isJa { return "今話したいのは..." }
        if isZh { return "我現在想說..." }
        return "I like to speak..."
    }

    var setting: String {
        if isJa || isZh { return "設  定"}
        return "Setting"
    }

    var japanese: String {
        if isJa || isZh { return "日本語" }
        return "Japanese"
    }

    var english: String {
        if isJa || isZh { return "英語" }
        return "English"
    }
}
