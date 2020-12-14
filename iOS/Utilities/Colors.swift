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
    return UIColor(red: CGFloat(red / 255.0),
                   green: CGFloat(green / 255.0),
                   blue: CGFloat(blue / 255.0),
                   alpha: CGFloat(alpha))
}

let myRed = rgb(254, 67, 134)
let myOrange = rgb(255, 195, 0)
let myGreen = rgb(150, 207, 42)
let myBlue = rgb(20, 168, 237)
let myPurple = UIColor.purple
let hashtagColor = rgb(0, 53, 105)
let highlightColor = myOrange.withAlphaComponent(0.3)

let brassLight = rgb(196, 177, 71)
let brassDark = rgb(148, 97, 33)
let goldLight = rgb(255, 223, 55)
let goldMiddle = rgb(198, 139, 33)
let goldDark = rgb(179, 111, 29)
let textGold = rgb(130, 113, 60)
let minorTextColor = rgb(200, 200, 200)
let progressBackGray = rgb(80, 80, 80)

let myWhite = rgb(240, 240, 240)
let myLightGray = rgb(224, 224, 224)
let myGray = rgb(192, 192, 192)

let myWaterBlue = rgb(64, 192, 255)

let lightestGray = rgb(250, 250, 250)

let darkBackground = rgb(60, 60, 60)

// option buttons
let buttonBackgroundGray = UIColor.white.withAlphaComponent(0.25)
let buttonActionBackgroundGray = UIColor.white.withAlphaComponent(0.3)
let buttonForegroundGray = rgb(220, 220, 220)
let buttonActionGray = UIColor.white

extension UIColor {
    func withSaturation(_ newS: CGFloat) -> UIColor {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        if getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
            return UIColor(hue: h, saturation: newS, brightness: b, alpha: a)
        }

        print("withSaturation getHue fail")
        return self
    }

    func withBrightness(_ newB: CGFloat) -> UIColor {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        if getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
            return UIColor(hue: h, saturation: s, brightness: newB, alpha: a)
        }

        print("withBrightness getHue fail")
        return self
    }

    func whiteBlend(_ ratio: CGFloat) -> UIColor {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        if getRed(&r, green: &g, blue: &b, alpha: &a) {
            return UIColor(red: (1 - ratio) + r * ratio,
                           green: (1 - ratio) + g * ratio,
                           blue: (1 - ratio) + b * ratio,
                           alpha: 1.0)
        }

        print("white blend fail")
        return self
    }
}
