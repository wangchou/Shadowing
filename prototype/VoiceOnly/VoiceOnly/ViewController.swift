//
//  ViewController.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/04/14.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let audioController: AudioController = AudioController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        audioController.engineStart()
        audioController.playBGM()
        audioController.repeatAfterMe()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


