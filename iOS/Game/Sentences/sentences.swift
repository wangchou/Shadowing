import UIKit

var avgKanaCountDict: [String: Int] = [:]
private let minKanaCounts = [2, 7, 9, 12, 15, 17, 19, 22, 27]
private let maxKanaCounts = [6, 8, 11, 14, 16, 18, 21, 26, 36]
private let colors = [myRed, myRed, myOrange, myOrange, myGreen, myGreen, myBlue, myBlue, .purple]
private let titles = ["入門一", "入門二", "初級一", "初級二", "中級一", "中級二", "上級一", "上級二", "超難問"]
let allLevels: [Level] = [.lv0, .lv1, .lv2, .lv3, .lv4, .lv5, .lv6, .lv7, .lv8]

func getLevel(avgKanaCount: Int) -> Level {
    for i in 0..<allLevels.count where avgKanaCount <= maxKanaCounts[i] {
        return allLevels[i]
    }
    return Level.lv8
}

enum Level: Int, Codable {
    case lv0=0, lv1=1, lv2=2, lv3=3, lv4=4, lv5=5, lv6=6, lv7=7, lv8=8
    var color: UIColor {
        return colors[self.rawValue]
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
        return titles[self.rawValue]
    }

    var character: String {
        return title.prefix(1).s
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

var allSentences: [String: [String]] = [:]
var allSentencesKeys: [String] = []
var dataKeyToLevels: [String: Level] = [:]

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
            let key = sentences[0]
            allSentences[key] = sentences
            allSentencesKeys.append(key)

            let avgKanaCount = sentences
                .map { s -> Int in
                    return topicSentencesInfos[s]?.kanaCount ?? 0
                }
                .reduce(0, { sum, count in
                    return sum + count
                })/sentences.count
            avgKanaCountDict[key] = avgKanaCount
            dataKeyToLevels[key] = getLevel(avgKanaCount: avgKanaCount)
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
