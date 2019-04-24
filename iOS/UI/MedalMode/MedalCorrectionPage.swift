//
//  MedalSummaryPage.swift
//  今話したい
//
//  Created by Wangchou Lu on 4/24/31 H.
//  Copyright © 31 Heisei Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

private let context = GameContext.shared

class MedalCorrectionPage: UIViewController {
    static let id = "MedalCorrectionPage"
    var medalCorrectionPageView: MedalCorrectionPageView? {
        return (view as? MedalCorrectionPageView)
    }

    override func loadView() {
        view = MedalCorrectionPageView()
        view.frame = CGRect(x: 0, y: 0, width: screen.width, height: screen.height)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        medalCorrectionPageView?.viewWillAppear()
    }
}

class MedalCorrectionPageView: UIView, GridLayout, ReloadableView {
    var topView: UIView!
    var tableView: UITableView!
    var sentences: [String] = []

    func viewWillAppear() {
        removeAllSubviews()
        addTopView()
        addBottomTable()
        addCloseButton()
    }

    private func addTopView() {
        topView = UIView()
        topView.backgroundColor = rgb(60, 60, 60)
        layout(0, 0, gridCount, 10, topView)
        addSubview(topView)
    }

    private func addBottomTable() {
        tableView = UITableView()
        // https://stackoverflow.com/questions/25541786/custom-uitableviewcell-from-nib-in-swift
        tableView.register(UINib(nibName: "SentencesTableCell", bundle: nil),
                           forCellReuseIdentifier: SentencesTableCell.id)

        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.separatorColor = rgb(200, 200, 200)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.frame = CGRect(x: 0,
                                 y: topView.frame.y + topView.frame.height,
                                 width: screen.width,
                                 height: screen.height -
                                    topView.frame.height -
                                    step * 7)
        addSubview(tableView)
    }

    private func addCloseButton() {
        let button = UIButton()
        button.frame = CGRect(x: 0,
                              y: tableView.frame.origin.y + tableView.frame.height,
                              width: screen.width,
                              height: step * 7)
        button.backgroundColor = rgb(180, 180, 180)
        button.setTitle("x", for: .normal)
        button.titleLabel?.font = MyFont.regular(ofSize: step * 4)
        button.setTitleColor(.black, for: .normal)
        button.addTapGestureRecognizer {
            dismissVC()
        }
        addSubview(button)

        let line = addRect(x: 0, y: 0, w: 48, h: 1, color: .darkGray)
        line.frame.size.height = 0.5
        line.frame.origin.y = button.frame.y
    }

}

extension MedalCorrectionPageView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return context.sentences.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SentencesTableCell.id) as! SentencesTableCell
        cell.selectionStyle = .none

        let sentence = context.sentences[indexPath.row]
        cell.update(sentence: sentence,
                    isShowTranslate: context.gameSetting.isShowTranslationInPractice)

        return cell
    }
}

extension MedalCorrectionPageView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
}
