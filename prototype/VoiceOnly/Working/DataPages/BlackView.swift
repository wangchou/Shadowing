//
//  BlackView.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/27.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

// grid system width = 48 grids
private let stepCount: Int = 48
private let step: CGFloat = screen.width/stepCount.c
private func getFrame(x: Int, y: Int, w: Int, h: Int) -> CGRect {
    let x = (x + stepCount) % stepCount
    return CGRect(
        x: step * x.c,
        y: step * y.c,
        width: step * w.c,
        height: step * h.c
    )
}

class BlackView: UIView {
    func viewWillAppear() {
        self.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        self.removeAllSubviews()
        let backButton = UIButton()
        backButton.setTitle("X", for: .normal)
        backButton.titleLabel?.font = MyFont.systemFont(ofSize: step * 4)
        backButton.titleLabel?.textColor = myLightText
        backButton.frame = getFrame(x: -4, y: 2, w: 3, h: 3)
        self.addSubview(backButton)
    }
}
