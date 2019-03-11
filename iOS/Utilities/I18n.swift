//
//  I18n.swift
//  今話したい
//
//  Created by Wangchou Lu on 10/26/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//
// swiftlint:disable file_length type_body_length
import Foundation

let i18n = I18n.shared

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

    var speed: String {
        if isJa || isZh { return "速度" }
        return "Speed"
    }

    var narratorLabel: String {
        if isJa { return "挑戦の説明" }
        if isZh { return "開始語音說明" }
        return "Initial Descriptions"
    }
    var monitoringLabel: String {
        if isJa { return "モニタリング（有線イヤホンのみ）"}
        if isZh { return "即時監聽 (有線耳機 Only)" }
        return "Wired Monitoring"
    }
    var gotoIOSSettingButtonTitle: String {
        if isJa { return "iPhone 設定へ" }
        if isZh { return "前往 iPhone 設定中心" }
        return "Go to iPhone Setting Center"
    }
    var voiceNotAvailableMessage: String {
        let lang = gameLang == .jp ? japanese : english
        if isJa { return "もっと声をダウンロードしましょう\n「設定」>「一般」>「アクセシビリティ」>「スピーチ」 >「声」>「\(lang)」の順に選択します。" }
        if isZh { return "更多語音選項: \n請前往手機的「設定 > 一般 > 輔助使用 > 語音 > 聲音 > \(lang)」下載" }
        return "Download more voices:\nGo to Settings > General > Accessibility > Speech > Voice > \(lang)"
    }

    var settingSectionGameSpeed: String {
        if isJa { return "挑戦中"}
        if isZh { return "遊戲時" }
        return "Game Speed"
    }
    var settingSectionPracticeSpeed: String {
        if isJa { return  "練習の速度" }
        if isZh { return "練習的速度" }
        return "Practice Speed"
    }
    var gameSetting: String {
        if isJa { return "ゲーム設定" }
        if isZh { return "遊戲設定" }
        return "Game Settings"
    }
    var micAndSpeechPermission: String {
        if isJa { return "マイク と 音声認識の権限" }
        if isZh { return "麥克風與語音辨識權限" }
        return "Mic and Recognition Permissions"
    }

    var gameOver: String {
        if isJa { return "ゲーム終了" }
        if isZh { return "遊戲結束" }
        return "Game Over"
    }

    var gameStartedWithGuideVoice: String {
        if isJa { return "私のあとに\(langToSpeak)を繰り返してください。" }
        if isZh { return "當我說完\(langToSpeak)後，請跟著說～" }
        return "Please repeat \"\(langToSpeak) Sentences\" after me."
    }

    var gameStartedWithEchoMethod: String {
        if isJa { return "\(langToSpeak)の文を聞いて、回想して、繰り返してください。" }
        if isZh { return "聽我說\(langToSpeak)後，在心中回放一次、在之後跟著說～" }
        return "Please replay my voice in mind, then speak it"
    }

    var gameStartedWithoutGuideVoice: String {
        if isJa { return "\(langToSpeak)の文を読んていってください。" }
        if isZh { return "請唸出對應的\(langToSpeak)。" }
        return "Please speak displayed \"\(langToSpeak) Sentences\"."
    }

    var reachDailyGoal: String {
        if gameLang == .jp { return "今日の目標を完成しました。" }
        return "Daily goal is completed. Good Job!"
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
        return "Text to Speech (\(langToSpeak))"
    }
    var teacherLabel: String {
        if gameLang == .jp {
            if isJa { return "日本語先生" }
            if isZh { return "日文老師" }
            return "Teacher"
        }

        if isJa { return "英語先生" }
        if isZh { return "英文老師" }
        return "Teacher"
    }
    var assistantLabel: String {
        if gameLang == .jp {
            if isJa { return "日本語アシスタント" }
            if isZh { return "日文助理" }
            return "Assisant"
        }
        if isJa { return "英語アシスタント" }
        if isZh { return "英文助理" }
        return "Assisant"
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
        if isZh { return "繼續遊戲"}
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
        default:
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
        if isZh || isJa { return "\(english) / \(japanese)" }
        return "英語 / 日本語"
    }

    var chineseOrJapanese: String {
        if isZh || isJa { return "\(chinese) / \(japanese)" }
        return "中国語 / 日本語"
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
        if isJa { return "アメリカ 🇺🇸" }
        if isZh { return "美國 🇺🇸" }
        return "American 🇺🇸"
    }

    var gb: String {
        if isJa { return "英国 🇬🇧" }
        if isZh { return "英國 🇬🇧" }
        return "United Kingdom 🇬🇧"
    }

    var au: String {
        if isJa { return "アオースラリア 🇦🇺" }
        if isZh { return "澳洲 🇦🇺" }
        return "Australia 🇦🇺"
    }
    var ie: String {
        if isJa { return "アイルランド 🇨🇮" }
        if isZh { return "愛爾蘭 🇨🇮" }
        return "Ireland 🇨🇮"
    }
    var za: String {
        if isJa { return "南アフリカ 🇿🇦" }
        if isZh { return "南非 🇿🇦" }
        return "South Africa 🇿🇦"
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
        return "話題 (\(languageInJa))"
    }

    var infiniteChallengeTitle: String {
        return "無限挑戦 (\(languageInJa))"
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
    var continues: String {
        if isZh { return "連續" }
        return "連続"
    }
    var best: String {
        if isZh { return "最佳" }
        return "ベスト"
    }
    var last7Days: String {
        if isZh { return "過去7天" }
        return "過去7日間"
    }

    var last30Days: String {
        if isZh { return "過去30天" }
        return "過去30日間"
    }
    var sentence: String {
        if isZh { return "句" }
        return "文"
    }
    var goalPrefix: String {
        if isZh { return "每天說對" }
        return "毎日"
    }
    var goalSuffix: String {
        if isZh { return "句" }
        return "文"//を正しく話す"
    }
    var day: String {
        if isZh { return "天"}
        return "日"
    }
    var dayRange: String {
        if isZh { return "天"}
        return "日間"
    }
    var longTermGoalMiddleText: String {
        if isZh { return "% 已說，離完成"}
        return "% を話した、完了まで"
    }

    var learningMode: String {
        if isJa { return "学習モード" }
        if isZh { return "學習模式" }
        return "Learning Mode"
    }

    var meaningAndSpeaking: String {
        if isJa { return "意味と発音" }
        if isZh { return "意義與發音" }
        return "meaning"
    }

    var speakingOnly: String {
        if isJa { return "発音のみ" }
        if isZh { return "跟讀" }
        return "shadowing"
    }

    var interpretation: String {
        if isJa { return "通訳" }
        if isZh { return "口譯" }
        return "interpreter"
    }
    var speedIs: String {
        if gameLang == .jp {
            return "速度は"
        }
        return "Speed is "
    }
    var canChangeItLaterInSetting: String {
        if isJa { return "後で、設定ページから変更することができます。" }
        if isZh { return "之後可從設定頁面更改。" }
        return "It could be changed from the settings page later."
    }
    var restorePreviousPurchase: String {
        if isJa { return "購入記録を復元する" }
        if isZh { return "恢復購買紀錄" }
        return "Restore purchase records"
    }
    var startChallenge: String {
        if isJa { return "挑戦を続ける" }
        if isZh { return "繼續挑戰"}
        return "Continue to challenge"
    }
    var purchaseViewTitle: String {
        if isJa { return "[無料版] 毎日\(dailyFreeLimit)文の挑戦制限" }
        if isZh { return "[免費版] 每日\(dailyFreeLimit)句挑戰限制" }
        return "[Free version] Daily \(dailyFreeLimit) sentences limit"
    }
    var purchaseViewMessage: String {
        if isJa { return "\nアイテムは自動的に更新されませんので、\nお気軽に購入してください。\n\n〜 スタジオ大草原不可避 〜" }
        if isZh { return "\n所有項目皆不會自動續約、請安心購買。\n\n〜 大草原不可避工作室 〜" }
        return "\nPurchased item will not auto-renew. \nPlease feel free to buy it.\n\n〜 Studio 大草原不可避 〜"
    }
    var freeButtonPurchaseMessage: String {
        if isJa { return "\n[無料版制限] 1日に100文を話すと広告が表示されます。アイテムは自動的に更新されませんので、お気軽に購入してください。\n\n〜 スタジオ大草原不可避 〜" }
        if isZh { return "\n[免費版限制] 一天唸超過一百句後、會顯示廣告。以下項目皆不會自動續約、請安心購買。\n\n〜 大草原不可避工作室 〜" }
        return "\n[Free version constraint] Ads will be displayed after speaking more than 100 sentences a day. Purchased item will not auto-renew. \nPlease feel free to buy it.\n\n〜 Studio 大草原不可避 〜"
    }
    var previousPurchaseRestored: String {
        if isJa { return "購入記録を復元しました" }
        if isZh { return "已恢復過去購買紀錄" }
        return "Past purchase records are restored"
    }
    var iGotIt: String {
        if isJa { return "わかりました" }
        if isZh { return "我知道了" }
        return "Ok"
    }
    var processing: String {
        if isJa { return "処理しています。" }
        if isZh { return "處理中" }
        return "processing"
    }
    var buyOneMonth: String {
        if isJa { return "1ヶ月有料版" }
        if isZh { return "付費版一個月" }
        return "Paid Version (1 Month)"
    }
    var buyThreeMonths: String {
        if isJa { return "3ヶ月有料版" }
        if isZh { return "付費版三個月" }
        return "Paid Version (3 Months)"
    }
    var buyForever: String {
        if isJa { return "永久有料版" }
        if isZh { return "永久付費版" }
        return "Paid Version (Forever)"
    }
    var cannotMakePayment: String {
        if isJa { return "iTunes Store や App Store で購入できない (ペアレンタルコントロールを使いますか？)" }
        if isZh { return "本機器沒有辦法付款 (家長保護控制開啟中?)" }
        return "This device is not able or allowed to make payments. (Is Parental controls on?)"
    }
    var iCannotHearYou: String {
        if isJa { return "聞こえない" }
        if isZh { return "聽不清楚"}
        return "I cannot hear you"
    }
    var remaining: String {
        if isJa { return "まだ" }
        if isZh { return "還有"}
        return "まだ"
    }
    var echoMethod: String {
        if isJa { return "エコー法"}
        if isZh { return "回音法" }
        return "mind echo"
    }
    var listenToEcho: String {
        if isJa { return "心のエコーを聞いて" }
        if isZh { return "聽心中回音" }
        return "Listen to echo in mind."
    }
    var yourFeedbackMakeAppBetter: String {
        if isJa { return "あなたの声はAppの成長の原動力です" }
        if isZh { return "您的回饋是 App 成長的原動力"}
        return "Your feedback makes app better."
    }
    var gotoAppStore: String {
        if isJa { return "App Store へ" }
        if isZh { return "前往 App Store"}
        return "Go to App Store"
    }
    var freeVersion: String {
        if isZh { return "免費版" }
        return "無料版"
    }
    var itIsfreeVersion: String {
        if isJa { return "現在のバージョンは無料版です" }
        if isZh { return "目前的版本為免費版"}
        return "You are using Free Version"
    }
    var close: String {
        if isJa { return "閉じる" }
        if isZh { return "關閉"}
        return "Close"
    }

    func getSpeakingStatus(percent: String, rank: String) -> String {
        if gameLang == .jp { return "完成率：\(percent)%、判定：\(rank)" }
        return "\(percent)% completed. Rank \(rank)."
    }
}
// swiftlint:enable file_length  type_body_length
