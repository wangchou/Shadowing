//
//  MedalSummaryPage.swift
//  今話したい
//
//  Created by Wangchou Lu on 4/19/31 H.
//  Copyright © 31 Heisei Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

class MedalSummaryPage: UIViewController {
    static let id = "MedalSummaryPage"
    var medalSummaryPageView: MedalSummaryPageView? {
        return (view as? MedalSummaryPageView)
    }

    override func loadView() {
        view = MedalSummaryPageView()
        view.frame = CGRect(x: 0, y: 0, width: screen.width, height: screen.height)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        medalSummaryPageView?.viewWillAppear()
    }
}

class MedalSummaryPageView: UIView, GridLayout, ReloadableView {
    var gridCount: Int = 48
    var axis: GridAxis = .horizontal
    var spacing: CGFloat = 0

    func viewWillAppear() {
        print(frame)
        backgroundColor = myRed
        addText(x: 3, y: 3, h: 10, text: "MedalSummaryPageView") { _ in
            print("added")
        }
    }
}
