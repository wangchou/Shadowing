// modified from
// https://stackoverflow.com/questions/46690337/swift-4-ctrubyannotation-dont-work

import Foundation
import UIKit

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
    
    var furiganaAttributedString: NSMutableAttributedString {
        return self.replace("(｜.+?《.+?》)", "👻$1👻")
            .components(separatedBy: "👻")
            .map { x -> NSAttributedString in
                if let pair = x.find("｜(.+?)《(.+?)》") {
                    let string = (x as NSString).substring(with: pair.range(at: 1))
                    let ruby = (x as NSString).substring(with: pair.range(at: 2))
                    
                    let annotation = CTRubyAnnotationCreateWithAttributes(
                        .auto, .auto, .before, ruby as CFString, [:] as CFDictionary)
                    
                    return NSAttributedString(
                        string: string,
                        attributes: [kCTRubyAnnotationAttributeName as NSAttributedStringKey: annotation])
                } else {
                    return NSAttributedString(string: x, attributes: nil)
                }
            }
            .reduce(NSMutableAttributedString()) { $0.append($1); return $0 }
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
       furiganaLabel.attributedText = "｜優勝《ゆうしょう》の｜懸《か》かった｜試合《しあい》。".furiganaAttributedString
    }
}
