//
//  ReportView.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 6/7/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

private let context = GameContext.shared

class GameReportBoxView: UIView, ReloadableView, GridLayout {
    let gridCount = 44
    let axis: GridAxis = .horizontal
    let spacing: CGFloat = 0

    func viewWillAppear() {
        removeAllSubviews()
        backgroundColor = UIColor.black.withAlphaComponent(0.6)

        renderTopTitle()
        renderMiddleRecord()
        renderBottomCharacter()
    }

    func renderTopTitle() {
        guard let record = context.gameRecord else { return }
        roundBorder(cornerRadius: 15, color: myLightText)
        addText(2, 1, 6, record.dataSetKey, color: myLightText, strokeColor: .black)
    }

    func renderMiddleRecord() {
        guard let record = context.gameRecord else { return }

        let y = 7
        addText(2, y, 2, "達成率")
        let progress = getAttrText([
            ( record.progress.padWidthTo(4), .white, getFontSize(h: 12)),
            ( "%", .lightGray, getFontSize(h: 4))
            ])
        addAttrText(2, y, 12, progress)

        addText(26, y, 2, "Rank")
        addText(26, y, 12, record.rank.rawValue.padWidthTo(3), color: record.rank.color)

        addText(2, y+11, 3, "正解 \(record.perfectCount) | すごい \(record.greatCount) | いいね \(record.goodCount) | ミス \(record.missedCount)")
    }

    func renderBottomCharacter() {
        let rect = UIView()
        layout(2, 23, 40, 1, rect)
        rect.backgroundColor = .lightGray
        rect.frame.size.height = step/4
        self.addSubview(rect)

        let characterView = CharacterView()
        layout(2, 25, 19, 19, characterView)
        addReloadableSubview(characterView)

        // data part
        characterView.viewWillAppear()
    }

    func addRoundRect(_ x: Int, _ y: Int, _ w: Int, _ h: Int,
                      color: UIColor, radius: CGFloat? = nil, backgroundColor: UIColor? = nil) {
        addRoundRect(x: x, y: y, w: w, h: h, borderColor: color, radius: radius, backgroundColor: backgroundColor)
    }

    func addText(_ x: Int, _ y: Int, _ h: Int, _ text: String, color: UIColor = .white, strokeColor: UIColor = .black) {
        let fontSize = getFontSize(h: h)
        let font = MyFont.bold(ofSize: fontSize)
        addAttrText( x, y, h,
                     getText(text, color: color, strokeWidth: -1.5, strokeColor: strokeColor, font: font)
        )
    }

    func addAttrText(_ x: Int, _ y: Int, _ h: Int, _ attrText: NSAttributedString) {
        addAttrText(x: x, y: y, w: gridCount - x, h: h, text: attrText)
    }

    func getFontSize(h: Int) -> CGFloat {
        return h.c * step * 0.7
    }
}

class GameReportView: UIView, ReloadableView, GridLayout {
    let gridCount = 48
    let axis: GridAxis = .horizontal
    let spacing: CGFloat = 0

    func viewWillAppear() {
        removeAllSubviews()
        backgroundColor = UIColor.black.withAlphaComponent(0.6)
        frame = CGRect(x: 0, y: 0, width: screen.width, height: screen.width * 1.3)

        let reportBox = GameReportBoxView()
        layout(2, 4, 44, 46, reportBox)
        addReloadableSubview(reportBox)

        addBackButton()
    }

    func addBackButton() {
        let backButton = UIButton()
        backButton.setTitle("戻  る", for: .normal)
        backButton.backgroundColor = .red
        backButton.titleLabel?.font = MyFont.regular(ofSize: step * 4)
        backButton.titleLabel?.textColor = myLightText
        backButton.roundBorder(borderWidth: 3, cornerRadius: 15, color: UIColor.white.withAlphaComponent(0.5))

        backButton.addTapGestureRecognizer {
            if let vc = UIApplication.getPresentedViewController() {
                launchStoryboard(vc, "ShadowingListPage", animated: true)
            }
        }
        layout(2, 52, 44, 8, backButton)
        addSubview(backButton)
    }
}
