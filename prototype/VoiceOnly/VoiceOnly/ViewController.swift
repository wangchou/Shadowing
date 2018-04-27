//
//  ViewController.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/04/14.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var audio = AudioController.shared
    var flow = FlowController.shared
    override func viewDidLoad() {
        super.viewDidLoad()
        if(isDev) {
            audio.start()
            self.flow.repeatAfterMe()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


