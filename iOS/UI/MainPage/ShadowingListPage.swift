//
//  ViewController.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/04/14.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import UIKit
import Charts
import Foundation

private let context = GameContext.shared
private let engine = SpeechEngine.shared

extension Notification.Name {
    static let topicFlagChanged = Notification.Name("topicFlagChanged")
}

class ShadowingListPage: UIViewController {
    @IBOutlet weak var sentencesTableView: UITableView!
    @IBOutlet weak var timeline: TimelineView!
    @IBOutlet weak var topArea: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topBarView: TopBarView!
    @IBOutlet weak var topicFilterBarView: TopicFilterBarView!
    @IBOutlet weak var abilityChart: AbilityChart!

    var timelineSubviews: [String: UIView] = [:]
    override func viewDidLoad() {
        super.viewDidLoad()
        topBarView.rightButton.setIconImage(named: "outline_info_black_48pt", isIconOnLeft: false)
        if Locale.current.languageCode == "zh" {
            topBarView.customOnRightButtonClicked = {
                launchStoryboard(self, "InfoPage")
            }
        } else {
            topBarView.rightButton.isHidden = true
        }
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadTopicSentences),
                                               name: .topicFlagChanged,
                                               object: nil)
    }

    @objc func injected() {
        #if DEBUG
        viewWillAppear(false)
        #endif
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let height = screen.width * 150/320
        topArea.frame.size.height = height + 50
        timeline.frame.size.height = height * 140 / 150
        timeline.frame.size.width = height * 21 / 20

        sentencesTableView.reloadData()
        timeline.viewWillAppear()
        abilityChart.render()
        if context.dataSetKey == "" {
            context.dataSetKey = dataSetKeys[0]
            context.loadLearningSentences()
        }
        topicFilterBarView.viewWillAppear()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addGradientSeparatorLine()
    }

    func addGradientSeparatorLine() {
        let lightRGBs = [
            Level.lv0.color,
            Level.lv2.color,
            Level.lv4.color,
            Level.lv6.color,
            Level.lv8.color
        ].map { $0.cgColor }
        let layer = CAGradientLayer()
        layer.frame = topView.frame
        layer.frame.origin.y = screen.width * 150/320 - 1.5
        layer.frame.size.height = 1.5
        layer.frame.size.width = screen.size.width
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1.0, y: 0)
        layer.colors = lightRGBs
        topView.layer.insertSublayer(layer, at: 0)
    }

    @objc func reloadTopicSentences() {
        loadDataSets()
        sentencesTableView.reloadData()
    }
}

extension ShadowingListPage: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSetKeys.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SentencesCell", for: indexPath)
        guard let contentCell = cell as? ContentCell else { print("convert content cell error"); return cell }

        let dataSetKey = dataSetKeys[indexPath.row]
        let attrStr = NSMutableAttributedString()
        attrStr.append(rubyAttrStr(dataSetKey, fontSize: 16))
        if let tags = datasetKeyToTags[dataSetKey],
           !tags.isEmpty {
            attrStr.append(
                rubyAttrStr("\n"+tags.joined(separator: " "), fontSize: 14, color: hashtagColor, isWithStroke: false)
            )
        }

        if let level = dataKeyToLevels[dataSetKey] {
            contentCell.levelLabel.text = level.character
            contentCell.levelLabel.textColor = level.color
            contentCell.levelLabel.roundBorder(borderWidth: 1.5, cornerRadius: 20, color: level.color)
            contentCell.levelLabel.backgroundColor = level.color.withAlphaComponent(0.1)
        }
        contentCell.titleLabel.attributedText = attrStr
        let record = findBestRecord(key: dataSetKey)
        contentCell.strockedProgressText = record?.progress
        contentCell.strockedRankText = record?.rank.rawValue

        return contentCell
    }
}

extension ShadowingListPage: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        context.dataSetKey = dataSetKeys[indexPath.row]
        context.loadLearningSentences()
        (rootViewController.current as? UIPageViewController)?.goToNextPage()
    }
}