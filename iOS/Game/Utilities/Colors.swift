//
//  colors.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/27.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

func rgb(_ red: Float, _ green: Float, _ blue: Float, _ alpha: Float = 1.0) -> UIColor {
    return UIColor(red: CGFloat(red/255.0), green: CGFloat(green/255.0), blue: CGFloat(blue/255.0), alpha: CGFloat(alpha))
}

let myBlue = rgb(20, 168, 237)
let myGreen = rgb(150, 207, 42)
let myOrange = rgb(255, 195, 0)
let myRed = rgb(254, 67, 134)
let hashtagColor = rgb(0, 53, 105)

let myWhite = rgb(240, 240, 240)
let myLightText = rgb(224, 224, 224)
let myGray = rgb(192, 192, 192)

let myWaterBlue = rgb(64, 192, 255)

func getLevelColor(level: Level) -> UIColor {
    switch level {
    case .lv0, .lv1:
        return myRed
    case .lv2, .lv3:
        return myOrange
    case .lv4, .lv5:
        return myGreen
    case .lv6, .lv7:
        return myBlue
    case .lv8:
        return .purple
    }
}

func getRankColor(rank: Rank?) -> UIColor {
    guard let rank = rank else { return myLightText }
    var color: UIColor
    switch rank {
    case .s, .ss:
        color = myBlue
    case .a:
        color = myGreen
    case .b, .c, .d:
        color = myOrange
    case .e, .f:
        color = myRed
    }
    return color
}
