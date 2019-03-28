//
//  TrophyGamePage.swift
//  今話したい
//
//  Created by Wangchou Lu on 3/26/31 H.
//  Copyright © 31 Heisei Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

private let context = GameContext.shared

@IBDesignable
class TrophyPageView: UIView, ReloadableView, GridLayout {
    var gridCount: Int = 48

    var axis: GridAxis = .horizontal

    var spacing: CGFloat = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        sharedInit()
    }

    func sharedInit() {
        backgroundColor = .orange
        self.frame = CGRect(x: 0, y: 0, width: screen.width, height: screen.height)
    }

    func viewWillAppear() {
        removeAllSubviews()
        backgroundColor = rgb(50, 50, 50)

        addAnimatedBackgroundText()
        addLangInfo(y: 10)
    }

    private func addAnimatedBackgroundText() {

        let num = Int(sqrt(pow(screen.width, 2) + pow(screen.height, 2)) / stepFloat)/8
        let level = Level.lv9
        let sentences = getRandSentences(level: level, numOfSentences: num * 2)
        func randPad(_ string: String) -> String {
            var res = string
            let prefixCount = Int.random(in: 0 ... 30)
            let suffixCount = Int.random(in: 2 ... 8)
            for _ in 0 ..< prefixCount {
                res = " " + res
            }
            for _ in 0 ..< suffixCount {
                res += " "
            }
            return res
        }
        for i in 0 ..< num {
            let x = 1
            let y = i * 9
            let sentence = randPad(sentences[i]) + sentences[i+num]
            let label = addText(x: x, y: y, h: 6, text: sentence, color: rgb(90, 90, 90))
            label.sizeToFit()
            label.centerX(frame)
            //label.backgroundColor = .white
            label.textAlignment = .left

            label.transform = CGAffineTransform.identity
                .translatedBy(x: 0, y: -1 * screen.width/5)
                .rotated(by: -1 * .pi/8)
        }
    }

    private func addLangInfo(y: Int) {

        let languageRect = addRect(x: 3, y: y, w: 42, h: 42, color: .lightGray)
        languageRect.roundBorder(borderWidth: 2.5, cornerRadius: stepFloat * 3, color: .white)

        let topBarRect = UIView()
        topBarRect.backgroundColor = .darkGray
        layout(0, 0, 42, 12, topBarRect)
        languageRect.addSubview(topBarRect)

        let trophyCountStr = "25".padWidthTo(3)
        let starStr = "⭐️ \(trophyCountStr)"
        let starAttrStr = getStrokeText(starStr, myOrange, strokeWidth: -2.5, font: MyFont.bold(ofSize: 8*fontSize))
        var label = addAttrText(x: 3, y: y + 1, h: 10, text: starAttrStr)
        label.centerX(languageRect.frame)
        label.textAlignment = .center

        let langTitle = "日本語"
        let attrTitle = getStrokeText(langTitle, .white, strokeWidth: -2.5, font: MyFont.bold(ofSize: 10*fontSize))

        label = addAttrText(x: 3, y: y+16, h: 10, text: attrTitle)
        label.centerX(languageRect.frame)
        label.textAlignment = .center

        let currentLevelTitle = "超難問一   150/210"
        label = addText(x: 3, y: y + 30, h: 6, text: currentLevelTitle)
        label.centerX(languageRect.frame)
        label.textAlignment = .center

        // progress bar
        let progressBarBack = UIView()
        progressBarBack.backgroundColor = rgb(220, 220, 220)
        layout(6, y + 37, 36, 1, progressBarBack)
        progressBarBack.roundBorder(borderWidth: 1.5, cornerRadius: stepFloat/2, color: .clear)
        addSubview(progressBarBack)

        let progressBarFront = UIView()
        progressBarFront.backgroundColor = rgb(100, 100, 100)
        progressBarFront.roundBorder(borderWidth: 1.5, cornerRadius: stepFloat/2, color: .clear)
        layout(6, y + 37, 32, 1, progressBarFront)
        addSubview(progressBarFront)

    }

}
