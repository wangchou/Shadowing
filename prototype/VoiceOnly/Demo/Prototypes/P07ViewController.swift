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

// Prototype 7: prototype 6 + 遊戲畫面。在 getScore 後 update UI
let rihoUrl = "https://i2.kknews.cc/SIG=vanen8/66nn0002p026p2100op3.jpg"

private let context = GameContext.shared

extension P07ViewController: GameEventDelegate {
    @objc func onEventHappened(_ notification: Notification) {
        guard let event = notification.object as? Event else { return }
        let status: (GameState, EventType) = (game.state, event.type)

        switch status {
        case (.speakingJapanese, .sayStarted):
            self.focusTextView(isTargetView: true)

        case (.speakingJapanese, .stringSaid):
            guard let token = event.string else { return }
            print(token, terminator: "")
            self.targetTextView.text = "\(String(describing: targetTextView.text))\(token)"

        case (.speakingJapanese, .sayEnded):
            print("")
            self.focusTextView(isTargetView: false)

        case (.listening, .stringRecognized):
            if let str = event.string {
                self.saidTextView.text = str
            }

        case (.stringRecognized, .gameStateChanged):
            self.scoreDescLabel.text = ""

        case (.stringRecognized, .scoreCalculated):
            if let score = event.score {
                self.updateUIByScore(score)
                sumScore += score.value
            }

        case (.sentenceSessionEnded, .gameStateChanged):
            self.sentenceNumLabel.text = "\(context.sentenceIndex)/\(context.sentences.count)"
            if context.sentenceIndex == context.sentences.count {
                self.isGameFinished = true
                self.afterGameFinished()
            }

        default:
            ()//print("unhandle \(status)")
        }

    }
}

class P07ViewController: UIViewController {

    let game = SimpleGame.shared
    var isGameFinished = false

    var sumScore = 0
    var comboCount = 0

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
        sumScore = 0
        comboCount = 0
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        game.stop()
        //stopEventObserving(self)
    }

    // MARK: - Update UI
    func updateUIByScore(_ score: Score) {
        self.updateBlood(score)
        self.updateScoreLabel(score)
        self.updateComboLabel(score)
        self.updateScoreDescLabel(score)
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

    func updateScoreLabel(_ score: Score) {
        scoreLabel.text = String(sumScore)
    }

    func updateComboLabel(_ score: Score) {
        switch score.type {
        case .perfect, .great:
            comboCount += 1
        case .good, .poor:
            comboCount = 0
        }
        comboLabel.text = String(comboCount)
    }

    func afterGameFinished() {
        let isGameClear = bloodBar.progress > 0

        if isGameClear {
            targetTextView.layer.borderColor = UIColor.black.cgColor
            saidTextView.layer.borderColor = UIColor.lightGray.cgColor
            saidTextView.text = ""
            targetTextView.text = ""
            scoreDescLabel.text = ""
            //downloadImage(url: URL(string: rihoUrl)!)
            meijia("恭喜你全破了。有人想和你說...").then {
                oren("きみのこと、大好きだよ")
            }.always {
                stopEngine()
            }
        } else {
            meijia("生命值為零，遊戲結束").always {
                self.scoreDescLabel.text = "遊戲結束"
                self.scoreDescLabel.textColor = UIColor.red
                stopEngine()
            }
        }
    }

    func updateBlood(_ score: Score) {
        switch score.type {
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

    func updateScoreDescLabel(_ score: Score) {
        saidTextView.text = "\(String(describing: saidTextView.text))(\(score)分)"
        scoreDescLabel.text = score.text
        scoreDescLabel.textColor = score.color
    }

    // MARK: - Utilities
    // https://stackovercmd.com/questions/24231680/loading-downloading-image-from-url-on-swift
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
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
            DispatchQueue.main.async {
                self.imageView.image = UIImage(data: data)
            }
        }
    }
}
