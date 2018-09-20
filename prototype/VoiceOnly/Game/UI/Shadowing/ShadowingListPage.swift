//
//  ViewController.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/04/14.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import UIKit

private let context = GameContext.shared
private let engine = SpeechEngine.shared

class ShadowingListPage: UIViewController {
    @IBOutlet weak var sentencesTableView: UITableView!

    @IBOutlet weak var timeline: TimelineView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var characterView: CharacterView!

    var timelineSubviews: [String: UIView] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        engine.start()
        addSentences()
        loadGameHistory()
        loadGameSetting()
        loadUserSaidSentencesAndScore()

        let height = screen.width * 120/320
        topView.frame.size.height = height
        timeline.frame.size.width = height * 5/3
        timeline.frame.size.height = height
        characterView.frame.size.width = height - 10
        characterView.frame.size.height = height - 10
    }

    @objc func injected() {
        #if DEBUG
        viewWillAppear(false)
        #endif
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCharacterProfile()
        sentencesTableView.reloadData()
        timeline.viewWillAppear()
        characterView.viewWillAppear()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addGradientSeparatorLine()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func addGradientSeparatorLine() {
        let lightRGBs = [myRed, myOrange, myGreen, myBlue].map { $0.cgColor }
        let layer = CAGradientLayer()
        layer.frame = topView.frame
        layer.frame.origin.y = topView.frame.height - 1.5
        layer.frame.size.height = 1.5
        layer.frame.size.width = screen.size.width
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1.0, y: 0)
        layer.colors = lightRGBs
        topView.layer.insertSublayer(layer, at: 0)
    }
}

extension ShadowingListPage: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allSentences.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SentencesCell", for: indexPath)
        guard let contentCell = cell as? ContentCell else { print("convert content cell error"); return cell }

        let dataSetKey = allSentencesKeys[indexPath.row]

        contentCell.titleLabel.attributedText = rubyAttrStr(dataSetKey, fontSize: 16)
        let record = findBestRecord(key: dataSetKey)
        contentCell.strockedProgressText = record?.progress
        contentCell.strockedRankText = record?.rank.rawValue

        return contentCell
    }
}

extension ShadowingListPage: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        context.dataSetKey = allSentencesKeys[indexPath.row]
        context.loadLearningSentences(isShuffle: false)
        launchStoryboard(self, "GameContentDetailPage")
    }
}
