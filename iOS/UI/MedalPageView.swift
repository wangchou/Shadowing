//
//  MedalGamePage.swift
//  今話したい
//
//  Created by Wangchou Lu on 3/26/31 H.
//  Copyright © 31 Heisei Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

private let context = GameContext.shared

@IBDesignable
class MedalPageView: UIView, ReloadableView, GridLayout {
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
        self.clipsToBounds = true
        backgroundColor = .orange
        self.frame = CGRect(x: 0, y: 0, width: screen.width, height: screen.height)
    }

    func viewWillAppear() {
        removeAllSubviews()

        drawBackground()
        addLangInfo(y: 10)
        addGoButton()
    }

    private func drawBackground() {
        backgroundColor = rgb(50, 50, 50)
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
        let medal = context.gameMedal

        // info background
        let languageRect = addRect(x: 3, y: y, w: 42, h: 42, color: rgb(255, 255, 255).withAlphaComponent(0.7))
        languageRect.roundBorder(borderWidth: stepFloat/2, cornerRadius: stepFloat * 4, color: rgb(150, 150, 150))

        let topBarRect = UIView()
        topBarRect.backgroundColor = .darkGray
        layout(0, 0, 42, 12, topBarRect)
        languageRect.addSubview(topBarRect)

        let medalCountStr = "\(medal.count)".padWidthTo(3)
        let starStr = "⭐️ \(medalCountStr)"
        let starAttrStr = getStrokeText(starStr, myOrange, strokeWidth: -2.5, font: MyFont.bold(ofSize: 8*fontSize))
        var label = addAttrText(x: 3, y: y + 1, h: 10, text: starAttrStr)
        label.centerX(languageRect.frame)
        label.textAlignment = .center

        // language name
        let langTitle = gameLang == .jp ? "日本語" : "英語"
        let attrTitle = getStrokeText(langTitle, .white, strokeWidth: -2.5, font: MyFont.bold(ofSize: 10*fontSize))

        label = addAttrText(x: 3, y: y+16, h: 10, text: attrTitle)
        label.centerX(languageRect.frame)
        label.textAlignment = .center

        // progress bar
        label = addText(x: 6, y: y + 31, h: 6, text: medal.lowLevel.title)
        label.textAlignment = .left

        let nextLevelBound = medal.highLevel.rawValue * 50
        label = addText(x: 6, y: y + 31, h: 6, text: "\(medal.count)/\(nextLevelBound)")
        layout(22, y + 31, 20, 6, label)
        label.textAlignment = .right

        let progressBarBack = UIView()
        progressBarBack.backgroundColor = .white
        layout(6, y + 37, 36, 1, progressBarBack)
        progressBarBack.roundBorder(borderWidth: 1.5, cornerRadius: stepFloat/2, color: .clear)
        addSubview(progressBarBack)

        let progressBarFront = UIView()
        progressBarFront.backgroundColor = medal.lowLevel.color
        progressBarFront.roundBorder(borderWidth: 1.5, cornerRadius: stepFloat/2, color: .clear)
        layout(6, y + 37, 32, 1, progressBarFront)
        var percentage: CGFloat = 0.0
        if medal.lowLevel == Level.lv9 {
            percentage = 1.0
        } else {
            percentage = CGFloat(medal.count % 50)/50.0
        }
        progressBarFront.frame.size.width = progressBarBack.frame.width * percentage
        addSubview(progressBarFront)
    }

    private func addGoButton() {
        let yMax = Int(screen.height / stepFloat)

        let button = UIButton()
        button.setTitleColor(UIColor.white.withAlphaComponent(0.6), for: .highlighted)
        button.backgroundColor = .red
        let attrText = getStrokeText(
            "GO!",
            .white,
            font: MyFont.bold(ofSize: 8 * stepFloat)
        )
        button.setAttributedTitle(attrText, for: .normal)
        button.roundBorder(borderWidth: stepFloat/2, cornerRadius: stepFloat * 4, color: UIColor.red.withSaturation(0.4))
        button.showsTouchWhenHighlighted = true
        button.addTarget(self, action: #selector(onGoButtonClicked), for: .touchUpInside)

        layout(3, yMax - 18, 42, 12, button)
        addSubview(button)

    }

    @objc func onGoButtonClicked() {
        context.gameMode = .medalMode
        guard !TopicDetailPage.isChallengeButtonDisabled else { return }
        if let vc = UIApplication.getPresentedViewController() {
            if isUnderDailySentenceLimit() {
                launchStoryboard(vc, "MessengerGame")
            }
        }
    }

}
