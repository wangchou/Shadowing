import UIKit

enum Level: Int, Codable {
    case lv0=0, lv1=1, lv2=2, lv3=3, lv4=4
    var color: UIColor {
        return getLevelColor(level: self)
    }

    var minKanaCount: Int {
        let minKanaCounts = [1, 6, 9, 12, 18]
        return minKanaCounts[self.rawValue]
    }

    var maxKanaCount: Int {
        let maxKanaCounts = [8, 12, 18, 24, 36]
        return maxKanaCounts[self.rawValue]
    }

    var dataSetKey: String {
        return "Level DataSet Key \(self.rawValue)"
    }

    var title: String {
        let titles = ["入門", "初級", "中級", "上級", "超難問"]
        return titles[self.rawValue]
    }
}

enum Rank: String, Codable {
    case ss = "SS"
    case s = "S"
    case a = "A"
    case b = "B"
    case c = "C"
    case d = "D"
    case e = "E"
    case f = "F"

    var color: UIColor {
        return getRankColor(rank: self)
    }
}

var allSentences: [String: [(speaker: ChatSpeaker, string: String)]] = [:]
var allSentencesKeys: [String] = []
var allLevels: [String: Level] = [:]

func getTagPoints() -> [String: Int] {
    var tagPoints = [String: Int]()
    var maxGamePoints = [String: Int]()
    let games = GameContext.shared.gameHistory

    games.forEach { g in
        if let score = maxGamePoints[g.dataSetKey],
           score.f > g.p {
            return
        }
        maxGamePoints[g.dataSetKey] = g.p.i
    }
    for (datasetKey, points) in maxGamePoints {
        if let tags = datasetKeyToTags[datasetKey] {
            tags.forEach {tag in
                tagPoints[tag] = (tagPoints[tag] ?? 0) + points
            }
        }
    }
    return tagPoints
}

func addSentences() {
    shadowingSentences
        .filter { sentences in return !sentences.isEmpty }
        .forEach { sentences in
        let subSentences: [(speaker: ChatSpeaker, string: String)] = sentences
            .map { s in
                return (ChatSpeaker.hattori, s)
        }
        let key = "\(subSentences[0].string)"
        allSentences[key] = subSentences
        allSentencesKeys.append(key)
        allLevels[key] = Level.lv0
    }
}
