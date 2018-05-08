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
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    func addLabel(_ text: String, isLeft: Bool = true) {
        let myLabel = UITextView(frame: CGRect(x: 5, y: y, width: 210, height: 30))
        myLabel.text = text
        myLabel.textContainerInset = UIEdgeInsetsMake(4, 4, 4, 4)
        myLabel.layer.borderWidth = 1.5;
        myLabel.font = UIFont(name: "Helvetica-Light", size: 20)
        myLabel.backgroundColor = .white
        myLabel.sizeToFit()
        myLabel.clipsToBounds = true
        myLabel.layer.cornerRadius = 10.0
        y = y + Int(myLabel.frame.height) + spacing
        
        if(!isLeft) {
            myLabel.frame.origin.x = 115
        }
        
        scrollView.contentSize = CGSize(
            width: scrollView.frame.size.width,
            height: max(scrollView.frame.size.height, CGFloat(y))
        )
        
        scrollView.addSubview(myLabel)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addLabel("ただの人間には")
        for _ in 1...10 {
            addLabel("ただの人間には")
        }
        addLabel("今日はいい天気ですね今日はすね今日はいい天気ですね", isLeft: false)
        addLabel("今日はいい天気ですね")

        
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
