import Alamofire
import Foundation
import Promises

#if os(iOS)
    let serverURL = "http://52.194.172.67/nlp"
#else
    var kanaTokenInfosCacheDictionary: [String: [[String]]] = [:]
    let serverURL = "http://127.0.0.1:3000/nlp"
#endif

func getKanaTokenInfos(_ kanjiString: String, originalString: String = "", retryCount: Int = 0) -> Promise<[[String]]> {
    let promise = Promise<[[String]]>.pending()
    let parameters: Parameters = [
        "jpnStr": kanjiString,
        "originalStr": originalString,
    ]

    #if os(iOS)
        // try to lookup from local db
        if kanaTokenInfosCacheDictionary[kanjiString] == nil {
            loadTokenInfos(ja: kanjiString)
        }
    #endif

    if let tokenInfos = kanaTokenInfosCacheDictionary[kanjiString] {
        promise.fulfill(tokenInfos)
        return promise
    }

    // timeout and retry for solving 4G network packet lost
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = TimeInterval(retryCount * 2 + 2)
    let sessionManager = Alamofire.SessionManager(configuration: configuration)

    sessionManager.request(
        serverURL,
        method: .post,
        parameters: parameters
    ).responseJSON { response in
        // https://stackoverflow.com/questions/39984880/alamofire-result-failure-error-domain-nsurlerrordomain-code-999-cancelled
        _ = sessionManager // for retain

        switch response.result {
        case .success:
            guard let tokenInfos = response.result.value as? [[String]] else {
                print("parse tokenInfo response error")
                promise.fulfill([])
                return
            }
            kanaTokenInfosCacheDictionary[kanjiString] = tokenInfos
            promise.fulfill(tokenInfos)

        case let .failure(error):
            print(error)
            if retryCount < 5 {
                getKanaTokenInfos(kanjiString,
                                  originalString: originalString,
                                  retryCount: retryCount + 1)
                    .then { tokenInfos in
                        kanaTokenInfosCacheDictionary[kanjiString] = tokenInfos
                        promise.fulfill(tokenInfos)
                    }
            } else {
                promise.fulfill([])
            }
        }
    }
    return promise
}

func getKana(_ kanjiString: String, isFuri: Bool = false, originalString: String?) -> Promise<String> {
    let promise = Promise<String>.pending()

    if kanjiString.isEmpty {
        promise.fulfill("")
        return promise
    }

    getKanaTokenInfos(kanjiString, originalString: originalString ?? kanjiString).then { tokenInfos in
        let kanaStr = tokenInfos.reduce("") { kanaStr, tokenInfo in
            if tokenInfo.count < 2 || tokenInfo[1] == "記号" {
                return kanaStr
            }
            let shift = isFuri ? 2 : 1
            let kanaPart = (tokenInfo[tokenInfo.count - shift] == "*" ? tokenInfo[0] : tokenInfo[tokenInfo.count - shift])
            return kanaStr + kanaPart
        }
        promise.fulfill(kanaStr)
    }

    return promise
}

func calculateScore(
    _ originalString: String,
    _ candidates: [String]
) -> Promise<Score> {
    //let recognizedString = candidates[0]
    //userSaidSentences[originalString] = recognizedString
    #if os(iOS)
        if gameLang == .en { return calculateScoreEn(originalString, candidates) }
    #endif

    let promise = Promise<Score>.pending()

    func calcScore(_ str1: String, _ str2: String) -> Int {
        let trimedS1 = str1.replacingOccurrences(of: " ", with: "")
        let trimedS2 = str2.replacingOccurrences(of: " ", with: "")
        let len = max(trimedS1.count, trimedS2.count)
        guard len > 0 else {
            #if os(iOS)
                showMessage(I18n.shared.cannotReachServer)
            #endif
            print("zero len error on calcScore", str1, str2)
            return 0
        }
        let score = (len - distanceBetween(trimedS1, trimedS2)) * 100 / len
        return score
    }

    var kanaPromises: [Promise<String>] = [getKana(originalString, originalString: originalString)]
    kanaPromises.append(contentsOf: candidates.map { getKana($0, originalString: originalString) })

    all(kanaPromises).then { kanas in
        var bestScore = 0
        var bestCandidate = ""
        let oriKana = kanas[0]
        let candidateKanas = kanas[1 ..< kanas.count]
        candidateKanas.enumerated().forEach { index, candidateKana in
            let score = calcScore(oriKana.kataganaToHiragana, candidateKana.kataganaToHiragana)
            print("score:", score, candidates[index])
            if score > bestScore {
                bestScore = score
                bestCandidate = candidates[index]
            }
        }

        userSaidSentences[originalString] = bestCandidate
        #if os(iOS)
            postEvent(.scoreCalculated, score: Score(value: bestScore))
        #endif
        promise.fulfill(Score(value: bestScore))
    }.catch { error in
        promise.reject(error)
    }

    return promise
}

var nCache: [String: String] = [:]

func calculateScoreEn(
    _ originalStr: String,
    _ candidates: [String]
) -> Promise<Score> {
    let promise = Promise<Score>.pending()
    func calcScore(_ str1: String, _ str2: String) -> Int {
        let len = max(str1.count, str2.count)
        guard len > 0 else {
            #if os(iOS)
                showMessage(I18n.shared.cannotReachServer)
            #endif
            print("zero len error on calcScore", str1, str2)
            return 0
        }
        let score = (len - distanceBetween(str1, str2)) * 100 / len
        return score
    }

    let normalizedOriginal = nCache[originalStr] ?? normalizeEnglishText(originalStr)

    var highestScore = 0
    var bestCandidate = ""
    candidates.forEach {
        let normalizedText = nCache[$0] ?? normalizeEnglishText($0)
        let score = calcScore(normalizedOriginal, normalizedText)
        print("score:", score, $0)
        if score > highestScore {
            highestScore = score
            bestCandidate = $0
        }
    }

    userSaidSentences[originalStr] = bestCandidate

    #if os(iOS)
        postEvent(.scoreCalculated, score: Score(value: highestScore))
    #endif
    promise.fulfill(Score(value: highestScore))
    return promise
}

// TODO:
// digits mapping => "20" : "twenty"
// contraction => "it's : "it is"
// special abbreviations => "mt." : "Mount", "m: meters"

func normalizeEnglishText(_ text: String) -> String {
    let tagger = NSLinguisticTagger(
        tagSchemes: NSLinguisticTagger.availableTagSchemes(forLanguage: "en"),
        options: 0
    )

    var returnText = ""

    let newText = text
        .lowercased()
        .spellOutNumbers()
        .replacingOccurrences(of: " ", with: "")
        .replacingOccurrences(of: "-", with: "")
        .replacingOccurrences(of: "favourite", with: "favorite")
        .replacingOccurrences(of: "colour", with: "color")
        .replacingOccurrences(of: "colourful", with: "colorful")
        .replacingOccurrences(of: "flavour", with: "flavor")
        .replacingOccurrences(of: "humour", with: "humor")
        .replacingOccurrences(of: "labour", with: "labor")
        .replacingOccurrences(of: "viour", with: "vior")
        .replacingOccurrences(of: "neighbour", with: "neighbor")
        .replacingOccurrences(of: "licence", with: "license")
        .replacingOccurrences(of: "defence", with: "defense")
        .replacingOccurrences(of: "offence", with: "offense")
        .replacingOccurrences(of: "analyse", with: "analyze")
        .replacingOccurrences(of: "emphasise", with: "emphasize")
        .replacingOccurrences(of: "moustache", with: "mustache")
        .replacingOccurrences(of: "centre", with: "center")
        .replacingOccurrences(of: "favour", with: "favor")
        .replacingOccurrences(of: "lled", with: "led")
        .replacingOccurrences(of: "recognise", with: "recognize")
        .replacingOccurrences(of: "fibre", with: "fiber")
        .replacingOccurrences(of: "litre", with: "liter")
        .replacingOccurrences(of: "ere's", with: "ereis")
        .replacingOccurrences(of: "hat's", with: "hatis")
        .replacingOccurrences(of: "i'm", with: "iam")
        .replacingOccurrences(of: "'ll", with: "will")
        .replacingOccurrences(of: "you're", with: "youare")
        .replacingOccurrences(of: "he's", with: "heis")
        .replacingOccurrences(of: "desert", with: "dessert")

    tagger.string = newText
    let range = NSRange(location: 0, length: newText.count)
    tagger.enumerateTags(in: range, scheme: .tokenType, options: []) { tag, tokenRange, _, _ in
        let token = (newText as NSString).substring(with: tokenRange)
        if tag?.rawValue == "Punctuation" {
            returnText += ""
        } else {
            returnText += "\(token)"
        }
    }
    nCache[text] = returnText

    return returnText
}
