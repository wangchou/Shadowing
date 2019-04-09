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

    var yMax: Int {
        return Int(screen.height / stepFloat)
    }

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
        self.frame = CGRect(x: 0, y: 0, width: screen.width, height: screen.height)
    }

    func viewWillAppear() {
        removeAllSubviews()
        drawTextBackground(bgColor: rgb(60, 60, 60), textColor: rgb(100, 100, 100))
        addTopBar(y: 5)
        addLangInfo(y: (yMax - 18)/2 - 21 + 7)
        addGoButton()
    }

    private func addTopBar(y: Int) {
        func addButton(iconName: String) -> UIButton {
            let button = createButton(title: "", bgColor: myOrange)
            button.setIconImage(named: iconName, tintColor: .black, isIconOnLeft: false)
            button.roundBorder(borderWidth: stepFloat/2, cornerRadius: stepFloat,
                               color: rgb(35, 35, 35))
            addSubview(button)
            return button
        }

        let leftButton = addButton(iconName: "outline_settings_black_24pt")
        layout(3, y, 7, 7, leftButton)
        leftButton.addTapGestureRecognizer {
            (rootViewController.current as? UIPageViewController)?.goToPreviousPage()
        }

        let rightButton = addButton(iconName: "outline_all_inclusive_black_24pt")
        layout(38, y, 7, 7, rightButton)

        rightButton.addTapGestureRecognizer {
            (rootViewController.current as? UIPageViewController)?.goToNextPage()
        }

        // total medal counts
        let outerRect = addRect(x: 13, y: y, w: 22, h: 7,
                                color: UIColor.white.withAlphaComponent(0.2))
        outerRect.roundBorder(borderWidth: stepFloat/2, cornerRadius: stepFloat,
                              color: UIColor.black.withAlphaComponent(0.8))

        let medalView = MedalView()
        layout(15, y + 2, 4, 4, medalView)
        medalView.centerY(outerRect.frame)
        medalView.viewWillAppear()
        addSubview(medalView)

        let starAttrStr = getStrokeText("\(context.gameMedal.totalCount)".padWidthTo(4),
                                        myOrange,
                                        strokeWidth: Float(stepFloat * -3/5),
                                        font: MyFont.heavyDigit(ofSize: 5 * fontSize))
        let label = addAttrText(x: 19, y: y - 1, w: 14, h: 9, text: starAttrStr)
        label.textAlignment = .center
    }

    private func addLangInfo(y: Int) {
        let medal = context.gameMedal

        // info background
        let outerRect = addRect(x: 3, y: y, w: 42, h: 42, color: .clear)
        outerRect.roundBorder(borderWidth: stepFloat/2, cornerRadius: stepFloat * 3,
                              color: UIColor.black.withAlphaComponent(0.8))
        outerRect.addTapGestureRecognizer { [weak self] in
            changeGameLangTo(lang: gameLang == .jp ? .en : .jp)
            self?.viewWillAppear()
        }

        let topBarRect = UIView()
        topBarRect.backgroundColor = UIColor.darkGray.withAlphaComponent(0.7)
        layout(0, 0, 42, 10, topBarRect)
        outerRect.addSubview(topBarRect)

        let bottomBarRect = UIView()
        bottomBarRect.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        layout(0, 10, 42, 32, bottomBarRect)
        outerRect.addSubview(bottomBarRect)

        // medal
        let medalView = MedalView()
        layout(6, y+2, 6, 6, medalView)
        addSubview(medalView)
        medalView.viewWillAppear()

        let starAttrStr = getStrokeText("\(medal.count)".padWidthTo(3),
                                        rgb(220, 220, 220),
                                        strokeWidth: Float(stepFloat * -3/5),
                                        font: MyFont.heavyDigit(ofSize: 7 * fontSize))
        var label = addAttrText(x: 24, y: y + 1, w: 18, h: 8, text: starAttrStr)
        label.textAlignment = .right

        // language name
        let langTitle = gameLang == .jp ? "日本語" : "英語"
        let attrTitle = getStrokeText(langTitle,
                                      .white,
                                      strokeWidth: Float(stepFloat * -2/5),
                                      font: MyFont.bold(ofSize: 10*fontSize))

        label = addAttrText(x: 3, y: y+16, h: 10, text: attrTitle)
        label.centerX(outerRect.frame)
        label.textAlignment = .center
        addMedalProgressBar(y: y + 31, medal: medal, isWithOutGlow: true)
    }

    private func addGoButton() {
        let button = UIButton()
        button.setTitleColor(UIColor.white.withAlphaComponent(0.6), for: .highlighted)
        button.backgroundColor = .red
        let attrText = getStrokeText(
            "GO!",
            .white,
            font: MyFont.bold(ofSize: 8 * stepFloat)
        )
        button.setAttributedTitle(attrText, for: .normal)
        button.roundBorder(borderWidth: stepFloat/2, cornerRadius: stepFloat * 3,
                           color: UIColor.red.withSaturation(0.3))
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
                launchVC(vc, "MessengerGame")
            }
        }
    }

}

extension GridLayout where Self: UIView {
    func drawTextBackground(bgColor: UIColor, textColor: UIColor) {
        backgroundColor = bgColor
        let num = Int(sqrt(pow(screen.width, 2) + pow(screen.height, 2)) / stepFloat)/8
        let level = context.gameMedal.lowLevel
        let sentences = getRandSentences(level: level, numOfSentences: num * 2)
        func randPad(_ string: String) -> String {
            var res = string
            let prefixCount = Int.random(in: 0 ... 10 + level.rawValue * 3)
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
            let label = addText(x: x, y: y, h: 6 - level.rawValue/3, text: sentence, color: textColor)
            label.sizeToFit()
            label.centerX(frame)
            //label.backgroundColor = .white
            label.textAlignment = .left

            label.transform = CGAffineTransform.identity
                .translatedBy(x: 0, y: -1 * screen.width/5)
                .rotated(by: -1 * .pi/8)
        }
    }

    func addMedalProgressBar(
        y: Int,
        medal: GameMedal,
        textColor: UIColor = .black,
        strokeColor: UIColor = .white,
        isWithOutGlow: Bool = false,
        duration: TimeInterval = 0
    ) {

        // lvl text
        var attrTitle = getStrokeText(medal.lowLevel.title,
                                      textColor,
                                      strokeWidth: Float(-0.3 * fontSize), strokColor: strokeColor,
                                      font: MyFont.bold(ofSize: 4 * fontSize))
        var label = addAttrText(x: 7, y: y, h: 6, text: attrTitle)
        label.textAlignment = .left
        if duration > 0 { fadeIn(view: label, duration: duration) }

        // medal count
        let nextLevelBound = medal.highLevel.rawValue * medal.medalsPerLevel
        attrTitle = getStrokeText(
            "\(medal.count)/\(nextLevelBound)",
            textColor,
            strokeWidth: Float(-0.6 * fontSize), strokColor: strokeColor,
            font: MyFont.heavyDigit(ofSize: 4 * fontSize))
        label = addAttrText(x: 7, y: y, h: 6, text: attrTitle)
        layout(21, y, 20, 6, label)
        label.textAlignment = .right
        if duration > 0 { fadeIn(view: label, duration: duration) }

        // bar
        let progressBarBack = UIView()
        progressBarBack.backgroundColor = .white
        layout(7, y + 6, 34, 1, progressBarBack)
        progressBarBack.roundBorder(cornerRadius: stepFloat/2, color: .clear)
        addSubview(progressBarBack)
        if duration > 0 { fadeIn(view: progressBarBack, duration: duration) }

        let progressBarMid = UIView()
        progressBarMid.backgroundColor = medal.lowLevel.color.withSaturation(1)
        progressBarMid.roundBorder(cornerRadius: stepFloat/2, color: .clear)
        progressBarMid.frame = progressBarBack.frame
        let percentage = medal.lowLevel == Level.lv9 ?
            1.0 : CGFloat(medal.count % 50)/50.0
        progressBarMid.frame.size.width = progressBarBack.frame.width * percentage
        addSubview(progressBarMid)
        if duration > 0 { fadeIn(view: progressBarMid, duration: duration) }

        if isWithOutGlow  {
            let progressBarFront = UIView()
            progressBarFront.backgroundColor = .clear
            progressBarFront.roundBorder(borderWidth: 0.5, cornerRadius: stepFloat/2, color: .white)
            progressBarFront.frame = progressBarBack.frame
            addSubview(progressBarFront)
            if duration > 0 { fadeIn(view: progressBarFront, duration: duration) }
        }
    }
}
