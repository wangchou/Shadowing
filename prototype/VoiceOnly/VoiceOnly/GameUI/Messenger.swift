//
//  P8ViewController.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/05.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

fileprivate let context = GameContext.shared

// Prototype 8: messenger / line interface
class Messenger: UIViewController {
    let game = SimpleGame.shared
    
    var lastLabel: UITextView = UITextView()
    
    private var y: Int = 8
    private var previousY: Int = 0
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    func addLabel(_ text: String, isLeft: Bool = true) {
        let myLabel = UITextView()
        myLabel.isEditable = false
        updateLabel(myLabel, text: text, isLeft: isLeft)
        scrollView.addSubview(myLabel)
        lastLabel = myLabel
    }
    
    func updateLabel(_ myLabel: UITextView, text: String, isLeft: Bool = true) {
        let maxLabelWidth: Int = Int(screenSize.width*2/3)
        let spacing: Int = 8
        
        myLabel.text = text
        myLabel.textContainerInset = UIEdgeInsetsMake(4, 4, 4, 4)
        myLabel.layer.borderWidth = 1.5;
        myLabel.font = UIFont.systemFont(ofSize: 20)
        myLabel.frame = CGRect(x: 5, y: y, width: maxLabelWidth, height: 30)
        myLabel.sizeToFit()
        myLabel.clipsToBounds = true
        myLabel.layer.cornerRadius = 15.0
        
        if isLeft {
            myLabel.backgroundColor = .white
        } else {
            myLabel.frame.origin.x = CGFloat(Int(screenSize.width) - spacing - Int(myLabel.frame.width))
            if text == "..." {
                myLabel.backgroundColor = .gray
            } else if text == "聽不清楚" {
                myLabel.backgroundColor = myRed
            } else{
                myLabel.backgroundColor = myGreen
            }
        }
        
        previousY = y
        y = y + Int(myLabel.frame.height) + spacing
        
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
        startEventObserving(self)
        game.play()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopEventObserving(self)
        game.stop()
    }
}
