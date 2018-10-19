import UIKit

var avgKanaCountDict: [String: Int] = [:]
private let minKanaCounts = [2, 6, 9, 12, 18]
private let maxKanaCounts = [8, 12, 18, 24, 36]

func getLevel(avgKanaCount: Int) -> Level {
    if avgKanaCount < maxKanaCounts[0] { return Level.lv0 }
    if avgKanaCount < maxKanaCounts[1] { return Level.lv1 }
    if avgKanaCount < maxKanaCounts[2] { return Level.lv2 }
    if avgKanaCount < maxKanaCounts[3] { return Level.lv3 }
    return Level.lv4
}

enum Level: Int, Codable {
    case lv0=0, lv1=1, lv2=2, lv3=3, lv4=4
    var color: UIColor {
        return getLevelColor(level: self)
    }

    var minKanaCount: Int {
        return minKanaCounts[self.rawValue]
    }

    var maxKanaCount: Int {
        return maxKanaCounts[self.rawValue]
    }

    var dataSetKey: String {
        return "Level DataSet Key \(self.rawValue)"
    }

    var title: String {
        let titles = ["入門", "初級", "中級", "上級", "超難問"]
        return titles[self.rawValue]
    }

    var character: String {
        let characters = ["入", "初", "中", "上", "超"]
        return characters[self.rawValue]
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
    allSentencesKeys = []
    shadowingSentences
        .filter { sentences in return !sentences.isEmpty }
        .filter { sentences in
            guard topicFilterFlag[titleForAll] != true else { return true }
            let key = sentences[0]
            guard let topic = datasetKeyToTags[key]?[0].split(separator: "#")[0].s,
                  let flag = topicFilterFlag[topic]      else { return false }

            return flag
        }
        .forEach { sentences in
            let subSentences: [(speaker: ChatSpeaker, string: String)] = sentences
                .map { s in
                    return (ChatSpeaker.hattori, s)
            }
            let key = "\(subSentences[0].string)"
            allSentences[key] = subSentences
            allSentencesKeys.append(key)

            let avgKanaCount = subSentences
                .map { pair -> Int in
                    return topicSentencesInfos[pair.string]?.kanaCount ?? 0
                }
                .reduce(0, { sum, count in
                    return sum + count
                })/subSentences.count
            avgKanaCountDict[key] = avgKanaCount
            allLevels[key] = getLevel(avgKanaCount: avgKanaCount)
        }
    allSentencesKeys.sort { key1, key2 in
        if let count1 = avgKanaCountDict[key1],
           let count2 = avgKanaCountDict[key2] {
            return count1 < count2
        }
        return true
    }

    //allSentencesKeys.forEach {k in print(k, avgKanaCountDict[k]!)}
}
