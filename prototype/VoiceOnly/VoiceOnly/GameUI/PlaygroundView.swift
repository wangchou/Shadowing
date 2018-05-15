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
                if tokenInfo.count < 9 {
                    return
                }
                let token = tokenInfo[0] // ex: 懸かっ
                let tokenKana = tokenInfo[8].kataganaToHiragana // ex: かかっ
                
                if let kanjiRange = token.range(of: "\\p{Han}*\\p{Han}", options: .regularExpression) {
                    //let kanji = String(token[kanjiRange]) // ex: 懸
                    //var kana = tokenKana // ex: か
                    //var suffixPart = token // ex: かっ
                    
//                    if kanji.count < token.count {
//                        suffixPart.removeSubrange(kanjiRange)
//                        kana.removeLast(suffixPart.count)
//                    }
                    
                    let annotation = CTRubyAnnotationCreateWithAttributes(
                        .auto, .auto, .before, tokenKana as CFString, [:] as CFDictionary)
                    
                    attributeStr.append(NSAttributedString(
                        string: token,
                        attributes: [kCTRubyAnnotationAttributeName as NSAttributedStringKey: annotation]))
                    
//                    if kanji.count < token.count {
//                        attributeStr.append(NSAttributedString(string: suffixPart, attributes: nil))
//                    }
                } else {
                    attributeStr.append(NSAttributedString(string: token, attributes: nil))
                }
            }
           
            attributeStr.addAttributes(
                [   NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16),
                    NSAttributedStringKey.verticalGlyphForm: false,
                ],
                range: NSMakeRange(0, (attributeStr.length)))
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
    override func viewDidLoad() {
        
        //print("世の中に失敗というものはない。".replace("(\\p{Han}*\\p{Han})", "👻$1👻"))
        //"逃げるは恥だが役に立つ".furiganaAttributedString.then { str in
        //    self.furiganaLabel.attributedText = str
        //}
    }
}

extension PlaygroundView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return n3.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "N3SentencesCell", for: indexPath) as! N3SentenceCell
        
        n3[indexPath.row].furiganaAttributedString.then { str in
            cell.sentenceLabel.attributedText = str
        }
        
        //cell.sentenceLabel.text = n3[indexPath.row]
        
        return cell
    }
}

class N3SentenceCell: UITableViewCell {
    @IBOutlet weak var sentenceLabel: CustomLabel!
}
