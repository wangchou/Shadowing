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

let n5Prefix = "N5 口說"
let n4Prefix = "N4 口說"
let n3Prefix = "N3 口說"

func addSentences(sentences: [String], prefix: String, level: Level) {
    let sectionNum = 20
    var index = 0
    var serial = 1
    repeat {
        let subSentences: [(speaker: ChatSpeaker, string: String)] = Array(sentences[index..<index+sectionNum])
            .map { s in
                return (ChatSpeaker.woman1, s)
            }
        let key = "\(prefix) \(serial)"
        allSentences[key] = subSentences
        allSentencesKeys.append(key)
        allLevels[key] = level
        index += sectionNum
        serial += 1
    } while (index + sectionNum) <= sentences.count
}
