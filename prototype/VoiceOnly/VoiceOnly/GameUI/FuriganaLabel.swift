import Foundation
import UIKit

class FuriganaLabel: UILabel {
    private var height: CGFloat = 0
    private let topPadding: CGFloat = 8

    override var text: String? {
        willSet {
            if let newValue = newValue {
                self.attributedText = rubyAttrStr(newValue, "")
            }
        }
    }

    override var attributedText: NSAttributedString? {
        willSet {
            if  let newValue = newValue,
                let attributedText = self.attributedText,
                newValue != attributedText {
                height = heightOfCoreText(attributed: newValue)
            }
        }
    }

    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        if self.attributedText != nil {
            size.height = height + topPadding
        }
        return size
    }

    // modified from reference: https://stackoverflow.com/questions/47636905/custom-uitableviewcell-with-core-text
    override func drawText(in rect: CGRect) {
        guard let attributed = self.attributedText,
              let context = UIGraphicsGetCurrentContext() else { return }

        let path = CGPath(rect: rect, transform: nil)
        let framesetter = CTFramesetterCreateWithAttributedString(attributed)
        let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attributed.length), path, nil)

        context.textMatrix = CGAffineTransform.identity
        context.translateBy(x: 0, y: rect.height + topPadding)
        context.scaleBy(x: 1.0, y: -1.0)

        CTFrameDraw(frame, context)
    }

    private func heightOfCoreText(attributed: NSAttributedString) -> CGFloat {
        var height = CGFloat()

        var textDrawRect = self.frame
        textDrawRect.size.height = CGFloat.greatestFiniteMagnitude

        let path = CGPath(rect: textDrawRect, transform: nil)
        let framesetter = CTFramesetterCreateWithAttributedString(attributed)
        let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attributed.length), path, nil)

        guard let lines = CTFrameGetLines(frame) as? [CTLine] else { return height }
        for line in lines {
            var ascent = CGFloat()
            var descent = CGFloat()
            var leading = CGFloat()
            CTLineGetTypographicBounds(line, &ascent, &descent, &leading)
            height += ceil(ascent + leading)
        }

        return height
    }
}
