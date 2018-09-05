//
//  ViewController.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/04/14.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import UIKit

private let context = GameContext.shared

class MainViewController: UIViewController {
    @IBOutlet weak var sentencesTableView: UITableView!

    @IBOutlet weak var timeline: TimelineView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var characterView: CharacterView!

    var timelineSubviews: [String: UIView] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        let tmpKey = "ChatDemo"
        allSentences[tmpKey] = chatDemo
        allSentencesKeys.append(tmpKey)
        allLevels[tmpKey] = Level.n5b

//        tmpKey = "ChatDemo2"
//        allSentences[tmpKey] = chatDemo2
//        allSentencesKeys.append(tmpKey)
//        allLevels[tmpKey] = Level.n4b

        addSentences(sentences: n5, prefix: n5Prefix, level: Level.n5a)
        addSentences(sentences: n4, prefix: n4Prefix, level: Level.n4a)
        addSentences(sentences: n3, prefix: n3Prefix, level: Level.n3a)

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
        loadGameHistory()
        loadGameCharacter()
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
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1.0, y: 0)
        layer.colors = lightRGBs
        topView.layer.insertSublayer(layer, at: 0)
    }
}

extension MainViewController: UITableViewDataSource {
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

        contentCell.titleLabel.text = dataSetKey
        let record = findBestRecord(key: dataSetKey)
        contentCell.strockedProgressText = record?.progress
        contentCell.strockedRankText = record?.rank.rawValue

        return contentCell
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        context.dataSetKey = allSentencesKeys[indexPath.row]
        context.loadLearningSentences(isShuffle: false)
        launchStoryboard(self, "GameContentDetailPage")
    }
}
