//
//  ViewController.swift
//  voicePrototype
//
//  Created by Wangchou Lu on R 2/12/21.
//

import UIKit
import AVFoundation
import Promises

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        SpeechEngine.shared.start()
        AVSpeechSynthesisVoice.speechVoices().forEach {
            if $0.language.contains("ja") {
                print($0.identifier)
            }
        }
    }

    @IBAction func button1Cliced(_ sender: Any) {
        let engine = SpeechEngine.shared
        let otoya = "com.apple.ttsbundle.Otoya-premium"
        //let oren = "com.apple.ttsbundle.siri_female_ja-JP_compact"
        engine.say("文型練習：まるまるはどこですか？ー。ー。まるまるはまるまるにあります。", voiceId: otoya, speed: 0.8, lang: .ja)
            .then {
                engine.say("1、テレビ。ー。ー。本棚の上。", voiceId: otoya, speed: 0.8, lang: .ja)
            }.then { _ -> Promise<[String]> in
                return engine.listen(duration: 6, localeId: "ja_JP")
            }.then { _ in
                engine.say("2、鉛筆。ー。ー。机の上", voiceId: otoya, speed: 0.8, lang: .ja)
            }.then {
                return engine.listen(duration: 6, localeId: "ja_JP")
            }.then {
                print($0)
            }
    }
}
