//
//  P1ViewController.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/04/24.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import Speech


fileprivate let listenPauseDuration = 0.4
fileprivate let isDev = false
fileprivate let cmd = Commands.shared
fileprivate var targetSentence = sentences[sentenceIndex]
fileprivate var translation = translations[sentenceIndex]

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

let rihoUrl = "https://i2.kknews.cc/SIG=vanen8/66nn0002p026p2100op3.jpg"

class P7ViewController: UIViewController, AVSpeechSynthesizerDelegate {
    var isGameFinished = false
    
    @IBOutlet weak var comboLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var sentenceNumLabel: UILabel!
    @IBOutlet weak var bloodBar: UIProgressView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var targetTextView: UITextView!
    @IBOutlet weak var saidTextView: UITextView!
    @IBOutlet weak var scoreDescLabel: UILabel!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        isGameFinished = false
        comboLabel.text = "0"
        scoreLabel.text = "0"
        sentenceNumLabel.text = String(sentenceIndex) + "/" + String(sentences.count)
        bloodBar.progress = 0.6
        
        targetTextView.text = ""
        targetTextView.layer.cornerRadius = 5
        targetTextView.layer.borderColor = UIColor.black.cgColor
        targetTextView.layer.borderWidth = 2
        
        saidTextView.text = ""
        saidTextView.layer.cornerRadius = 5
        saidTextView.layer.borderColor = UIColor.yellow.cgColor
        saidTextView.layer.borderWidth = 2
        
        scoreDescLabel.text = ""
        
        sentenceIndex = 0
        targetSentence = sentences[sentenceIndex]
        translation = translations[sentenceIndex]
        
        cmd.startEngine(toSpeaker: true)
        repeatAfterMe()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cmd.stopEngine()
    }
    
    // MARK: - Audio cmd Control
    func teacher(_ sentence: String) {
        focusTextView(isTargetView: true)
        DispatchQueue.main.async {
            self.targetTextView.text = "\(translation) | "
        }
        hattori(sentence, delegate: self)
        focusTextView(isTargetView: false)
    }
    
    func repeatAfterMe() {
        // async/await
        cmdQueue.async {
            print("----------------------------------")
            let speakTime = getNow()
            self.teacher(targetSentence)
            DispatchQueue.main.async {
                self.scoreDescLabel.text = "👂請說"
                self.scoreDescLabel.textColor = UIColor.black
            }
            cmd.listen(
                listenDuration: (getNow() - speakTime) + listenPauseDuration,
                resultHandler: self.speechResultHandler
            )
        }
    }
    
    func iHearYouSaid(_ saidSentence: String) {
        cmdQueue.async {
            print("hear <<< \(saidSentence)")
            // meijia(I_HEAR_YOU_HINT)
            // oren(saidSentence)
            let score = getSpeechScore(targetSentence, saidSentence)
            self.updateUIByScore(score)
            oren(self.getScoreText(score))
            cmdGroup.wait()
            DispatchQueue.main.async {
                self.nextSentence()
                if(self.isGameFinished) {
                    return
                }
                self.repeatAfterMe()
            }
            
            
        }
    }
    
    // MARK: - Speech Recogntion Part
    func onRecognitionResult(_ result: SFSpeechRecognitionResult?) {
        guard let result = result else { return }
        saidTextView.text = result.bestTranscription.formattedString
        if result.isFinal {
            DispatchQueue.main.async {
                self.scoreDescLabel.text = ""
            }
            iHearYouSaid(saidTextView.text)
        }
    }
    
    func onRecognitionError(_ error: Error?) {
        if error == nil { return }
        if(isDev) {
            iHearYouSaid("おねさま")
        } else {
            cmdQueue.async {
                meijia(CANNOT_HEAR_HINT)
                self.repeatAfterMe()
            }
        }
    }
    
    func speechResultHandler(result: SFSpeechRecognitionResult?, error: Error?) {
        if cmd.isEngineRunning {
            onRecognitionResult(result)
            onRecognitionError(error)
        }
    }
    
    // MARK: - TTS Delegate
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
        guard cmd.tts.completionHandler != nil else { return }
        print("")
        cmd.tts.completionHandler!()
    }
    
    
    // MARK: - Update UI
    func updateUIByScore(_ score: Int) {
        DispatchQueue.main.async {
            self.updateBlood(score)
            self.updateScoreLabel(score)
            self.updateComboLabel(score)
            self.updateScoreDescLabel(score)
        }
    }
    func getScoreDesc(_ score: Int) -> ScoreDesc {
        if(score >= 100) { return .perfect }
        if(score >= 80) { return .great }
        if(score >= 60) { return .good}
        return .poor
    }
    
    func focusTextView(isTargetView: Bool) {
        DispatchQueue.main.async {
            if isTargetView {
                self.targetTextView.text = ""
                self.saidTextView.text = ""
                self.scoreDescLabel.text = ""
                self.targetTextView.layer.borderColor = UIColor.black.cgColor
                self.saidTextView.layer.borderColor = UIColor.yellow.cgColor
            } else {
                self.saidTextView.text = ""
                self.saidTextView.layer.borderColor = UIColor.black.cgColor
                self.targetTextView.layer.borderColor = UIColor.yellow.cgColor
            }
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
    
    func nextSentence() {
        sentenceIndex = sentenceIndex + 1
        sentenceNumLabel.text = String(sentenceIndex) + "/" + String(sentences.count)
        if(sentenceIndex == sentences.count) {
            isGameFinished = true
            afterGameFinished()
            return
        }
        translation = translations[sentenceIndex]
        targetSentence = sentences[sentenceIndex]
    }
    
    func afterGameFinished() {
        let isGameClear = bloodBar.progress > 0
        
        if isGameClear {
            targetTextView.layer.borderColor = UIColor.black.cgColor
            saidTextView.layer.borderColor = UIColor.yellow.cgColor
            saidTextView.text = ""
            targetTextView.text = ""
            scoreDescLabel.text = ""
            downloadImage(url: URL(string: rihoUrl)!)
            cmdQueue.async {
                meijia("恭喜你全破了。有人想和你說...")
                oren("きみのこと、大好きだよ", rate: teachingRate * 0.7, delegate: self)
                cmd.stopEngine()
            }
        } else {
            cmdQueue.async {
                meijia("生命值為零，遊戲結束")
            }
            scoreDescLabel.text = "遊戲結束"
            scoreDescLabel.textColor = UIColor.red
            cmd.stopEngine()
        }
    }
    
    func updateBlood(_ score: Int) {
        let scoreDesc = getScoreDesc(score)
        switch scoreDesc {
        case .perfect:
            bloodBar.progress = min(1.0, bloodBar.progress + 0.15)
        case .great:
            bloodBar.progress = min(1.0, bloodBar.progress + 0.08)
        case .good:
            bloodBar.progress = min(1.0, bloodBar.progress + 0.02)
        case .poor:
            bloodBar.progress = max(0, bloodBar.progress - 0.15)
            if bloodBar.progress == 0 {
                isGameFinished = true
                afterGameFinished()
            }
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
            return "違うよ"
        }
    }
    
    func updateScoreDescLabel(_ score: Int) {
        saidTextView.text = saidTextView.text + "(" + String(score) + "分)"
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
            scoreDescLabel.text = "違うよ"
            scoreDescLabel.textColor = UIColor.red
        }
    }
    
    // MARK: - Utilities
    // https://stackovercmd.com/questions/24231680/loading-downloading-image-from-url-on-swift
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    func downloadImage(url: URL) {
        print("Download Started")
        getDataFromUrl(url: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                self.imageView.image = UIImage(data: data)
            }
        }
    }
}
