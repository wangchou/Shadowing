//
//  InfoPage.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 10/20/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import UIKit

class InfoPage: UIViewController {
    static let id = "InfoPage"
    static var content: String?
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        closeButton.roundBorder(radius: 25)
        if let content = InfoPage.content {
            textView.text = content
        }
        textView.dataDetectorTypes = []
    }

    @IBAction func onCloseButtonClicked(_: Any) {
        InfoPage.content = nil
        dismiss(animated: true)
    }
}
