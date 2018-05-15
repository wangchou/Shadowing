// modified from
// https://stackoverflow.com/questions/46690337/swift-4-ctrubyannotation-dont-work

import Foundation
import UIKit
import Promises

extension String {
    func find(_ pattern: String) -> NSTextCheckingResult? {
        do {
            let re = try NSRegularExpression(pattern: pattern, options: [])
            return re.firstMatch(
                in: self,
                options: [],
                range: NSMakeRange(0, self.utf16.count))
        } catch {
            return nil
        }
    }
    
    func replace(_ pattern: String, _ template: String) -> String {
        do {
            let re = try NSRegularExpression(pattern: pattern, options: [])
            return re.stringByReplacingMatches(
                in: self,
                options: [],
                range: NSMakeRange(0, self.utf16.count),
                withTemplate: template)
        } catch {
            return self
        }
    }
    
    var furiganaAttributedString: Promise<NSMutableAttributedString> {
        let promise = Promise<NSMutableAttributedString>.pending()
        let attributeStr = NSMutableAttributedString()
        getKanaTokenInfos(self).then { tokenInfos in
            for tokenInfo in tokenInfos {
                let token = tokenInfo[0] // ex: 懸かっ
                let tokenKana = tokenInfo[8].kataganaToHiragana // ex: かかっ
                var suffixPart = token // ex: かっ
                
                if let kanjiRange = token.range(of: "\\p{Han}*\\p{Han}", options: .regularExpression) {
                    let kanji = String(token[kanjiRange]) // ex: 懸
                    var kana = tokenKana
                    
                    if kanji.count < token.count {
                        suffixPart.removeSubrange(kanjiRange)
                        kana.removeLast(suffixPart.count)
                    }
                    
                    let annotation = CTRubyAnnotationCreateWithAttributes(
                        .auto, .auto, .before, kana as CFString, [:] as CFDictionary)
                    
                    attributeStr.append(NSAttributedString(
                        string: kanji,
                        attributes: [kCTRubyAnnotationAttributeName as NSAttributedStringKey: annotation]))
                    
                    if kanji.count < token.count {
                        attributeStr.append(NSAttributedString(string: suffixPart, attributes: nil))
                    }
                } else {
                    attributeStr.append(NSAttributedString(string: token, attributes: nil))
                }
            }
           
            promise.fulfill(attributeStr)
        }
        return promise
    }
    
    // Hiragana: 3040-309F
    // Katakana: 30A0-30FF
    var kataganaToHiragana: String {
        var hiragana = ""
        for ch in self {
            let scalars = ch.unicodeScalars
            hiragana.append(Character(UnicodeScalar(scalars[scalars.startIndex].value - 0x60)!))
        }
        return hiragana
    }
}

class CustomLabel: UILabel {
    //override func draw(_ rect: CGRect) { // if not has drawText, use draw UIView etc
    override func drawText(in rect: CGRect) {
        let attributed = NSMutableAttributedString(attributedString: self.attributedText!)
        let isVertical = false // if Vertical Glyph, true.
        attributed.addAttributes([NSAttributedStringKey.verticalGlyphForm: isVertical], range: NSMakeRange(0, attributed.length))
        drawContext(attributed, textDrawRect: rect, isVertical: isVertical)
    }
    
    func drawContext(_ attributed:NSMutableAttributedString, textDrawRect:CGRect, isVertical:Bool) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        var path:CGPath
        if isVertical {
            context.rotate(by: .pi / 2)
            context.scaleBy(x: 1.0, y: -1.0)
            path = CGPath(rect: textDrawRect, transform: nil)
        }
        else {
            context.textMatrix = CGAffineTransform.identity
            context.translateBy(x: 0, y: textDrawRect.height)
            context.scaleBy(x: 1.0, y: -1.0)
            path = CGPath(rect: textDrawRect, transform: nil)
        }
        
        let framesetter = CTFramesetterCreateWithAttributedString(attributed)
        let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attributed.length), path, nil)
        
        CTFrameDraw(frame, context)
    }
}

class PlaygroundView: UIViewController {
    @IBOutlet weak var furiganaLabel: CustomLabel!
    override func viewDidLoad() {
        //"｜優勝《ゆうしょう》の｜懸《か》かった｜試合《しあい》。"
        "優勝の懸かった試合。".furiganaAttributedString.then { str in
            self.furiganaLabel.attributedText = str
        }
    }
}
