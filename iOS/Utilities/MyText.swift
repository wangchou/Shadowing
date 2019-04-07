//
//  MyFont.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/22.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

//Hiragino Maru Gothic ProN
//    -- HiraMaruProN-W4
//Hiragino Mincho ProN
//    -- HiraMinProN-W3
//    -- HiraMinProN-W6
//Hiragino Sans
//    -- HiraginoSans-W3
//    -- HiraginoSans-W6
class MyFont {
    static var fontCache: [String: UIFont] = [:]
    static func thin(ofSize fontSize: CGFloat) -> UIFont {
        let key = "thin-\(fontSize)"
        if let font = fontCache[key] { return font }
        fontCache[key] = UIFont(name: ".HiraKakuInterface-W2", size: fontSize) ??
                         UIFont.systemFont(ofSize: fontSize, weight: .thin)
        return fontCache[key]!
    }

    static func regular(ofSize fontSize: CGFloat) -> UIFont {
        let key = "regular-\(fontSize)"
        if let font = fontCache[key] { return font }
        fontCache[key] = UIFont(name: ".HiraKakuInterface-W3", size: fontSize) ??
                         UIFont.systemFont(ofSize: fontSize, weight: .regular)
        return fontCache[key]!
    }

    static func bold(ofSize fontSize: CGFloat) -> UIFont {
        let key = "bold-\(fontSize)"
        if let font = fontCache[key] { return font }
        fontCache[key] = UIFont(name: ".HiraKakuInterface-W6", size: fontSize) ??
                         UIFont.systemFont(ofSize: fontSize, weight: .bold)
        return fontCache[key]!
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
    var attributes: [NSAttributedString.Key: Any] = [:]
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

func getAttrText(_ parts: [(text: String,
                            color: UIColor,
                            fontSize: CGFloat)]) -> NSAttributedString {
    let attrText = NSMutableAttributedString()
    parts.forEach { part in
        attrText.append(getText(
            part.text,
            color: part.color,
            font: MyFont.bold(ofSize: part.fontSize)
        ))
    }
    return attrText
}

func getStrokeText(
    _ text: String,
    _ color: UIColor,
    strokeWidth: Float = -1.5,
    strokColor: UIColor = .black,
    font: UIFont = UIFont.boldSystemFont(ofSize: 32)
    ) -> NSMutableAttributedString {
    return getText(text, color: color, strokeWidth: strokeWidth, strokeColor: strokColor, font: font)
}

func colorText(
    _ text: String,
    _ color: UIColor = .lightText,
    terminator: String = "",
    fontSize: CGFloat = 24
    ) -> NSMutableAttributedString {
    return getText(text, color: color, font: MyFont.regular(ofSize: fontSize), terminator: terminator)
}
