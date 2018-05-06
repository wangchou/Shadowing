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

// before 315 lines
// after ?

// Prototype 7: prototype 6 + 遊戲畫面。在 getScore 後 update UI
enum ScoreDesc {
    case perfect
    case great
    case good
    case poor
}

let rihoUrl = "https://i2.kknews.cc/SIG=vanen8/66nn0002p026p2100op3.jpg"

fileprivate let context = GameContext.shared

extension P07ViewController: EventDelegate {
    @objc func onEventHappened(_ notification: Notification) {
        let event = notification.object as! Event
        let status: (GameState, EventType) = (game.state, event.type)
        
        DispatchQueue.main.async {
            switch status {
            case (.speakingJapanese, .sayStarted):
                self.focusTextView(isTargetView: true)
                
            case (.speakingJapanese, .stringSaid):
                let token = event.object as! String
                print(token, terminator: "")
                self.targetTextView.text = self.targetTextView.text + token
                
            case (.speakingJapanese, .sayEnded):
                print("")
                self.focusTextView(isTargetView: false)
                
            case (.stringRecognized, .gameStateChanged):
                self.scoreDescLabel.text = ""
                
            case (.stringRecognized, .scoreCalculated):
                self.updateUIByScore(event.object as! Int)
                
            case (.sentenceSessionEnded, .gameStateChanged):
                self.sentenceNumLabel.text = "\(context.sentenceIndex)/\(context.sentences.count)"
                if(context.sentenceIndex == context.sentences.count) {
                    self.isGameFinished = true
                    self.afterGameFinished()
                }
                
            default:
                ()//print("unhandle \(status)")
            }
        }
    }
}

class P07ViewController: UIViewController {
    
    let game = SimpleGameFlow.shared
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

        startEventObserving(self)
        game.play()
        
        isGameFinished = false
        comboLabel.text = "0"
        scoreLabel.text = "0"
        sentenceNumLabel.text = "\(context.sentenceIndex)/\(context.sentences.count)"
        bloodBar.progress = 0.6
        
        targetTextView.text = ""
        targetTextView.layer.cornerRadius = 5
        targetTextView.layer.borderColor = UIColor.black.cgColor
        targetTextView.layer.borderWidth = 2
        
        saidTextView.text = ""
        saidTextView.layer.cornerRadius = 5
        saidTextView.layer.borderColor = UIColor.lightGray.cgColor
        saidTextView.layer.borderWidth = 2
        
        scoreDescLabel.text = ""
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        game.stop()
        stopEventObserving(self)
    }
    
    // MARK: - Update UI
    func updateUIByScore(_ score: Int) {
        self.updateBlood(score)
        self.updateScoreLabel(score)
        self.updateComboLabel(score)
        self.updateScoreDescLabel(score)
    }
    
    func getScoreDesc(_ score: Int) -> ScoreDesc {
        if(score >= 100) { return .perfect }
        if(score >= 80) { return .great }
        if(score >= 60) { return .good}
        return .poor
    }
    
    func focusTextView(isTargetView: Bool) {
        if isTargetView {
            self.targetTextView.text = ""
            self.saidTextView.text = ""
            self.scoreDescLabel.text = ""
            self.targetTextView.layer.borderColor = UIColor.black.cgColor
            self.saidTextView.layer.borderColor = UIColor.lightGray.cgColor
        } else {
            self.saidTextView.text = ""
            self.saidTextView.layer.borderColor = UIColor.black.cgColor
            self.targetTextView.layer.borderColor = UIColor.lightGray.cgColor
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
    
    func afterGameFinished() {
        let isGameClear = bloodBar.progress > 0
        
        if isGameClear {
            targetTextView.layer.borderColor = UIColor.black.cgColor
            saidTextView.layer.borderColor = UIColor.lightGray.cgColor
            saidTextView.text = ""
            targetTextView.text = ""
            scoreDescLabel.text = ""
            // downloadImage(url: URL(string: rihoUrl)!)
            cmdQueue.async {
                // meijia("恭喜你全破了。有人想和你說...")
                // oren("きみのこと、大好きだよ", rate: teachingRate * 0.7, delegate: self)
                stopEngine()
            }
        } else {
            cmdQueue.async {
                meijia("生命值為零，遊戲結束")
            }
            scoreDescLabel.text = "遊戲結束"
            scoreDescLabel.textColor = UIColor.red
            stopEngine()
        }
    }
    
    func updateBlood(_ score: Int) {
        let scoreDesc = getScoreDesc(score)
        switch scoreDesc {
        case .perfect:
            bloodBar.progress = min(1.0, bloodBar.progress + 0.15)
        case .great:
            bloodBar.progress = min(1.0, bloodBar.progress + 0.10)
        case .good:
            bloodBar.progress = min(1.0, bloodBar.progress + 0.05)
        case .poor:
            bloodBar.progress = max(0, bloodBar.progress - 0.20)
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
        scoreDescLabel.text = getScoreText(score)
        let scoreDesc = getScoreDesc(score)
        switch scoreDesc {
        case .perfect:
            scoreDescLabel.textColor = UIColor.orange
        case .great:
            scoreDescLabel.textColor = UIColor.green
        case .good:
            scoreDescLabel.textColor = UIColor.blue
        case .poor:
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
