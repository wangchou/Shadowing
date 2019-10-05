import Foundation
import UIKit

class FuriganaLabel: UILabel {
    private var height: CGFloat = 60
    private var topShift: CGFloat { return 6 }
    private var topTranslateY: CGFloat {
        return text?.jpnType == JpnType.noKanjiAndNumber ? 5 : 0
    }

    var widthPadding: CGFloat = 10

    override var text: String? {
        willSet {
            if let newValue = newValue {
                lineBreakMode = .byWordWrapping
                self.attributedText = rubyAttrStr(newValue)
            }
        }
    }

    override var attributedText: NSAttributedString? {
        willSet {
            if let newValue = newValue,
                newValue != self.attributedText {
                height = heightOfCoreText(attributed: newValue, width: self.frame.width)
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
        context.translateBy(x: 0 + widthPadding, y: rect.height + topShift + topTranslateY)
        context.scaleBy(x: 1.0, y: -1.0)

        CTFrameDraw(frame, context)
    }

    func heightOfCoreText(attributed: NSAttributedString, width: CGFloat) -> CGFloat {
        guard attributed.string != "" else { return 28 + topShift }
        var height = CGFloat()

        let textDrawRect = CGRect(
            x: x0,
            y: y0,
            width: width - widthPadding * 2,
            height: CGFloat.greatestFiniteMagnitude
        )

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

        if #available(iOS 13, *), height + topShift + topTranslateY > 50 {
            height += 4
        }

        return height + topShift + topTranslateY
    }

    // sizeToFit on width
    func widthOfCoreText(attributed: NSAttributedString, maxWidth: CGFloat) -> CGFloat {
        var previousWidth = maxWidth
        var width = maxWidth
        let resizeWidthStep: CGFloat = 3
        let framesetter = CTFramesetterCreateWithAttributedString(attributed)
        repeat {
            let textDrawRect = CGRect(
                x: x0,
                y: y0,
                width: width - widthPadding * 2,
                height: CGFloat.greatestFiniteMagnitude
            )

            let path = CGPath(rect: textDrawRect, transform: nil)
            let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attributed.length), path, nil)

            if let lines = CTFrameGetLines(frame) as? [CTLine] {
                if lines.count > 1 { return previousWidth }
            } else {
                return 0
            }
            previousWidth = width
            width -= resizeWidthStep
        } while width > 30

        return previousWidth
    }
}
