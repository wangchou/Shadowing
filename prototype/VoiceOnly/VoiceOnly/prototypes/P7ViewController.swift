//
//  P1ViewController.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/04/24.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit
import Speech


fileprivate let listenPauseDuration = 0.4

// Prototype 7: prototype 6 + 遊戲畫面。在 getScore 後 update UI
// Loop {
//  日文
//  使用者複述
//  説(我聽到你說)
//  辨識出的 TTS
//  分數
// }

enum ScoreDesc {
    case perfect
    case great
    case good
    case poor
}

class P7ViewController: UIViewController, AVSpeechSynthesizerDelegate {
    let audio = AudioController.shared
    @IBOutlet weak var comboLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var bloodBar: UIProgressView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var targetTextView: UITextView!
    @IBOutlet weak var saidTextView: UITextView!
    @IBOutlet weak var scoreDescLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        comboLabel.text = "0"
        scoreLabel.text = "0"
        bloodBar.progress = 0.6
        
        targetTextView.text = ""
        targetTextView.layer.cornerRadius = 5
        targetTextView.layer.borderColor = UIColor.black.cgColor
        targetTextView.layer.borderWidth = 1
        
        saidTextView.text = ""
        saidTextView.layer.cornerRadius = 5
        saidTextView.layer.borderColor = UIColor.yellow.cgColor
        saidTextView.layer.borderWidth = 1
        
        scoreDescLabel.text = ""
        
        audio.start()
        repeatAfterMe()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        audio.stop()
    }
    
    func repeatAfterMe() {
        print("----------------------------------")
        let audio = AudioController.shared
        let sentence = sentences[sentenceIndex]
        
        // completionHandler chain
        let speakTime = getNow()
        focusTextView(isTargetView: true)
        audio.say(sentence, teacher, rate: teachingRate, delegate: self)
        {   self.focusTextView(isTargetView: false)
            audio.listen(
            listenDuration: (getNow() - speakTime) + listenPauseDuration,
            resultHandler: self.speechResultHandler
            )
        }
    }
    
    private func repeatWhatSaid(_ saidSentence: String, completionHandler: @escaping (Int)->Void) {
        let audio = AudioController.shared
        var speechScore: Int = 0
        let group = DispatchGroup()
        
        group.enter()
        audio.say(saidSentence, Oren, rate: teachingRate) { group.leave() }
        
        group.enter()
        let targetSentence = sentences[sentenceIndex]
        getSpeechScore(targetSentence, saidSentence) {
            speechScore = $0
            group.leave()
        }
        
        group.notify(queue: .main) {
            completionHandler(speechScore)
        }
    }
    
    func iHearYouSaid(_ saidSentence: String) {
        let audio = AudioController.shared
        print("hear <<< \(saidSentence)")
        
        // completionHandler chain
        audio.say(I_HEAR_YOU_HINT, assistant)
        {   self.repeatWhatSaid(saidSentence)
        {   sentenceIndex = (sentenceIndex + 1) % sentences.count
            let score: Int = $0
            self.updateBlood(score)
            self.updateScoreLabel(score)
            self.updateComboLabel(score)
            self.updateScoreDescLabel(score)
            audio.say(self.getScoreText(score), Oren)
        {   self.repeatAfterMe()
        }}}
    }
    
    func getScoreDesc(_ score: Int) -> ScoreDesc {
        if(score >= 100) { return .perfect }
        if(score >= 80) { return .great }
        if(score >= 60) { return .good}
        return .poor
    }
    
    // Pragma Mark: - update UI part
    func focusTextView(isTargetView: Bool) {
        if isTargetView {
            targetTextView.text = ""
            saidTextView.text = ""
            scoreDescLabel.text = ""
            targetTextView.layer.borderColor = UIColor.black.cgColor
            saidTextView.layer.borderColor = UIColor.yellow.cgColor
        } else {
            saidTextView.text = ""
            saidTextView.layer.borderColor = UIColor.black.cgColor
            targetTextView.layer.borderColor = UIColor.yellow.cgColor
        }
    }
    
    func updateScoreLabel(_ score: Int) {
        scoreLabel.text = String((Int(scoreLabel.text!)! + score))
    }
    
    func updateComboLabel(_ score: Int) {
        let scoreDesc = getScoreDesc(score)
        switch scoreDesc {
        case .perfect, .great:
            comboLabel.text = String(Int(comboLabel.text!)! + 1)
        case .good, .poor:
            comboLabel.text = "0"
        }
    }

    func updateBlood(_ score: Int) {
        let scoreDesc = getScoreDesc(score)
        switch scoreDesc {
        case .perfect:
            bloodBar.progress = min(1.0, bloodBar.progress + 0.1)
        case .great:
            bloodBar.progress = min(1.0, bloodBar.progress + 0.05)
        case .good:
            bloodBar.progress = min(1.0, bloodBar.progress + 0.02)
        case .poor:
            bloodBar.progress = max(0, bloodBar.progress - 0.1)
        }
    }
    
    func getScoreText(_ score: Int) -> String {
        let scoreDesc = getScoreDesc(score)
        switch scoreDesc {
        case .perfect:
            return "正解！"
        case .great:
            return "すごい"
        case .good:
            return "いいね"
        case .poor:
            return "違います"
        }
    }
    
    func updateScoreDescLabel(_ score: Int) {
        let scoreDesc = getScoreDesc(score)
        switch scoreDesc {
        case .perfect:
            scoreDescLabel.text = "正解"
            scoreDescLabel.textColor = UIColor.orange
        case .great:
            scoreDescLabel.text = "すごい"
            scoreDescLabel.textColor = UIColor.green
        case .good:
            scoreDescLabel.text = "いいね"
            scoreDescLabel.textColor = UIColor.blue
        case .poor:
            scoreDescLabel.text = "違います"
            scoreDescLabel.textColor = UIColor.red
            
        }
    }
    
    // Speech Recognition delegate
    func speechResultHandler(result: SFSpeechRecognitionResult?, error: Error?) {
        let audio = AudioController.shared
        if !audio.isRunning {
            return
        }
        
        if let result = result {
            saidTextView.text = result.bestTranscription.formattedString
            if result.isFinal {
                iHearYouSaid(result.bestTranscription.formattedString)
            }
        }
        
        if error != nil {
            if(isDev) {
                iHearYouSaid("おねさま")
            } else {
                audio.say(CANNOT_HEAR_HINT, assistant) {
                    self.repeatAfterMe()
                }
            }
        }
    }

    // TTS delegate
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                           willSpeakRangeOfSpeechString characterRange: NSRange,
                           utterance: AVSpeechUtterance) {
        let speechString = utterance.speechString as NSString
        let token = speechString.substring(with: characterRange)
        print(token, terminator: "")
        targetTextView.text = targetTextView.text + token
    }
    
    func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didFinish utterance: AVSpeechUtterance
        ) {
        guard AudioController.shared.tts.completionHandler != nil else { return }
        print("")
        AudioController.shared.tts.completionHandler!()
    }
    
}
