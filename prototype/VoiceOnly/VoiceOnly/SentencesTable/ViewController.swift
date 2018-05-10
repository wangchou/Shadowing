//
//  ViewController.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/04/14.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import UIKit

fileprivate let context = GameContext.shared

class ViewController: UIViewController {
    @IBOutlet weak var sentencesTableView: UITableView!
    let transparentView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transparentView.backgroundColor = .clear
        sentencesTableView.selectRow(at: [0, 0], animated: false, scrollPosition: UITableViewScrollPosition(rawValue: 0)!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sentencesTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

func getSentencesKeys() -> [String] {
    return Array(allSentences.keys).sorted().reversed()
}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allSentences.capacity
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SentencesCell", for: indexPath) as! SentencesTableViewCell
        
        let keys = getSentencesKeys()
        let dataSetKey = keys[indexPath.row]
        cell.title.text = dataSetKey
        cell.strockedProgressText = context.gameHistory[dataSetKey]?.progress
        cell.strockedRankText = context.gameHistory[dataSetKey]?.rank
        cell.selectedBackgroundView = transparentView
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let keys = getSentencesKeys()
        context.dataSetKey = keys[indexPath.row]
        
        let v = tableView.cellForRow(at: indexPath)!.contentView
        v.alpha = 1
        v.backgroundColor = myBlue
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let v = tableView.cellForRow(at: indexPath)!.contentView
        v.alpha = 0.5
        v.backgroundColor = .white
    }
}
