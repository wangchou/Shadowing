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
        return isJa ? "自動速度" : "自動速度"
    }

    var translationLabel: String {
        return isJa ? "中国語翻訳" : "中文翻譯"
    }
    var guideVoiceLabel: String {
        return isJa ? "ガイド音声" : "日文引導朗讀"
    }
    var narratorLabel: String {
        return isJa ? "ゲーム中国語説明" : "遊戲開始中文說明"
    }
    var gotoIOSSettingButtonTitle: String {
        return isJa ? "iPhone設定へ" : "前往iPhone設定中心"
    }
    var defaultText: String {
        return isJa ? "デフォルト" : "預設"
    }
    var voiceNotAvailableTitle: String {
        return isJa ? "選らんた声はまだダウンロードされていません" : "你選的語音還未下載"
    }
    var voiceNotAvailableMessage: String {
        return isJa ? "iPhoneの「設定 > 一般 > アクセシビリティ > スピーチ > 声 > 日本語」で、ダウンロードしましょう。":"請於手機的「設定 > 一般 > 輔助使用 > 語音 > 聲音 > 日文」下載相關語音。"
    }
    var voiceNotAvailableOKButton: String {
        return isJa ? "わかった" : "知道了"
    }

    var settingSectionGameSpeed: String {
        return isJa ? "ゲーム時の読み上げ速度": "遊戲時的朗讀速度"
    }
    var settingSectionPracticeSpeed: String {
        return isJa ? "練習時の読み上げ速度": "練習時的朗讀速度"
    }
    var gameSetting: String {
        return isJa ? "ゲーム設定": "遊戲設定"
    }
    var micAndSpeechPermission: String {
        return isJa ? "マイクと音声認識のアクセス権限": "麥克風與語音辨識權限"
    }
    var japaneseTeacher: String {
        return isJa ? "日本語先生": "日文老師"
    }
    var japaneseAssistant: String {
        return isJa ? "日本語アシスタント": "日文助理"
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
}
