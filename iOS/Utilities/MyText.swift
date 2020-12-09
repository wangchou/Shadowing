//
//  MyFont.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/22.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

// Hiragino Maru Gothic ProN
//    -- HiraMaruProN-W4
// Hiragino Mincho ProN
//    -- HiraMinProN-W3
//    -- HiraMinProN-W6
// Hiragino Sans
//    -- HiraginoSans-W3
//    -- HiraginoSans-W6
class MyFont {
    static var fontCache: [String: UIFont] = [:]

    static func rubyThin(ofSize fontSize: CGFloat) -> UIFont {
        let key = "thin-\(fontSize)"
        if let font = fontCache[key] { return font }
        if #available(iOS 13.0, *) {
            fontCache[key] =
                UIFont(name: "HiraginoSans-W0", size: fontSize)
        } else {
            fontCache[key] = UIFont(name: ".HiraKakuInterface-W2", size: fontSize) ??
                UIFont.systemFont(ofSize: fontSize, weight: .thin)
        }
        return fontCache[key]!
    }

    static func thin(ofSize fontSize: CGFloat) -> UIFont {
        let key = "thin-\(fontSize)"
        if let font = fontCache[key] { return font }
        if #available(iOS 13.0, *) {
            fontCache[key] =
                UIFont(name: "HiraginoSans-W2", size: fontSize)
        } else {
            fontCache[key] = UIFont(name: ".HiraKakuInterface-W2", size: fontSize) ??
                UIFont.systemFont(ofSize: fontSize, weight: .thin)
        }
        return fontCache[key]!
    }

    static func regular(ofSize fontSize: CGFloat) -> UIFont {
        let key = "regular-\(fontSize)"
        if let font = fontCache[key] { return font }
        if #available(iOS 13.0, *) {
            fontCache[key] = UIFont(name: "HiraginoSans-W3", size: fontSize)
        } else {
            fontCache[key] = UIFont(name: ".HiraKakuInterface-W3", size: fontSize) ??
                UIFont.systemFont(ofSize: fontSize, weight: .regular)
        }
        return fontCache[key]!
    }

    static func bold(ofSize fontSize: CGFloat) -> UIFont {
        let key = "bold-\(fontSize)"
        if let font = fontCache[key] { return font }
        if #available(iOS 13.0, *) {
            fontCache[key] =
                UIFont(name: "HiraginoSans-W6", size: fontSize)
        } else {
            fontCache[key] = UIFont(name: ".HiraKakuInterface-W6", size: fontSize) ??
                UIFont.systemFont(ofSize: fontSize, weight: .bold)
        }
        return fontCache[key]!
    }

    // for rank, progress text
    static func heavyDigit(ofSize fontSize: CGFloat) -> UIFont {
        let key = "heavy-\(fontSize)"
        if let font = fontCache[key] { return font }
        fontCache[key] = UIFont(name: "SFProDisplay-Heavy", size: fontSize)
            ?? UIFont.systemFont(ofSize: fontSize, weight: .heavy)
        return fontCache[key]!
    }

    static func printAllFonts() {
        for family in UIFont.familyNames {

            let sName: String = family as String
            print("family: \(sName)")

            for name in UIFont.fontNames(forFamilyName: sName) {
                print("name: \(name as String)")
            }
        }
    }
}

extension NSMutableAttributedString {
    var allRange: NSRange {
        return NSRange(location: 0, length: length)
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
            strokeWidth: -1,
            strokeColor: .black,
            font: MyFont.heavyDigit(ofSize: part.fontSize)
        ))
    }
    return attrText
}

func getStrokeText(
    _ text: String,
    _ color: UIColor,
    strokeWidth: Float = -1.5,
    strokColor: UIColor = .black,
    font: UIFont = MyFont.heavyDigit(ofSize: 32)
) -> NSMutableAttributedString {
    let limitedWidth = max(-4, strokeWidth)
    return getText(text, color: color, strokeWidth: limitedWidth, strokeColor: strokColor, font: font)
}

func colorText(
    _ text: String,
    _ color: UIColor = .lightText,
    terminator: String = "",
    fontSize: CGFloat = 24
) -> NSMutableAttributedString {
    return getText(text, color: color, font: MyFont.regular(ofSize: fontSize), terminator: terminator)
}
