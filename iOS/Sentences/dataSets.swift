import UIKit

var dataSetKeys: [String] = []
var dataSets: [String: [String]] = [:]
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

func loadDataSets() {
    dataSetKeys = []
    rawDataSets
        .filter { sentences in return !sentences.isEmpty }
        .filter( isDataSetTopicOn )
        .forEach { sentences in
            let key = sentences[0]
            dataSets[key] = sentences
            dataSetKeys.append(key)

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
    dataSetKeys.sort { key1, key2 in
        if let count1 = avgKanaCountDict[key1],
           let count2 = avgKanaCountDict[key2] {
            return count1 < count2
        }
        return true
    }
}

private func isDataSetTopicOn(sentences: [String]) -> Bool {
    guard isTopicOn[topicForAll] != true else { return true }
    let key = sentences[0]
    guard let topic = datasetKeyToTags[key]?[0].split(separator: "#")[0].s,
          let isOn = isTopicOn[topic]      else { return false }

    return isOn
}
