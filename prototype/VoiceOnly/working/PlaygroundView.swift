// modified from
// https://stackoverflow.com/questions/46690337/swift-4-ctrubyannotation-dont-work

import Foundation
import UIKit
import Promises

enum JpnType {
    case noKanjiAndNumber
    case kanjiAndNumberOnly
    case mixed
}

func rubyAttrStr(_ string: String, _ ruby: String = " ") -> NSAttributedString {
    let annotation = CTRubyAnnotationCreateWithAttributes(
        .auto, .auto, .before, ruby as CFString,
        [:] as CFDictionary)
        //[kCTForegroundColorAttributeName: UIColor.blue.cgColor] as CFDictionary)
        //[kCTFontAttributeName: UIFont.boldSystemFont(ofSize: 9)] as CFDictionary)
    return NSAttributedString(
        string: string,
        attributes: [
            // if need to use same font in CTRun or 7時 furigana will not aligned
            //.font: UIFont(name: "HiraginoSans-W3", size: 18.0)!,
            .font: UIFont(name: ".HiraKakuInterface-W6", size: 18.0)!,
            .foregroundColor: UIColor.white,
            .strokeColor: UIColor.black,
            .strokeWidth: -1,
            kCTRubyAnnotationAttributeName as NSAttributedStringKey: annotation
        ]
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
        let result = parts[0].jpnType == JpnType.noKanjiAndNumber ?
            rubyAttrStr(parts[0]) :
            rubyAttrStr(parts[0], kana)

        attrStr.append(result)
        return attrStr
    }
    
    for i in 0..<parts.count {
        if parts[i].jpnType != JpnType.noKanjiAndNumber &&
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

func getFuriganaString(tokenInfos: [[String]]) -> NSMutableAttributedString {
    let furiganaAttrStr = NSMutableAttributedString()
    for tokenInfo in tokenInfos {
        if tokenInfo.count == 8 { // number strings
            furiganaAttrStr.append(rubyAttrStr(tokenInfo[0]))
            continue
        }
        if tokenInfo.count == 10 {
            let kanjiStr = tokenInfo[0]
            let kana = tokenInfo[8].kataganaToHiragana
            let parts = kanjiStr // [わたし、| 気 | になります！]
                .replace("([\\p{Han}\\d]*[\\p{Han}\\d])", "👻$1👻")
                .components(separatedBy: "👻")
                .filter { $0 != "" }
            
            furiganaAttrStr.append(getFuriganaAttrString(parts, kana))
            continue
        }
        print("unknown situation with tokenInfo: ", tokenInfo)
    }
//    let paragraphStyle = NSMutableParagraphStyle()
//    paragraphStyle.lineHeightMultiple = 0.8
//    paragraphStyle.lineSpacing = 0
//    furiganaAttrStr.addAttribute(
//        .paragraphStyle,
//        value: paragraphStyle,
//        range: NSMakeRange(0, furiganaAttrStr.length)
//    )
    return furiganaAttrStr
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
        guard let kanjiRange = self.range(of: "[\\p{Han}\\d]*[\\p{Han}\\d]", options: .regularExpression) else { return JpnType.noKanjiAndNumber }
        
        if String(self[kanjiRange]).count == self.count {
            return JpnType.kanjiAndNumberOnly
        }
        return JpnType.mixed
    }
    
    var furiganaAttributedString: Promise<NSMutableAttributedString> {
        let promise = Promise<NSMutableAttributedString>.pending()
        
        getKanaTokenInfos(self).then {
            promise.fulfill(getFuriganaString(tokenInfos: $0))
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

class FuriganaLabel: UILabel {
    var height: CGFloat = 0
    
    override var attributedText: NSAttributedString? {
        willSet {
            if  let newValue = newValue,
                let attributedText = self.attributedText,
                newValue.string != attributedText.string {
                height = heightOfCoreText(attributed: newValue)
            }
        }
    }

    //override func draw(_ rect: CGRect) { // if not has drawText, use draw UIView etc
    override func drawText(in rect: CGRect) {
        guard let attributed = self.attributedText else { return }
        guard let context = UIGraphicsGetCurrentContext() else { return }
        var path:CGPath

        context.textMatrix = CGAffineTransform.identity
        context.translateBy(x: 0, y: rect.height + 6)
        context.scaleBy(x: 1.0, y: -1.0)

        path = CGPath(rect: rect, transform: nil)

        let framesetter = CTFramesetterCreateWithAttributedString(attributed)
        let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attributed.length), path, nil)

        CTFrameDraw(frame, context)
    }

    private func heightOfCoreText(attributed: NSAttributedString) -> CGFloat {
        var height = CGFloat()

        // MEMO: height = CGFloat.greatestFiniteMagnitude
        let textDrawRect = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.size.width, height: CGFloat.greatestFiniteMagnitude)
        let path = CGPath(rect: textDrawRect, transform: nil)
        let framesetter = CTFramesetterCreateWithAttributedString(attributed)
        let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attributed.length), path, nil)
        let anyArray: [AnyObject] = CTFrameGetLines(frame) as [AnyObject]
        let lines = anyArray as! [CTLine]
        for line in lines {
            //print(line)
            var ascent = CGFloat()
            var descent = CGFloat()
            var leading = CGFloat()
            CTLineGetTypographicBounds(line, &ascent, &descent, &leading)
            height += ceil(ascent + leading)
            //print(ascent, descent, leading)
        }

        return height
    }

    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        if self.attributedText != nil {
           size.height = height + 10
        }
        return size
    }
}

fileprivate let dataSet = n4

class PlaygroundView: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        
        all(dataSet.map {$0.furiganaAttributedString}).then {_ in
            self.tableView.reloadData()
        }
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
        return dataSet.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "N3SentencesCell", for: indexPath) as! N3SentenceCell
        let str = dataSet[indexPath.row]
        if let tokenInfos = kanaTokenInfosCacheDictionary[str] {
            cell.sentenceLabel.attributedText = getFuriganaString(tokenInfos: tokenInfos)
        }
        
        return cell
    }
}

class N3SentenceCell: UITableViewCell {
    @IBOutlet weak var sentenceLabel: FuriganaLabel!
}

