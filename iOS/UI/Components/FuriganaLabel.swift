import Foundation
import UIKit

public extension NSAttributedString.Key {
    static let hightlightBackgroundFillColor: NSAttributedString.Key = .init("highlightBackgroundFillColorAttribute")
}

class FuriganaLabel: UILabel {
    open var linkBackgroundEdgeInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    private var height: CGFloat = 60
    private var topShift: CGFloat {
        return 10
    }

    private var hasRuby: Bool {
        var foundRuby = false
        if let attributedText = attributedText {
            attributedText.enumerateAttribute(
                rubyAnnotationKey,
                in: NSRange(location: 0, length: attributedText.length),
                options: .longestEffectiveRangeNotRequired) { obj, _, _ in
                    if obj != nil {
                        foundRuby = true
                    }
            }
        }

        return foundRuby
    }

    private var isEnglish: Bool {
        return attributedText?.string.isHasEn ?? true
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
        context.translateBy(x: 0 + widthPadding, y: rect.height + topShift)
        context.scaleBy(x: 1.0, y: -1.0)

        drawBackground(frame, inRect: rect, context: context)

        CTFrameDraw(frame, context)
    }

    // modified from
    // https://github.com/instacart/Nantes/blob/master/Source/Classes/Drawing/Drawing.swift
    private func drawBackground(_ frame: CTFrame, inRect rect: CGRect, context: CGContext) {
        guard let lines = CTFrameGetLines(frame) as [AnyObject] as? [CTLine] else {
            return
        }

        var origins: [CGPoint] = .init(repeating: .zero, count: lines.count)
        CTFrameGetLineOrigins(frame, CFRange(location: 0, length: 0), &origins)

        var lineIndex = 0
        for line in lines {
            var ascent: CGFloat = 0.0
            var descent: CGFloat = 0.0
            var leading: CGFloat = 0.0

            let width = CGFloat(CTLineGetTypographicBounds(line, &ascent, &descent, &leading))

            guard let glyphRuns = CTLineGetGlyphRuns(line) as [AnyObject] as? [CTRun] else {
                continue
            }

            var backgroundRectCount = 0
            for glyphRun in glyphRuns {
                guard let attributes = CTRunGetAttributes(glyphRun) as NSDictionary as? [NSAttributedString.Key: Any] else {
                    continue
                }
                if (attributes[.hightlightBackgroundFillColor] as? UIColor) == highlightColor {
                    backgroundRectCount += 1
                }
            }

            var unitedHighlightBounds: CGRect = CGRect(x: CGFloat.infinity, y: CGFloat.infinity, width: 0, height: 0)
            for glyphRun in glyphRuns {
                guard let attributes = CTRunGetAttributes(glyphRun) as NSDictionary as? [NSAttributedString.Key: Any] else {
                    continue
                }

                let fillColor: UIColor? = attributes[.hightlightBackgroundFillColor] as? UIColor

                guard fillColor != nil else {
                    lineIndex += 1
                    continue
                }

                var runBounds: CGRect = .zero
                var runAscent: CGFloat = 0.0
                var runDescent: CGFloat = 0.0

                runBounds.size.width = CGFloat(CTRunGetTypographicBounds(glyphRun, CFRange(location: 0, length: 0), &runAscent, &runDescent, nil))
                runBounds.size.height = ascent + descent

                var xOffset: CGFloat = 0.0
                let glyphRange = CTRunGetStringRange(glyphRun)

                switch CTRunGetStatus(glyphRun) {
                case .rightToLeft:
                    xOffset = CTLineGetOffsetForStringIndex(line, glyphRange.location + glyphRange.length, nil)
                default:
                    xOffset = CTLineGetOffsetForStringIndex(line, glyphRange.location, nil)
                }

                runBounds.origin.x = origins[lineIndex].x + rect.origin.x + xOffset  - rect.origin.x
                runBounds.origin.y = origins[lineIndex].y + rect.origin.y  - rect.origin.y - runDescent

                // We don't want to draw too far to the right
                runBounds.size.width = runBounds.width > width ? width : runBounds.width

                if fillColor == highlightColor {
                    let newX = min(unitedHighlightBounds.origin.x, runBounds.origin.x)
                    let newY = min(unitedHighlightBounds.origin.y, runBounds.origin.y)
                    let newWidth = max(unitedHighlightBounds.width, runBounds.origin.x + runBounds.width - newX)

                    unitedHighlightBounds = CGRect(x: newX,
                                          y: newY,
                                          width: newWidth ,
                                          height: ascent + descent)
                } else if let fillColor = fillColor {
                    context.setLineJoin(.round)
                    let path: CGPath = UIBezierPath(roundedRect: runBounds,
                                                    byRoundingCorners: [.bottomLeft, .topLeft, .bottomRight, .topRight],
                                                    cornerRadii: CGSize(width: 5,
                                                                        height: 5)).cgPath
                    context.setFillColor(fillColor.cgColor)
                    context.addPath(path)
                    context.fillPath()
                }
            }

            if unitedHighlightBounds.width > 0 {
                context.setLineJoin(.round)
                let path: CGPath = UIBezierPath(roundedRect: unitedHighlightBounds.expanding(padX: isEnglish ? 3 : 1, padY: 3),
                                                byRoundingCorners: [.bottomLeft, .topLeft, .bottomRight, .topRight],
                                                cornerRadii: CGSize(width: 5,
                                                                    height: 5)).cgPath
                context.setFillColor(highlightColor.cgColor)
                context.addPath(path)
                context.fillPath()
            }

            lineIndex += 1
        }
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

        height += 2

        if height > 50 && isEnglish {
            height += 5
        }

        return height + topShift
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
