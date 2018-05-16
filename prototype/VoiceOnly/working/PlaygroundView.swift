// modified from
// https://stackoverflow.com/questions/46690337/swift-4-ctrubyannotation-dont-work

import Foundation
import UIKit
import Promises

enum JpnType {
    case noKanji
    case kanjiOnly
    case mixed
}

func rubyAttrStr(_ string: String, _ ruby: String = " ") -> NSAttributedString {
    let annotation = CTRubyAnnotationCreateWithAttributes(
        .auto, .auto, .before, ruby as CFString, [:] as CFDictionary)
    
    return NSAttributedString(
        string: string,
        attributes: [kCTRubyAnnotationAttributeName as NSAttributedStringKey: annotation]
    )
}

//    case 1:
//    parts: [わたし、| 気 | になります！]
//    kana: わたしきになります
//
//    case2:
//    parts: [逃 | げるは | 恥 | だが | 役 | に | 立 | つ]
//    kana: にげるははじだがやくにたつ
//    case3:
//    parts: [ブラック | 企業勤 | めのころ]
//    kana: ...
func getFuriganaAttrString(_ parts: [String], _ kana: String) -> NSMutableAttributedString {
    let attrStr = NSMutableAttributedString()
    if parts.count == 0 { return attrStr }
    
    if parts.count == 1 {
        let result = parts[0].jpnType == JpnType.noKanji ?
            rubyAttrStr(parts[0]) :
            rubyAttrStr(parts[0], kana)
        attrStr.append(result)
        return attrStr
    }
    
    for i in 0..<parts.count {
        if parts[i].jpnType != JpnType.noKanji &&
            kana.patternCount(parts[i].hiraganaOnly) != 1 {
            continue
        }
        
        var kanaParts = kana.components(separatedBy: parts[i].hiraganaOnly)
        kanaParts = kanaParts.filter { $0 != "" }
        
        if i > 0 {
            attrStr.append(getFuriganaAttrString(Array(parts[0..<i]), kanaParts[0]))
        }
        
        attrStr.append(rubyAttrStr(parts[i]))
        
        if i + 1 < parts.count {
            let suffixKanaPartsIndex = i == 0 ? 0 : 1
            attrStr.append(
                getFuriganaAttrString(Array(parts[i+1..<parts.count]), kanaParts[suffixKanaPartsIndex])
            )
        }
        
        return attrStr
    }
    
    var kanjiPart = ""
    for part in parts {
        kanjiPart += part
    }
    attrStr.append(rubyAttrStr(kanjiPart, kana))
    return attrStr
}

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
    
    func patternCount(_ pattern: String) -> Int {
        return self.components(separatedBy: pattern).count - 1
    }
    
    var hiraganaOnly: String {
        let hiragana = self.kataganaToHiragana
        guard let hiraganaRange = hiragana.range(of: "\\p{Hiragana}*\\p{Hiragana}", options: .regularExpression)
            else { return "" }
        return String(hiragana[hiraganaRange])
    }
    
    var jpnType: JpnType {
        guard let kanjiRange = self.range(of: "\\p{Han}*\\p{Han}", options: .regularExpression) else { return JpnType.noKanji }
        
        if String(self[kanjiRange]).count == self.count {
            return JpnType.kanjiOnly
        }
        return JpnType.mixed
    }
    
    var furiganaAttributedString: Promise<NSMutableAttributedString> {
        let promise = Promise<NSMutableAttributedString>.pending()
        let furiganaAttrStr = NSMutableAttributedString()
        getKanaTokenInfos(self).then { tokenInfos in
            for tokenInfo in tokenInfos {
                guard tokenInfo.count > 8 else { return }
                let kanjiStr = tokenInfo[0]
                let kana = tokenInfo[8].kataganaToHiragana
                let parts = kanjiStr // [わたし、| 気 | になります！]
                    .replace("(\\p{Han}*\\p{Han})", "👻$1👻")
                    .components(separatedBy: "👻")
                
                furiganaAttrStr.append(getFuriganaAttrString(parts, kana))
            }
           
            furiganaAttrStr.addAttributes(
                [   NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16),
                    NSAttributedStringKey.verticalGlyphForm: false,
                ],
                range: NSMakeRange(0, (furiganaAttrStr.length))
            )
            promise.fulfill(furiganaAttrStr)
        }
        return promise
    }
    
    // Hiragana: 3040-309F
    // Katakana: 30A0-30FF
    var kataganaToHiragana: String {
        var hiragana = ""
        for ch in self {
            let scalars = ch.unicodeScalars
            let chValue = scalars[scalars.startIndex].value
            if chValue >= 0x30A0 && chValue <= 0x30FF {
                hiragana.append(Character(UnicodeScalar( chValue - 0x60)!))
            } else {
                hiragana.append(ch)
            }
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
