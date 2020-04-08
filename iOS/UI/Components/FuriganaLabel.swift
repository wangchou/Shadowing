import Foundation
import UIKit

public extension NSAttributedString.Key {
    static let nantesLabelBackgroundCornerRadius: NSAttributedString.Key = .init("NantesLabelBackgroundCornerRadiusAttribute")
    static let nantesLabelBackgroundFillColor: NSAttributedString.Key = .init("NantesLabelBackgroundFillColorAttribute")
    static let nantesLabelBackgroundFillPadding: NSAttributedString.Key = .init("NantesLabelBackgroundFillPaddingAttribute")
    static let nantesLabelBackgroundLineWidth: NSAttributedString.Key = .init("NantesLabelBackgroundLineWidthAttribute")
    static let nantesLabelBackgroundStrokeColor: NSAttributedString.Key = .init("NantesLabelBackgroundStrokeColorAttribute")
    static let nantesLabelStrikeOut: NSAttributedString.Key = .init("NantesLabelStrikeOutAttribute")
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
                if (attributes[.nantesLabelBackgroundFillColor] as? UIColor) == highlightColor {
                    backgroundRectCount += 1
                }
            }
            var backgroundRectIndex = 0
            for glyphRun in glyphRuns {
                guard let attributes = CTRunGetAttributes(glyphRun) as NSDictionary as? [NSAttributedString.Key: Any] else {
                    continue
                }

                let strokeColor: UIColor? = attributes[.nantesLabelBackgroundStrokeColor] as? UIColor
                let fillColor: UIColor? = attributes[.nantesLabelBackgroundFillColor] as? UIColor
                let fillPadding: UIEdgeInsets = attributes[.nantesLabelBackgroundFillPadding] as? UIEdgeInsets ?? .zero
                let cornerRadius: CGFloat = attributes[.nantesLabelBackgroundCornerRadius] as? CGFloat ?? 0.0
                let lineWidth: CGFloat = attributes[.nantesLabelBackgroundLineWidth] as? CGFloat ?? 0.0

                guard strokeColor != nil || fillColor != nil else {
                    lineIndex += 1
                    continue
                }

                var runBounds: CGRect = .zero
                var runAscent: CGFloat = 0.0
                var runDescent: CGFloat = 0.0

                runBounds.size.width = CGFloat(CTRunGetTypographicBounds(glyphRun, CFRange(location: 0, length: 0), &runAscent, &runDescent, nil)) + fillPadding.left + fillPadding.right
                runBounds.size.height = ascent + descent + fillPadding.top + fillPadding.bottom // modified

                var xOffset: CGFloat = 0.0
                let glyphRange = CTRunGetStringRange(glyphRun)

                switch CTRunGetStatus(glyphRun) {
                case .rightToLeft:
                    xOffset = CTLineGetOffsetForStringIndex(line, glyphRange.location + glyphRange.length, nil)
                default:
                    xOffset = CTLineGetOffsetForStringIndex(line, glyphRange.location, nil)
                }

                runBounds.origin.x = origins[lineIndex].x + rect.origin.x + xOffset - fillPadding.left - rect.origin.x
                runBounds.origin.y = origins[lineIndex].y + rect.origin.y - fillPadding.bottom - rect.origin.y - runDescent

                // We don't want to draw too far to the right
                runBounds.size.width = runBounds.width > width ? width : runBounds.width

                let roundedRect = runBounds.inset(by: linkBackgroundEdgeInset).insetBy(dx: lineWidth, dy: lineWidth)
                let path: CGPath = UIBezierPath(roundedRect: roundedRect,
                                                byRoundingCorners: [.bottomLeft, .bottomRight],
                                                cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
                context.setLineJoin(.round)

                if let fillColor = fillColor {
                    var roundingCorners: UIRectCorner = []
                    if backgroundRectIndex == 0 {
                        roundingCorners = roundingCorners.union([.bottomLeft, .topLeft])
                    }
                    if backgroundRectIndex == backgroundRectCount - 1 {
                        roundingCorners = roundingCorners.union([.bottomRight, .topRight])
                    }
                    let path: CGPath = UIBezierPath(roundedRect: roundedRect,
                                                    byRoundingCorners: roundingCorners,
                                                    cornerRadii: CGSize(width: cornerRadius,
                                                                        height: cornerRadius)).cgPath
                    context.setFillColor(fillColor.cgColor)
                    context.addPath(path)
                    context.fillPath()

                    if fillColor == highlightColor {
                        backgroundRectIndex += 1
                    }
                }

                if let strokeColor = strokeColor {
                    context.setStrokeColor(strokeColor.cgColor)
                    context.addPath(path)
                    context.strokePath()
                }
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

        if #available(iOS 13, *) {
            height += 3
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
