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

    var lang: Lang {
        if isZh { return .zh }
        if isJa { return .ja }
        return .en
    }

    var langCode: String? {
        return Locale.current.languageCode
    }

    var regionCode: String? {
        return Locale.current.regionCode
    }

    var isJa: Bool {
        return langCode == "ja"
    }

    var isZh: Bool {
        return langCode == "zh"
    }

    var isHK: Bool {
        return regionCode == "HK"
    }

    var isCN: Bool {
        return regionCode == "CN"
    }

    var speed: String {
        if isJa || isZh { return "速度" }
        return "Speed"
    }

    var confirm: String {
        if isZh { return "我知道了" }
        return "OK"
    }

    var narratorLabel: String {
        if isJa { return "挑戦の説明" }
        if isZh { return "語音說明" }
        return "Description"
    }

    var translationLanguageLabel: String {
        if isJa { return "翻訳言語" }
        if isZh { return "翻譯語言" }
        return "Translation Lang"
    }

    var monitoringLabel: String {
        if isJa { return "モニタリング（有線イヤホン）" }
        if isZh { return "即時監聽 (有線耳機 Only)" }
        return "Wired Monitroing"
    }

    var gotoIOSSettingButtonTitle: String {
        if isJa { return "iOS 設定へ" }
        if isZh { return "前往 iOS 設定中心" }
        return "Go to iOS Setting Center"
    }

    var speechText: String {
        if isJa {
            if #available(iOS 13, *) {
                return "読み上げコンテンツ"
            } else {
                return "スピーチ"
            }
        }

        if isZh {
            if #available(iOS 13, *) {
                return "語音內容"
            } else {
                return "語音"
            }
        }

        if #available(iOS 13, *) {
            return "Spoken Content"
        } else {
            return "Speech"
        }
    }

    var general: String {
        if #available(iOS 14, *) {
            return ""
        }
        if isJa {
            return "一般 > "
        }
        if isZh {
            return "一般 > "
        }

        return "General > "
    }

    var voiceNotAvailableMessage: String {
        if isJa {
            return "もっと声をダウンロードしましょう\n「設定 > \(general)アクセシビリティ > \(speechText) > 声 」の順に選択しましょう。"
        }
        if isZh { return "更多語音選項: \n請前往手機的「設定 > \(general)輔助使用 > \(speechText) > 聲音」下載" }
        return "Download more voices:\nGo to Settings > \(general)Accessibility > \(speechText) > Voices"
    }

    func voiceIsNotAvailable(lang: String) -> String {
        if isJa { return "\(lang)の声をダウンロードしましょう\n「設定 > \(general)アクセシビリティ > \(speechText) > 声 > \(lang)」の順に選択しましょう。" }
        if isZh { return "找不到\(lang)語音：\n請前往手機的「設定 > \(general)輔助使用 > \(speechText) > 聲音 > \(lang)」下載" }
        return "No \(lang) Voice found:\nGo to Settings > \(general)Accessibility > \(speechText) > Voices to Download"
    }

    var settingSectionGameSetting: String {
        if isJa { return "ゲーム設定" }
        if isZh { return "遊戲設定" }
        return "Game Setting"
    }

    var settingSectionGameSpeed: String {
        if isJa { return "ゲーム速度" }
        if isZh { return "遊戲速度" }
        return "Game Speed"
    }

    var settingSectionPracticeSpeed: String {
        if isJa { return "練習速度" }
        if isZh { return "練習速度" }
        return "Practice Speed"
    }

    var micAndSpeechPermission: String {
        if isJa { return "音声認識の権限、アプリの言語" }
        if isZh { return "APP 的語言、語音辨識權限" }
        return "Mic Permissions / App Language"
    }

    var gameOver: String {
        if isJa { return "ゲーム終了" }
        if isZh { return "遊戲結束" }
        return "Game Over"
    }

    var gameStartedWithGuideVoice: String {
        if isJa { return "私のあとに\(langToSpeak)を繰り返してください。" }
        if isZh { return "當我說完\(langToSpeak)後，請跟著說～" }
        return "Please repeat \"\(langToSpeak)\" after me."
    }

    var gameStartedWithEchoMethod: String {
        if isJa { return "\(langToSpeak)の文を聞いて、回想して、繰り返してください。" }
        if isZh { return "聽我說\(langToSpeak)後，在心中回放一次、在之後跟著說～" }
        return "Please replay my voice in mind, then speak it"
    }

    var gameStartedWithoutGuideVoice: String {
        if isJa { return "\(langToSpeak)の文を読んていってください。" }
        if isZh { return "請唸出對應的\(langToSpeak)。" }
        return "Please speak displayed \"\(langToSpeak) sentences\"."
    }

    var reachDailyGoal: String {
        if gameLang == .ja { return "今日の目標を完成しました。よくやった！" }
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
        return "Speech Voices"
    }

    var teacherLabel: String {
        if gameLang == .ja {
            if isJa { return "日本語先生" }
            if isZh { return "日文老師" }
            return "Teacher"
        }

        if isJa { return "英語先生" }
        if isZh { return "英文老師" }
        return "Teacher"
    }

    var assistantLabel: String {
        if gameLang == .ja {
            if isJa { return "日本語アシスタント" }
            if isZh { return "日文助理" }
            return "Assisant"
        }
        if isJa { return "英語アシスタント" }
        if isZh { return "英文助理" }
        return "Assisant"
    }

    var translatorLabel: String {
        if isJa { return "翻訳アシスタント" }
        if isZh { return "翻譯助理" }
        return "Translator"
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
        if isJa { return "キャンセル" }
        if isZh { return "取消" }
        return "Cancel"
    }

    var langToSpeak: String {
        switch gameLang {
        case .ja:
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
        if isJa || isZh { return "完成" }
        return "Done"
    }

    var wantToSayLabel: String {
        if isJa { return "今話したいのは" }
        if isZh { return "我現在想說" }
        return "I like to speak "
    }

    var setting: String {
        if isJa || isZh { return "設  定" }
        return "Settings"
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

    var translationLang: String {
        switch GameContext.shared.gameSetting.translationLang {
        case .ja:
            return japanese
        case .en:
            return english
        case .zh:
            return chinese
        default:
            return ""
        }
    }

    var translation: String {
        if isJa { return "翻訳" }
        if isZh { return "翻譯" }
        return "Translation"
    }

    var defaultVoice: String {
        if isJa { return "" }
        if isZh { return "預設" }
        return "default"
    }

    var enAbbr: String {
        if isJa || isZh { return "英" }
        return "En"
    }

    var jaAbbr: String {
        if isJa || isZh { return "日" }
        return "Ja"
    }

    var translationOrOriginal: String {
        return "\(langToSpeak) / \(translationLang)"
    }

    var japaneseOrChinese: String {
        return "\(japanese) / \(chinese)"
    }

    var challenge: String {
        if isJa { return "挑戦" }
        if isZh { return "關卡" }
        return "Challenge"
    }

    func getLangDescription(langAndRegion: String) -> String {
        let pairs = langAndRegion.split(separator: "-")
            .map { substring in substring.s }
        let lang = pairs[0] == "ja" ? japanese : ((pairs[0] == "en") ? english : chinese)
        let region = getRegion(region: pairs[1])
        if region == "" { return lang }
        if langAndRegion == "zh-HK" {
            return "\(cantonese) (\(region))"
        } else {
            return "\(lang) (\(region))"
        }
    }

    var cantonese: String {
        if isJa { return "広東語" }
        if isZh { return "廣東話" }
        return "Cantonese"
    }

    func getLang(lang: String) -> String {
        if lang.contains("ja") {
            return japanese
        } else if lang.contains("en") {
            return english
        }
        return chinese
    }

    func getRegion(region: String) -> String {
        if region == "TW" { return tw }
        if region == "CN" { return cn }

        return (Locale.current.localizedString(forRegionCode: region) ?? "") + " \(flag(region))"
    }

    var tw: String {
        if isJa { return "台湾 🇹🇼" }
        if isZh { return "台灣 🇹🇼" }
        return "Taiwan 🇹🇼"
    }

    var cn: String {
        if isJa { return "中国 🇨🇳" }
        if isZh { return "中國 🇨🇳" }
        return "China 🇨🇳"
    }

    var syllablesCount: String {
        if isZh { return gameLang == .ja ? "假名數" : "音節數" }
        if isJa { return gameLang == .ja ? "仮名数" : "音節数" }
        return gameLang == .ja ? "Kanas" : "Syllables"
    }

    var sentencesCount: String {
        if isZh { return "句數" }
        if isJa { return "句数" }
        return "Sent."
    }

    var topicPageTitile: String {
        if isZh { return "主題 (\(language))" }
        if isJa { return "テーマ (\(language))" }
        return "Topics" // japanese is too long
    }

    var infiniteChallenge: String {
        if isZh { return "無限挑戰" }
        if isJa { return "無限挑戦" }
        return "Infinite Games"
    }

    var infiniteChallengeTitle: String {
        if isZh || isJa {
            return "\(infiniteChallenge) (\(language))"
        }
        return infiniteChallenge
    }

    var language: String {
        if gameLang == .ja {
            return japanese
        }
        return english
    }

    var continues: String {
        if isZh { return "連續" }
        if isJa { return "連続" }
        return "Streak"
    }

    var best: String {
        if isZh { return "最佳" }
        if isJa { return "ベスト" }
        return "Best"
    }

    var last7Days: String {
        if isZh { return "過去7天" }
        if isJa { return "過去7日間" }
        return "7 Days"
    }

    var last30Days: String {
        if isZh { return "過去30天" }
        if isJa { return "過去30日間" }
        return "30 Days"
    }

    var sentence: String {
        if isZh { return "句" }
        if isJa { return "文" }
        return "Sent."
    }

    var goalPrefix: String {
        if isZh { return "每天說對" }
        if isJa { return "毎日" }
        return "Daily"
    }

    var goalSuffix: String {
        if isZh { return "句" }
        if isJa { return "文" }
        return "Sent."
    }

    var goalText: String {
        if isJa || isZh {
            return "\(goalPrefix)\(GameContext.shared.gameSetting.dailySentenceGoal)\(goalSuffix)"
        }
        return "\(GameContext.shared.gameSetting.dailySentenceGoal) Sentences"
    }

    var simpleGoalText: String {
        if isZh || isJa {
            return "\(GameContext.shared.gameSetting.dailySentenceGoal)\(goalSuffix)"
        }
        return "Goal"
    }

    var sevenDays: String {
        if isZh { return "7天" }
        if isJa { return "7日" }
        return "7 days"
    }

    var thirtyDays: String {
        if isZh { return "30天" }
        if isJa { return "30日" }
        return "30 days"
    }

    var all: String {
        if isJa || isZh { return "全部" }
        return "All"
    }

    var day: String {
        if isZh { return "天" }
        if isJa { return "日" }
        return "Days"
    }

    var time: String {
        if isZh || isJa {
            return "時間"
        }
        return "Time"
    }

    var longTermGoalSuffix: String {
        if isZh { return "天。" }
        if isJa { return "日間" }
        return "days left."
    }

    var longTermGoalMiddleText: String {
        if isZh { return "% 已說，離完成" }
        if isJa { return "% を話した、完了まで" }
        return "% are said, "
    }

    var learningMode: String {
        if isJa { return "学習モード" }
        if isZh { return "學習模式" }
        return "Learning Mode"
    }

    var meaningAndSpeaking: String {
        if isJa { return "意味と発音" }
        if isZh { return "意義&發音" }
        return "Meaning"
    }

    var speakingOnly: String {
        if isJa { return "発音" }
        if isZh { return "跟讀" }
        return "Shadowing"
    }

    var interpretation: String {
        if isJa { return "通訳" }
        if isZh { return "口譯" }
        return "Interpreter"
    }

    var speedIs: String {
        if gameLang == .ja {
            return "速度は"
        }
        return "Speed is "
    }

    var restorePreviousPurchase: String {
        if isJa { return "購入記録を復元する" }
        if isZh { return "恢復購買紀錄" }
        return "Restore purchase records"
    }

    var startChallenge: String {
        if isJa { return "明日挑戦します" }
        if isZh { return "明天再挑戰" }
        return "Challenge it tomorrow"
    }

    var aboutTopicTranslation: String {
        if isJa { return "注：テーマモードには中国語の翻訳のみです" }
        if isZh { return "註：主題模式僅有中文翻譯" }
        return "For topic sentences, only Chinese translations are available"
    }

    var purchaseViewTitle: String {
        if isJa { return "[体験版] 毎日\(dailyFreeLimit)文の挑戦制限" }
        if isZh { return "[試玩版] 已達每日\(dailyFreeLimit)句挑戰限制" }
        return "[Trial version] Daily \(dailyFreeLimit) sentences limit is reached"
    }

    var purchaseViewMessage: String {
        if isJa { return "楽しい時間はあっという間に。\n\n〜 スタジオ大草原不可避 〜" }
        if isZh { return "\n希望你今天有玩的很開心。 \n\n〜 大草原不可避工作室 〜" }
        return "Hope you already have great fun today. \n\n〜 Studio 大草原不可避 〜"
    }

    var freeButtonPurchaseMessage: String {
        if isJa { return "\n[体験版制限] 1日に\(dailyFreeLimit)文だけを話すことができます。\n\n〜 スタジオ大草原不可避 〜" }
        if isZh { return "\n[試玩版限制] 一天只能挑戰\(dailyFreeLimit)句。\n\n〜 大草原不可避工作室 〜" }
        return "\n[Trial version constraint] User can only play \(dailyFreeLimit) sentences a day. \n\n〜 Studio 大草原不可避 〜"
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
        if isJa { return "完全版(1ヶ月) " }
        if isZh { return "正式版一個月" }
        return "Full Version (1 Month)"
    }

    var buyForever: String {
        if isJa { return "完全版(永久) " }
        if isZh { return "永久正式版" }
        return "Full Version (Forever)"
    }

    var cannotMakePayment: String {
        if isJa { return "iTunes Store や App Store で購入できない (ペアレンタルコントロールを使いますか？)" }
        if isZh { return "本機器沒有辦法付款 (家長保護控制開啟中?)" }
        return "This device is not able or allowed to make payments. (Is parental controls on?)"
    }

    var iCannotHearYou: String {
        if isJa { return "聞こえない" }
        if isZh { return "聽不清楚" }
        return "I cannot hear you"
    }

    var echoMethod: String {
        if isJa { return "エコー法" }
        if isZh { return "回音法" }
        return "Echo"
    }

    var speakTranslation: String {
        if isJa { return "翻訳を読む"}
        if isZh { return "唸出翻譯" }
        return "Speak Translation"
    }

    var listenToEcho: String {
        if isJa { return "心のエコーを聞いて" }
        if isZh { return "聽心中回音" }
        return "Listen to echo in mind"
    }

    var yourFeedbackMakeAppBetter: String {
        if isJa { return "君の声を聞かせて欲しい" }
        if isZh { return "你的聲音是 App 成長的原動力" }
        return "Your voice makes app better"
    }

    var gotoAppStore: String {
        if isJa { return "App Store へ" }
        if isZh { return "前往 App Store" }
        return "Go to App Store"
    }

    var gotoAcknowledge: String {
        if isJa { return "謝辞" }
        if isZh { return "致謝" }
        return "Acknowledgement"
    }

    var freeVersion: String {
        if isZh { return "試玩版" }
        if isJa { return "体験版" }
        return "Trial"
    }

    var itIsfreeVersion: String {
        if isJa { return "現在のバージョンは体験版です" }
        if isZh { return "目前的版本為試玩版" }
        return "You are using Trial Version"
    }

    var close: String {
        if isJa { return "閉じる" }
        if isZh { return "關閉" }
        return "Close"
    }

    var rank: String {
        if isJa || isZh { return "判定" }
        return "Rank"
    }

    var medal: String {
        if isZh { return "小徽章" }
        if isJa { return "メダル" }
        return "Medal"
    }

    var pts: String {
        if isZh { return "分" }
        if isJa { return "点" }
        return "%"
    }

    var playTime: String {
        if isZh { return "遊玩時間" }
        if isJa { return "遊びの時間" }
        return "Play Time"
    }

    var correctSentences: String {
        if isZh { return "唸對句數" }
        if isJa { return "正しい文" }
        return "Sentences"
    }

    var excellent: String {
        if isJa || isZh { return "正解" }
        return "Excellent"
    }

    var excellentShort: String {
        if isJa || isZh { return "正解" }
        return "XLNT"
    }

    var great: String {
        if isJa { return "すごい" }
        if isZh { return "真厲害" }
        return "Great"
    }

    var correct: String { // excellent + great
        if isJa { return "正しい" }
        if isZh { return "正確的" }
        return "Correct"
    }

    var good: String {
        if isJa { return "いいね" }
        if isZh { return "良好" }
        return "Good"
    }

    var wrong: String {
        if isJa { return "ミス" }
        if isZh { return "錯誤" }
        return "Wrong"
    }

    var mins: String {
        if isZh { return "分鐘" }
        if isJa { return "分" }
        return "mins"
    }

    var date: String {
        if isZh { return "日期" }
        if isJa { return "日付" }
        return "Date"
    }

    var completeness: String {
        if isZh || isJa { return "完成率" }
        return "Complete"
    }

    var previousGame: String {
        if isJa { return "前回の挑戦" }
        if isZh { return "上次的挑戦" }
        return "Last Game"
    }

    func getSpeakingStatus(percent: String, rank: String, reward: Int?) -> String {
        let context = GameContext.shared
        switch context.gameMode {
        case .medalMode:
            guard let reward = reward else { return "" }
            let rewardText = (reward >= 0 ? "plus \(reward)" : "\(reward)")
                                .replacingOccurrences(of: "-", with: " minus ")
            let rankText = rank.replacingOccurrences(of: "+", with: " plus ")

            return gameLang == .ja ?
                "\(percent)%、判定：\(rankText)、メダル：\(rewardText)" :
                "\(percent)% Completed. Rank: \(rankText)... Medal: \(rewardText)"
        default:
            if gameLang == .ja { return "完成率：\(percent)%、判定：\(rank)" }
            return "\(percent)% completed. Rank \(rank)..."
        }
    }

    var listening: String {
        if isZh { return "正在聽..." }
        if isJa { return "聞いています。" }
        return "listening..."
    }

    var todaySummary: String {
        if isZh { return "本日的統計" }
        if isJa { return "今日のまとめ" }
        return "Today's Summary"
    }

    var secs: String {
        if isJa, isZh { return "秒" }
        return "s"
    }

    var nextGame: String {
        if isJa { return "次の挑戦" }
        if isZh { return "下個挑戰" }
        return screen.width > 750 ? "Next Game" : "Next"
    }

    var noScore: String {
        if isZh { return "無分" }
        return "  "
    }

    var todayGoal: String {
        if isJa { return "今日の目標" }
        if isZh { return "今日的目標" }
        return "Today's Goal"
    }

    var today: String {
        if isJa { return "今日" }
        if isZh { return "今天" }
        return "Today"
    }

    var medalMode: String {
        if isJa { return "メダルモード" }
        if isZh { return "徽章模式" }
        return "Medal Game"
    }

    var acknowledgement: String {
        if isZh {
            return """
            感謝，以下語言開放資源：

            Tanaka Corpus (英、日對照句子)
            Tatoeba.org (英、日、中句子)
            OpenCC (中文轉換)
            mecab-neologd (日文自然語言處理)
            台灣大考中心六級英文單字表


            最後感謝，曾參與設計、測試問題的朋友：

            Amber Liu, Eason Chou, Jennifer Chen, kaminomi, msglight4874, Satolu, Sid Weng, Stella, Ruth Yuru Chen, 伯豪 & 小乖, 肉鬆, 歐頭
            """
        }
        return """
        Thanks for open data / free softwares：

        Tanaka Corpus (sentences)
        Tatoeba.org (sentences)
        OpenCC (Chinese Conversion)
        mecab-neologd (nlp for Japanese)
        English vocabuly list from Taiwan College Entrance Center


        Thanks for people who help to design / test this app：

        Amber Liu, Eason Chou, Jennifer Chen, kaminomi, msglight4874, Satolu, Sid Weng, Stella, Ruth Yuru Chen, 伯豪 & 小乖, 肉鬆, 歐頭
        """
    }

    var tip1: String {
        let teacherName = gameLang == .ja ? "Otoya" : "Samatha"
        if isZh { return "安裝高品質語音。(\(teacherName) 300MB, iPhone設定：「輔助使用 > 語音」)" }
        if isJa { return "高品質の声をダウンロードしましょう。(\(teacherName) 300MB, iPhoneの設定：「アクセシビリティ」>「スピーチ」)" }
        return "Download high-quality voices (\(teacherName) 300MB) from iPhone Setting:「Accessibility > Speech」。"
    }

    var tip2: String {
        if isZh { return "用有線耳麥、監聽自己的聲音。" }
        if isJa { return "有線イヤホンを使用して、自分の声をモニタリングする。" }
        return "Use wired Apple earbuds to monitoring spoken voice. "
    }

    var tip3: String {
        if isZh { return "Siri 只聽得懂咬字清楚、大聲的句子。" }
        if isJa { return "Siriは、歯切れの良い大きな声だけを理解できる。" }
        return "Please articulate and keep voice loud."
    }

    var tip4: String {
        if gameLang == .en {
            if isZh { return "選英國腔老師時、Siri只聽得懂英國腔。" }
            if isJa { return "イギリスの先生を選んだ時、イギリスのアクセントを話そう。" }
            return "When choosing teacher from England, speak in England's accent."
        } else {
            if isZh { return "日文新手請從「主題模式」開始" }
            if isJa { return "初心者は「テーマモード」から始めてください。" }
            return "For Japanese beginner, please play \"Topic Mode\" first."
        }
    }

    var tip5: String {
        if isZh { return "挑選一個適合自己的速度。" }
        if isJa { return "自分に合う速度を選んでください。" }
        return "Choose the suitable speed for your level."
    }

    var tip6: String {
        if isZh { return "躺在床上唸錯時，請做仰臥起坐、保持清醒。" }
        if isJa { return "ベッドで間違って話した後に、腹筋運動をします。" }
        return "When practicing on the bed, do sit-ups after speaking wrongly."
    }

    var tip7: String {
        if isZh { return "當Siri說話時、請專注聽、螢幕只是輔助。" }
        if isJa { return "シリが話しているときはリスニングに集中してください。" }
        return "Focus on listening when siri is talking. (not focus on watching)"
    }

    var tip8: String {
        if isZh { return "累了、就休息一下。這樣學的更快。" }
        if isJa { return "疲れたら、少し休みましょう。これはもっと速い道です。" }
        return "If you feel tired, take a rest. Learning speed will be faster."
    }

    var tip9: String {
        if isZh { return "在安靜、有穩定網路的地方練習。" }
        if isJa { return "安定したネットワークで静かな場所で練習しましょ。" }
        return "Practice at a quiet place with stable network"
    }

    func getRandTip() -> String {
        // higher accuracy for tip1 & tip4
        return [tip1, tip1, tip2, tip3, tip4, tip4, tip5, tip6, tip7, tip8, tip9]
            .randomElement()!
    }
}

func flag(_ country: String) -> String {
    let base: UInt32 = 127397
    var s = ""
    for v in country.unicodeScalars {
        s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
    }
    return String(s)
}

// swiftlint:enable file_length  type_body_length
