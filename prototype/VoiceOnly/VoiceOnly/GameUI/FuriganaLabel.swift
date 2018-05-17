import Foundation
import UIKit

class FuriganaLabel: UILabel {
    private var height: CGFloat = 60
    private let topShift: CGFloat = 7
    private let widthPadding: CGFloat = 7

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
                height = heightOfCoreText(attributed: newValue, width: self.frame.width - widthPadding * 2)
            }
        }
    }

    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        if self.attributedText != nil {
            size.height = height
        }
        return size
    }

    // modified from reference: https://stackoverflow.com/questions/47636905/custom-uitableviewcell-with-core-text
    override func drawText(in rect: CGRect) {
        guard let attributed = self.attributedText,
              let context = UIGraphicsGetCurrentContext() else { return }

        var textDrawRect = rect
        textDrawRect.size.width = rect.width - widthPadding * 2
        let path = CGPath(rect: textDrawRect, transform: nil)
        let framesetter = CTFramesetterCreateWithAttributedString(attributed)
        let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attributed.length), path, nil)

        context.textMatrix = CGAffineTransform.identity
        context.translateBy(x: 0 + widthPadding, y: rect.height + topShift)
        context.scaleBy(x: 1.0, y: -1.0)

        CTFrameDraw(frame, context)
    }

    func heightOfCoreText(attributed: NSAttributedString, width: CGFloat) -> CGFloat {
        var height = CGFloat()

        var textDrawRect = self.frame
        textDrawRect.size.height = CGFloat.greatestFiniteMagnitude
        textDrawRect.size.width = width

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

        return height + topShift
    }

    func widthOfCoreText(attributed: NSAttributedString, maxWidth: CGFloat) -> CGFloat {
        var previousWidth = maxWidth
        var width = maxWidth
        repeat {
            var textDrawRect = self.frame
            textDrawRect.size.height = CGFloat.greatestFiniteMagnitude
            textDrawRect.size.width = width - widthPadding * 2

            let path = CGPath(rect: textDrawRect, transform: nil)
            let framesetter = CTFramesetterCreateWithAttributedString(attributed)
            let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attributed.length), path, nil)

            guard let lines = CTFrameGetLines(frame) as? [CTLine],
                  lines.count == 1 else { return previousWidth }
            previousWidth = width
            width -= 5
        } while(width > 30)

        return previousWidth

    }
}
