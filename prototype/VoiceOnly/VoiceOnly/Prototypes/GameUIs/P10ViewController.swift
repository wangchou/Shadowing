//
//  P10ViewController.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/05.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

func rgb(_ red: Float, _ green: Float, _ blue: Float) -> UIColor {
    return UIColor(red: CGFloat(red/255.0), green: CGFloat(green/255.0), blue: CGFloat(blue/255.0), alpha: 1)
}

let myBlue = rgb(20, 168, 237)
let myRed = rgb(254, 67, 134)
let myGreen = rgb(150, 207, 42)

// Prototype 10: black console
class P10ViewController: UIViewController, EventDelegate {
    let game = SimpleGameFlow.shared
    var score: Int = 0
    var tmpText: NSMutableAttributedString = colorText("")
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = ""
        startEventObserving(self)
        game.play()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopEventObserving(self)
        game.stop()
    }
    
    @objc func onEventHappened(_ notification: Notification) {
        let event = notification.object as! Event
        
        switch event.type {
        case .sayStarted:
            switch event.object as! String {
            case Hattori:
                cprint("---")
            default:
                return
            }
            
        case .stringSaid:
            var color: UIColor = .lightText
            color = game.state == .speakingJapanese ? myBlue : color
            if (game.state == .scoreCalculated) {
                color = score >= 60 ? myGreen : myRed
            }
            cprint(event.object as! String, color, terminator: "")
        
        case .sayEnded:
            cprint("")
        
        case .listenStarted:
            tmpText = textView.attributedText.mutableCopy() as! NSMutableAttributedString
        
        case .stringRecognized, .listenEnded:
            let curText = tmpText.mutableCopy() as! NSMutableAttributedString
            curText.append(colorText(event.object as! String, terminator: " "))
            textView.attributedText = curText
        
        case .scoreCalculated:
            score = event.object as! Int
            
        default:
            return
        }
    }
    
    func scrollTextIntoView() {
        let range = NSMakeRange(textView.text.count - 1, 0)
        textView.scrollRangeToVisible(range)
    }
    
    func cprint(_ text: String, _ color: UIColor = .lightText, terminator: String = "\n") {
        let newText = self.textView.attributedText.mutableCopy() as! NSMutableAttributedString
        newText.append(colorText(text, color, terminator: terminator))
        self.textView.attributedText = newText
        self.scrollTextIntoView()
    }
}

func colorText(_ text: String, _ color: UIColor = .lightText, terminator: String = "") -> NSMutableAttributedString {
    let colorText = NSMutableAttributedString(string: "\(text)\(terminator)")
    colorText.addAttributes([
            .foregroundColor: color,
            .font: UIFont.systemFont(ofSize: 24)
        ],
        range: NSMakeRange(0, colorText.length)
    )
    return colorText
}
