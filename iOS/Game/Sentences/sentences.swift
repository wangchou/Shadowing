import UIKit

enum Level: Int, Codable {
    case lv0=0, lv1=1, lv2=2, lv3=3, lv4=4
    var color: UIColor {
        return getLevelColor(level: self)
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
    shadowingSentences.forEach { sentences in
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
