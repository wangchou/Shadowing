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
    override func viewDidLoad() {
        super.viewDidLoad()
        sentencesTableView.selectRow(at: [0, 1], animated: false, scrollPosition: UITableViewScrollPosition(rawValue: 0)!)
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
        let cell = UITableViewCell()
        let keys = getSentencesKeys()
        cell.textLabel?.text = keys[indexPath.row]
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let keys = getSentencesKeys()
        context.dataSetKey = keys[indexPath.row]
    }
}
