import UIKit

enum Level: Int, Codable {
    case n5a=0, n5b=1, n5c=2, n4a=3, n4b=4, n4c=5, n3a=6, n3b=7
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

func addSentences() {
    shadowingSentences.forEach { sentences in
        let subSentences: [(speaker: ChatSpeaker, string: String)] = sentences
            .map { s in
                return (ChatSpeaker.man1, s)
        }
        let key = "\(subSentences[0].string)"
        allSentences[key] = subSentences
        allSentencesKeys.append(key)
        allLevels[key] = Level.n5a
    }
}
