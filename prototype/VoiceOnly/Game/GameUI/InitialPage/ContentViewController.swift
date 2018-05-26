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
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var characterView: CharacterView!

    var timelineSubviews: [String: UIView] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        addSentences(sentences: n5, prefix: n5Prefix, level: Level.n5)
        addSentences(sentences: n4, prefix: n4Prefix, level: Level.n4)
        addSentences(sentences: n3, prefix: n3Prefix, level: Level.n3)
        let height = screen.width * 120/320
        topView.frame.size.height = height
        timeline.frame.size.width = height * 5/3
        timeline.frame.size.height = height
        characterView.frame.size.width = height
        characterView.frame.size.height = height
    }

    @objc func characterViewTapped() {
        print("characterViewTapped")
        launchStoryboard(self, "DataPageViewOverlay", isOverCurrent: true, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadGameHistory()
        sentencesTableView.reloadData()
        timeline.viewWillAppear()
        characterView.viewWillAppear()
        let characterViewTap = UITapGestureRecognizer(target: self, action: #selector(self.characterViewTapped))
        characterView.addGestureRecognizer(characterViewTap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

func getLevelColor(level: Level) -> UIColor {
    switch level {
    case .n5:
        return myRed
    case .n4:
        return myOrange
    case .n3:
        return myGreen
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
        let record = findBestRecord(key: dataSetKey)
        contentCell.strockedProgressText = record?.progress
        contentCell.strockedRankText = record?.rank

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
