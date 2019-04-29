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

class TopicsListPage: UIViewController {
    @IBOutlet weak var sentencesTableView: UITableView!
    @IBOutlet weak var topArea: UIView!
    @IBOutlet weak var topChartView: TopChartView!
    @IBOutlet weak var topBarView: TopBarView!
    @IBOutlet weak var topicButtonAreaView: TopicButtonAreaView!
    @IBOutlet weak var topicFilterBarView: TopicFilterBarView!

    var timelineSubviews: [String: UIView] = [:]
    override func viewDidLoad() {
        super.viewDidLoad()
        topBarView.rightButton.setIconImage(named: "outline_info_black_48pt", isIconOnLeft: false)
        if Locale.current.languageCode == "zh" {
            topBarView.customOnRightButtonClicked = {
                launchVC("InfoPage", self)
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
        context.gameMode = .topicMode
        topBarView.titleLabel.text = I18n.shared.topicPageTitile
        let height = screen.width * 46/48
        topArea.frame.size.height = height + 61
        topChartView.prepareForDailyGoalAppear()
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
            DispatchQueue.main.async {
                self.topChartView.viewWillAppear()
                self.topChartView.animateProgress()
                self.topicFilterBarView.viewWillAppear()
                self.topicButtonAreaView.viewWillAppear()
                if context.dataSetKey == "" {
                    context.dataSetKey = dataSetKeys[0]
                    context.loadLearningSentences()
                }
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sentencesTableView.reloadData()
    }

    @objc func reloadTopicSentences() {
        loadDataSets()
        sentencesTableView.reloadData()

        if !dataSetKeys.contains(context.dataSetKey) {
            context.dataSetKey = dataSetKeys[0]
        }
    }
}

extension TopicsListPage: UITableViewDataSource {
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
        let dataSetTitle = getDataSetTitle(dataSetKey: dataSetKey)

        attrStr.append(rubyAttrStr(
            dataSetTitle,
            fontSize: 16))

        attrStr.append(rubyAttrStr(
            "\n\(dataSetKey)",
            fontSize: 14,
            color: hashtagColor, isWithStroke: false))

        if let level = dataKeyToLevels[dataSetKey] {
            contentCell.levelLabel.text = level.character
            contentCell.levelLabel.textColor = level.color
            contentCell.levelLabel.roundBorder(borderWidth: 1.5, cornerRadius: 20, color: level.color)
            contentCell.levelLabel.backgroundColor = level.color.withAlphaComponent(0.1)

        }
        contentCell.rankTitleLabel.text = i18n.rank
        contentCell.completeTitleLabel.text = i18n.completeness
        contentCell.titleLabel.attributedText = attrStr
        let record = findBestRecord(key: dataSetKey)
        contentCell.strockedProgressText = record?.progress
        contentCell.strockedRankText = record?.rank.rawValue

        return contentCell
    }
}

extension TopicsListPage: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        context.dataSetKey = dataSetKeys[indexPath.row]
        context.loadLearningSentences()
        (rootViewController.current as? UIPageViewController)?.goToNextPage { _ in
            let cell = tableView.dequeueReusableCell(withIdentifier: "SentencesCell", for: indexPath)
            cell.isSelected = false
        }
    }
}

func getDataSetTitle(dataSetKey: String) -> String {
    if let tags = datasetKeyToTags[dataSetKey],
        !tags.isEmpty {
        let tagsWithoutSharp = tags.map { t in return t.replacingOccurrences(of: "#", with: "")}
        let idx = abilities.index(of: tagsWithoutSharp[0]) ?? 0
        let categoryText = i18n.isZh ? tagsWithoutSharp[0] : jaAbilities[idx]
        return "[\(categoryText)] " + tagsWithoutSharp[1...].joined(separator: "、")
    }

    return ""
}

func getDataSetTopic(dataSetKey: String) -> String {
    if let tags = datasetKeyToTags[dataSetKey],
        !tags.isEmpty {
        let tagsWithoutSharp = tags.map { t in return t.replacingOccurrences(of: "#", with: "")}
        return tagsWithoutSharp[0]
    }

    return ""
}
