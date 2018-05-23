//
//  ViewController.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/04/14.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import UIKit

private let context = GameContext.shared

class ContentViewController: UIViewController {
    @IBOutlet weak var sentencesTableView: UITableView!

    @IBOutlet weak var timeline: TimelineView!

    var timelineSubviews: [String: UIView] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        addSentences(sentences: n5, prefix: n5Prefix, level: Level.n5)
        addSentences(sentences: n4, prefix: n4Prefix, level: Level.n4)
        addSentences(sentences: n3, prefix: n3Prefix, level: Level.n3)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadGameHistory()
        sentencesTableView.reloadData()
        timeline.viewWillAppear()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ContentViewController: UITableViewDataSource {
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

        contentCell.title.text = dataSetKey
        contentCell.strockedProgressText = context.gameHistory[dataSetKey]?.progress
        contentCell.strockedRankText = context.gameHistory[dataSetKey]?.rank

        var color: UIColor = .white

        if let level = allLevels[dataSetKey] {
            switch level {
            case .n5:
                color = myRed
            case .n4:
                color = myOrange
            case .n3:
                color = myGreen
            }
        }

        contentCell.backgroundColor = color.withAlphaComponent(0.1)

        return contentCell
    }
}

extension ContentViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        context.dataSetKey = allSentencesKeys[indexPath.row]
        context.loadLearningSentences(isShuffle: false)
        launchStoryboard(self, "GameContentDetailPage")
    }
}
