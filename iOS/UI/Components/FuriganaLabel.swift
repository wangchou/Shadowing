import Foundation
import UIKit

private var highlightRanges: [NSRange] = []

public extension NSAttributedString.Key {
    static let hightlightBackgroundFillColor: NSAttributedString.Key = .init("highlightBackgroundFillColorAttribute")
}

class FuriganaLabel: UILabel {
    open var linkBackgroundEdgeInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    private var height: CGFloat = 60
    private var topShift: CGFloat {
        return 10
    }

    var hasRuby: Bool {
        var foundRuby = false
        if let attributedText = attributedText {
            attributedText.enumerateAttribute(
                rubyAnnotationKey,
                in: NSRange(location: 0, length: attributedText.length),
                options: .longestEffectiveRangeNotRequired
            ) { obj, _, _ in
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
        guard let attributed = attributedText,
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

            var unitedHighlightBounds = CGRect(x: CGFloat.infinity, y: CGFloat.infinity, width: 0, height: 0)
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

                runBounds.origin.x = origins[lineIndex].x + rect.origin.x + xOffset - rect.origin.x
                runBounds.origin.y = origins[lineIndex].y + rect.origin.y - rect.origin.y - runDescent

                // We don't want to draw too far to the right
                runBounds.size.width = runBounds.width > width ? width : runBounds.width

                if fillColor == highlightColor {
                    let newX = min(unitedHighlightBounds.origin.x, runBounds.origin.x)
                    let newY = min(unitedHighlightBounds.origin.y, runBounds.origin.y)
                    let newWidth = max(unitedHighlightBounds.width, runBounds.origin.x + runBounds.width - newX)

                    unitedHighlightBounds = CGRect(x: newX,
                                                   y: newY,
                                                   width: newWidth,
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

        if #available(iOS 13, *) {
            height += height > 50 ? 7 : 2
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

// Highlight Range Related
extension FuriganaLabel {
    static func clearHighlighRange() {
        highlightRanges = []
    }

    func updateHighlightRange(newRange: NSRange, targetString: String, voiceRate: Float) {
        highlightRanges.append(newRange)
        let duration = Double(0.15 / (2 * voiceRate))

        Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
            if !highlightRanges.isEmpty {
                highlightRanges.removeFirst()
            }
        }
        let allRange: NSRange = highlightRanges.reduce(highlightRanges[0]) { allR, curR in
            allR.union(curR)
        }

        var attrText = NSMutableAttributedString()

        if let tokenInfos = kanaTokenInfosCacheDictionary[targetString] {
            let fixedRange = getRangeWithParticleFix(targetString: targetString,
                                                     tokenInfos: tokenInfos,
                                                     allRange: allRange)
            attrText = getFuriganaString(tokenInfos: tokenInfos)

            // version: 1.3.13 - 1.3.14
            // Crashed info: NSMutableRLEArray objectAtIndex:effectiveRange:: Out of bounds
            // cannot reproduce it => add upperBound check here
            if let fixedRange = fixedRange,
               attrText.allRange.contains(fixedRange.lowerBound),
               attrText.allRange.contains(fixedRange.upperBound - 1) {
                attrText.addAttributes([.hightlightBackgroundFillColor: highlightColor],
                                       range: fixedRange)
            }
        } else {
            attrText.append(rubyAttrStr(targetString))
            attrText.addAttributes([
                .hightlightBackgroundFillColor: highlightColor,
            ], range: allRange)
            let whiteRange = NSRange(location: allRange.upperBound, length: targetString.count - allRange.upperBound)
            attrText.addAttribute(.hightlightBackgroundFillColor, value: UIColor.clear, range: whiteRange)
        }
        attributedText = attrText
    }

    // The iOS tts speak japanese always report willSpeak before particle or mark
    // ex: when speaking 鴨川沿いには遊歩道があります
    // the tts spoke "鴨川沿いには", but the delegate always report "鴨川沿い"
    // then it reports "には遊歩道"
    // so this function will remove prefix particle range and extend suffix particle range
    //
    // known unfixable bug:
    //      pass to tts:  あした、晴れるかな
    //      targetString: 明日、晴れるかな
    //      ttsKanaFix will sometimes make the range is wrong
    func getRangeWithParticleFix(targetString: String,
                                 tokenInfos: [[String]],
                                 allRange: NSRange?) -> NSRange? {
        guard let r = allRange else { return nil }
        var lowerBound = r.lowerBound
        var upperBound = min(r.upperBound, targetString.count)
        var currentIndex = 0
        var isPrefixParticleRemoved = false
        var isPrefixSubVerbRemoved = false
        var isParticleSuffixExtended = false
        var isWordExpanded = false

        for i in 0 ..< tokenInfos.count {
            let part = tokenInfos[i]
            let partLen = part[0].count
            let isParticle = part[1] == "助詞" || part[1] == "記号" || part[1] == "助動詞"
            let isVerbLike = part[1] == "動詞" || part[1] == "形容詞"

            // fix: "お掛けに" なりませんか
            if part[1] == "接頭詞",
               currentIndex >= lowerBound,
               currentIndex + partLen == upperBound,
               i < tokenInfos.count - 1 {
                upperBound += tokenInfos[i + 1][0].count
            }
            if i > 0,
               tokenInfos[i - 1][1] == "接頭詞",
               currentIndex == lowerBound {
                lowerBound -= tokenInfos[i - 1][0].count
            }

            // prefix particle remove
            // ex: "が降りそう" の　"が"
            func trimPrefixParticle() {
                if !isPrefixParticleRemoved,
                   currentIndex <= lowerBound,
                   currentIndex + partLen > lowerBound,
                   currentIndex + partLen < upperBound {
                    if isParticle {
                        lowerBound = currentIndex + partLen
                    } else {
                        isPrefixParticleRemoved = true
                    }
                }
            }

            // prefix subVerb remove
            // ex: "が降りそう" の　"り"
            func trimPrefixSubVerb() {
                if !isPrefixSubVerbRemoved,
                   currentIndex < lowerBound,
                   currentIndex + partLen >= lowerBound,
                   currentIndex + partLen < upperBound {
                    if isVerbLike {
                        lowerBound = currentIndex + partLen
                    } else {
                        isPrefixSubVerbRemoved = true
                    }
                }
            }

            // fixed to whole word
            // "有給休假"，只 highlight "休假" 時 => 改 highlight 整個字
            func expandWholeWord() {
                if currentIndex <= lowerBound,
                   lowerBound < currentIndex + partLen {
                    lowerBound = currentIndex
                }

                if !isWordExpanded,
                   currentIndex < upperBound,
                   upperBound < currentIndex + partLen {
                    upperBound = currentIndex + partLen
                    isWordExpanded = true
                }
            }

            // for "っています" subVerb + Particle + others
            trimPrefixSubVerb()
            trimPrefixParticle()
            trimPrefixSubVerb()
            expandWholeWord()

            // suffix particle extend
            if !isParticleSuffixExtended,
               currentIndex >= upperBound {
                if isParticle {
                    upperBound = currentIndex + partLen
                } else {
                    isParticleSuffixExtended = true
                }
            }

            currentIndex += partLen
        }

        guard upperBound >= lowerBound,
              upperBound <= targetString.count,
              lowerBound <= targetString.count,
              upperBound >= 0,
              lowerBound >= 0 else {
            print("something went wrong on highlight bounds")
            return nil
        }
        return NSRange(location: lowerBound, length: upperBound - lowerBound)
    }
}
