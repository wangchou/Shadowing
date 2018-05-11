//
//  LifeBar.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/11.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

class LifeBar: UIView {
    var life: CGFloat = 40
    var lifeColor = UIColor.red
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        let bottomRect = CGRect(
            origin: CGPoint(x: rect.origin.x, y: rect.origin.y),
            size: CGSize(width: rect.size.width * life/100, height: rect.size.height)
        )
        
        if life > 80 {
            lifeColor = myGreen
        } else if life > 25 {
            lifeColor = myOrange
        } else {
            lifeColor = UIColor.red
        }
        
        lifeColor.setFill()
        UIRectFill(bottomRect)
    }
}
