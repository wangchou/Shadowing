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
        drawTextBackground(bgColor: rgb(60, 60, 60), textColor: textGold)
        addTopBar(y: 5)
        addLangInfo(y: (yMax - 18)/2 - 21 + 10)
        addGoButton(y: (yMax - 18)/2 - 21 + 40)
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

        var iconPX = "24pt"
        if isIPad { iconPX = "48pt"}

        let leftButton = addButton(iconName: "outline_settings_black_\(iconPX)")
        layout(3, y, 7, 7, leftButton)
        leftButton.addTapGestureRecognizer {
            (rootViewController.current as? UIPageViewController)?.goToPreviousPage()
        }

        let rightButton = addButton(iconName: "outline_all_inclusive_black_\(iconPX)")
        layout(38, y, 7, 7, rightButton)

        rightButton.addTapGestureRecognizer {
            (rootViewController.current as? UIPageViewController)?.goToNextPage()
        }

        // total medal counts
        let outerRect = addRect(x: 13, y: y, w: 22, h: 7,
                                color: UIColor.white.withAlphaComponent(0.15))
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

    @objc func onChangeLangButtonClicked() {
        changeGameLangTo(lang: gameLang == .jp ? .en : .jp)
        self.viewWillAppear()
    }

    private func addLangInfo(y: Int) {
        let medal = context.gameMedal

        // changeLangButton
        let changeLangButton = UIButton()
        changeLangButton.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        changeLangButton.roundBorder(borderWidth: 0, cornerRadius: stepFloat, color: .clear)
        var attrTitle = getStrokeText(gameLang == .jp ? "英" : "日",
                                      rgb(200, 200, 200),
                                      strokeWidth: Float(stepFloat * -1/3),
                                      font: MyFont.bold(ofSize: 4*fontSize))

        changeLangButton.setAttributedTitle(attrTitle, for: .normal)
        layout(36, y+6, 8, 5, changeLangButton)
        changeLangButton.addTarget(self, action: #selector(onChangeLangButtonClicked), for: .touchUpInside)
        changeLangButton.showsTouchWhenHighlighted = true
        addSubview(changeLangButton)

        // Title
        let rect = addRect(x: 4, y: y+15, w: 40, h: 22, color: UIColor.black.withAlphaComponent(0.4))
        rect.roundBorder(borderWidth: 0, cornerRadius: stepFloat * 3, color: .clear)
        attrTitle = getStrokeText(gameLang == .jp ? "日本語" : "英語",
                                  .white,
                                  strokeWidth: Float(stepFloat * -1/3),
                                  font: MyFont.bold(ofSize: 10*fontSize))

        let label = addAttrText(x: 7, y: y+9, h: 13, text: attrTitle)
        label.sizeToFit()

        addMedalProgressBar(y: y + 19, medal: medal, isWithOutGlow: false)
    }

    private func addGoButton(y: Int) {
        let button = UIButton()
        let w = 18
        button.setTitleColor(UIColor.white.withAlphaComponent(0.6), for: .highlighted)
        button.backgroundColor = .red
        let attrText = getStrokeText(
            "GO!",
            .white,
            font: MyFont.bold(ofSize: 5 * stepFloat)
        )
        button.setAttributedTitle(attrText, for: .normal)
        button.roundBorder(borderWidth: stepFloat/2,
                           cornerRadius: stepFloat * CGFloat(w)/2,
                           color: .black)
        button.showsTouchWhenHighlighted = true
        button.addTarget(self, action: #selector(onGoButtonClicked), for: .touchUpInside)

        layout(26, y, w, w, button)
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

func rollingText(view: UIView) {
    let animator = UIViewPropertyAnimator(duration: 15, curve: .easeOut, animations: {
        view.transform = CGAffineTransform.identity
            .translatedBy(x: 0, y: screen.width/2)
            .rotated(by: -1 * .pi/8)
            .translatedBy(x: -400, y: -200)
    })

    animator.startAnimation()
}

extension GridLayout where Self: UIView {
    func drawTextBackground(bgColor: UIColor, textColor: UIColor) {
        backgroundColor = bgColor
        let num = Int(sqrt(pow(screen.width, 2) + pow(screen.height, 2)) / stepFloat)/8
        let level = context.gameMedal.lowLevel
        let sentences = getRandSentences(level: level, numOfSentences: num * 4)
        func randPad(_ string: String) -> String {
            var res = string
            let prefixCount = Int.random(in: 0 ... 10)
            let suffixCount = Int.random(in: 2 ... 10)
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
            let sentence = randPad(sentences[i]) +
                           randPad(sentences[i+num]) +
                           randPad(sentences[i + (2 * num)]) +
                           sentences[i + (3 * num)]
            let label = addText(x: x, y: y, h: 6 - level.rawValue/3, text: sentence, color: textColor)
            label.sizeToFit()
            label.centerX(frame)
            label.textAlignment = .left

            label.transform = CGAffineTransform.identity
                .translatedBy(x: 0, y: screen.width/2)
                .rotated(by: -1 * .pi/8)
            rollingText(view: label)
        }
    }

    func drawMedal(_ medalCount: Int, x: Int, y: Int) {
        let h = 6
        let textSize = 5 * fontSize
        let medalW = 4

        // medal
        let medalView = MedalView()
        layout(x + 1, y, medalW, medalW, medalView)
        addSubview(medalView)
        medalView.viewWillAppear()

        // medal count
        let attrTitle = getStrokeText(
            "\(medalCount)",
            myOrange,
            strokeWidth: Float(-0.6 * fontSize), strokColor: .black,
            font: MyFont.heavyDigit(ofSize: textSize))
        let label = addAttrText(x: x + medalW + 2, y: y, w: 11, h: h, text: attrTitle)

        let rect = label.frame
        label.sizeToFit()
        label.moveToRight(rect)
        label.centerY(medalView.frame)
        medalView.frame.origin.x = label.frame.origin.x -
            medalView.frame.width -
            stepFloat/2
    }

    func addMedalProgressBar(
        y: Int,
        medal: GameMedal,
        isWithOutGlow: Bool = false,
        delay: TimeInterval = 0,
        duration: TimeInterval = 0
    ) {
        var views: [UIView] = []

        // lvl text
        let attrText = getStrokeText(medal.lowLevel.lvlTitle,
                                     .white,
                                     strokeWidth: Float(-0.3 * fontSize),
                                     strokColor: .black,
                                     font: MyFont.bold(ofSize: 4 * fontSize))

        var label = addAttrText(x: 7, y: y, h: 6,
                                text: attrText)
        label.textAlignment = .left
        views.append(label)

        drawMedal(medal.count, x: 24, y: y + 1)

        // medal higher bound
        let lightTextColor = rgb(180, 180, 180)
        var medalText = "\((medal.lowLevel.rawValue + 1) * medal.medalsPerLevel)"
        label = addText(x: 31, y: y + 7, w: 10, h: 3,
                            text: medalText, color: lightTextColor)
        label.frame.origin.y += stepFloat/2
        label.textAlignment = .right
        views.append(label)

        // medal lower bound
        medalText = "\(medal.lowLevel.rawValue * medal.medalsPerLevel)"
        label = addText(x: 7, y: y + 7, w: 10, h: 3,
                        text: medalText, color: lightTextColor)
        label.frame.origin.y += stepFloat/2
        label.textAlignment = .left
        views.append(label)

        // bar
        let progressBarBack = UIView()
        progressBarBack.backgroundColor = .white
        layout(7, y + 6, 34, 1, progressBarBack)
        progressBarBack.roundBorder(cornerRadius: stepFloat/2, color: .clear)
        addSubview(progressBarBack)
        views.append(progressBarBack)

        let progressBarMid = UIView()
        progressBarMid.backgroundColor = medal.lowLevel.color.withSaturation(1)
        progressBarMid.roundBorder(cornerRadius: stepFloat/2, color: .clear)
        progressBarMid.frame = progressBarBack.frame
        let percentage = medal.count > 500 ?
            1.0 : CGFloat(medal.count % 50)/50.0
        progressBarMid.frame.size.width = progressBarBack.frame.width * percentage
        addSubview(progressBarMid)
        views.append(progressBarMid)

        if isWithOutGlow {
            let progressBarFront = UIView()
            progressBarFront.backgroundColor = .clear
            progressBarFront.roundBorder(borderWidth: 0.5, cornerRadius: stepFloat/2, color: .white)
            progressBarFront.frame = progressBarBack.frame
            addSubview(progressBarFront)
            views.append(progressBarFront)
        }

        if duration > 0 {
            views.forEach { view in
                view.fadeIn(delay: delay, duration: duration)
            }
        }
    }
}
