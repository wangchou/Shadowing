import UIKit

var dataSetKeys: [String] = []
var dataSets: [String: [String]] = [:]
var dataKeyToLevels: [String: Level] = [:]

func getTagPoints(isWithoutLast: Bool = false) -> [String: Int] {
    var tagPoints = [String: Int]()
    var maxGamePoints = [String: Int]()
    var games = GameContext.shared.gameHistory

    if isWithoutLast {
        games.removeLast()
    }

    games.forEach { g in
        if let score = maxGamePoints[g.dataSetKey],
            score.f > g.p {
            return
        }
        maxGamePoints[g.dataSetKey] = g.p.i
    }

    for (datasetKey, points) in maxGamePoints {
        if let tags = datasetKeyToTags[datasetKey] {
            tags.forEach { tag in
                tagPoints[tag] = (tagPoints[tag] ?? 0) + points
            }
        }
    }
    return tagPoints
}

func getTagMaxPoints() -> [String: Int] {
    var tagMaxPoints: [String: Int] = [:]
    datasetKeyToTags.keys.forEach { key in
        if let tags = datasetKeyToTags[key],
            !tags.isEmpty {
            let tag = tags[0]
            tagMaxPoints[tag] = (tagMaxPoints[tag] ?? 0) + 100
        }
    }
    return tagMaxPoints
}

func buildDataSets() {
    dataSetKeys = []
    rawDataSets
        .filter { sentences in !sentences.isEmpty }
        .filter(isDataSetTopicOn)
        .forEach { sentences in
            let key = sentences[0]
            let vocabularyPlus = datasetKeyToTags[key]?[0].range(of: "單字") != nil ? 8 : 0
            dataSets[key] = sentences
            dataSetKeys.append(key)

            let avgKanaCount: Float = sentences
                .map { s -> Int in
                    (topicSentencesInfos[s]?.kanaCount ?? 0) + vocabularyPlus
                }
                .reduce(0) { sum, count in
                    sum + count
                }.f / sentences.count.f
            avgKanaCountDict[key] = avgKanaCount
            dataKeyToLevels[key] = Level(avgSyllablesCount: avgKanaCount)
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
    let key = sentences[0]
    guard let topic = datasetKeyToTags[key]?[0].split(separator: "#")[0].s,
        let isOn = isTopicOn[topic] else { return false }

    return isOn
}
