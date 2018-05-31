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
    static func thin(ofSize fontSize: CGFloat) -> UIFont {
        var fontThin = UIFont.systemFont(ofSize: fontSize, weight: UIFont.Weight.thin)
        if let fontW2 = UIFont(name: ".HiraKakuInterface-W2", size: fontSize) {
            fontThin = fontW2
        }
        return fontThin
    }

    static func regular(ofSize fontSize: CGFloat) -> UIFont {
        var fontRegular = UIFont.systemFont(ofSize: fontSize, weight: UIFont.Weight.regular)
        if let fontW3 = UIFont(name: ".HiraKakuInterface-W3", size: fontSize) {
            fontRegular = fontW3
        }
        return fontRegular
    }

    static func bold(ofSize fontSize: CGFloat) -> UIFont {
        var fontBold = UIFont.systemFont(ofSize: fontSize, weight: UIFont.Weight.bold)
        if let fontW6 = UIFont(name: ".HiraKakuInterface-W6", size: fontSize) {
            fontBold = fontW6
        }
        return fontBold
    }
}

extension NSMutableAttributedString {
    var allRange: NSRange {
        return NSRange(location: 0, length: self.length)
    }
}

func getText(
    _ text: String,
    color: UIColor? = nil,
    strokeWidth: Float? = nil,
    strokeColor: UIColor? = nil,
    font: UIFont? = nil,
    terminator: String = ""
    ) -> NSMutableAttributedString {
    let text = NSMutableAttributedString(string: "\(text)\(terminator)")
    var attributes: [NSAttributedStringKey: Any] = [:]
    if let color = color { attributes[.foregroundColor] = color }
    if let strokeWidth = strokeWidth { attributes[.strokeWidth] = strokeWidth }
    if let strokeColor = strokeColor { attributes[.strokeColor] = strokeColor }
    if let font = font { attributes[.font] = font }
    text.addAttributes(
        attributes,
        range: text.allRange
    )
    return text
}

func getStrokeText(
    _ text: String,
    _ color: UIColor,
    strokeWidth: Float = -1.5,
    strokColor: UIColor = .black,
    font: UIFont = UIFont.boldSystemFont(ofSize: 32)) -> NSMutableAttributedString {
    return getText(text, color: color, strokeWidth: strokeWidth, strokeColor: strokColor, font: font)
}

func colorText(
    _ text: String,
    _ color: UIColor = .lightText,
    terminator: String = ""
    ) -> NSMutableAttributedString {
    return getText(text, color: color, font: MyFont.regular(ofSize: 24))
}
