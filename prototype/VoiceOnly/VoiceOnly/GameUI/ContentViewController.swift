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
    //let game = SentencesTestGame.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        addSentences(sentences: n5, prefix: n5Prefix)
        addSentences(sentences: n4, prefix: n4Prefix)
        addSentences(sentences: n3, prefix: n3Prefix)
        //game.play()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadGameHistory()
        sentencesTableView.reloadData()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "SentencesCell", for: indexPath) as! ContentCell

        let dataSetKey = allSentencesKeys[indexPath.row]

        cell.title.text = dataSetKey
        cell.strockedProgressText = context.gameHistory[dataSetKey]?.progress
        cell.strockedRankText = context.gameHistory[dataSetKey]?.rank

        return cell
    }
}

extension ContentViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        context.dataSetKey = allSentencesKeys[indexPath.row]
        context.loadLearningSentences(isShuffle: false)
        launchStoryboard(self, "GameContentDetailPage")
    }
}
