//
//  P8ViewController.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/05.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

// Prototype 8: messenger / line interface
class P08ViewController: UIViewController, GameEventDelegate {
    let game = VoiceOnlyGame.shared
    let spacing: Int = 8
    var y: Int = 8
    var previousY: Int = 0
    var lastLabel: UITextView = UITextView()
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    func addLabel(_ text: String, isLeft: Bool = true) {
        let myLabel = UITextView(frame: CGRect(x: 5, y: y, width: 210, height: 30))
        updateLabel(myLabel, text: text, isLeft: isLeft)
        scrollView.addSubview(myLabel)
        lastLabel = myLabel
    }
    
    func updateLabel(_ myLabel: UITextView, text: String, isLeft: Bool = true) {
        myLabel.text = text
        myLabel.textContainerInset = UIEdgeInsetsMake(4, 4, 4, 4)
        myLabel.layer.borderWidth = 1.5;
        myLabel.font = UIFont(name: "Helvetica-Light", size: 20)
        myLabel.backgroundColor = .white
        myLabel.sizeToFit()
        myLabel.clipsToBounds = true
        myLabel.layer.cornerRadius = 10.0
        
        previousY = y
        y = y + Int(myLabel.frame.height) + spacing
        
        if(!isLeft) {
            myLabel.frame.origin.x = CGFloat(320 - spacing - Int(myLabel.frame.width))
        }
        
        scrollView.contentSize = CGSize(
            width: scrollView.frame.size.width,
            height: max(scrollView.frame.size.height, CGFloat(y))
        )
        scrollView.scrollRectToVisible(CGRect(x: 5, y: y-1, width: 1, height: 1), animated: true)
    }
    
    func updateLastLabelText(_ text: String, isLeft: Bool = true) {
        y = previousY
        updateLabel(lastLabel, text: text, isLeft: isLeft)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addLabel("ただの人間には")
        updateLastLabelText("qoo", isLeft: false)
        DispatchQueue.global().async {
            for _ in 1...10 {
                sleep(1)
                DispatchQueue.main.async {
                    self.addLabel("ただの人間には")
                    self.addLabel("今日はいい天気ですね", isLeft: false)
                }
            }
        }
        addLabel("今日はいい天気ですね今日はすね今日はいい天気ですね")
        

        
//        startEventObserving(self)
//        game.play()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        stopEventObserving(self)
//        game.stop()
    }
    
    @objc func onEventHappened(_ notification: Notification) {
        let event = notification.object as! Event
        print(game.state, event.type)
    }
    
}
