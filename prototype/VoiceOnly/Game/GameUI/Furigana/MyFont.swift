//
//  MyFont.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/22.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

class MyFont {
    static func thinSystemFont(ofSize fontSize: CGFloat) -> UIFont {
        var fontThin = UIFont.systemFont(ofSize: fontSize, weight: UIFont.Weight.thin)
        if let fontW2 = UIFont(name: ".HiraKakuInterface-W2", size: fontSize) {
            fontThin = fontW2
        }
        return fontThin
    }

    static func systemFont(ofSize fontSize: CGFloat) -> UIFont {
        var fontRegular = UIFont.systemFont(ofSize: fontSize, weight: UIFont.Weight.regular)
        if let fontW3 = UIFont(name: ".HiraKakuInterface-W3", size: fontSize) {
            fontRegular = fontW3
        }
        return fontRegular
    }

    static func boldSystemFont(ofSize fontSize: CGFloat) -> UIFont {
        var fontBold = UIFont.systemFont(ofSize: fontSize, weight: UIFont.Weight.bold)
        if let fontW6 = UIFont(name: ".HiraKakuInterface-W6", size: fontSize) {
            fontBold = fontW6
        }
        return fontBold
    }
}
