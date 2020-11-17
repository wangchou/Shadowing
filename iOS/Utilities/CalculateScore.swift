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
        "originalStr": originalString
    ]

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
        // swiftlint:disable redundant_discardable_let
        let _ = sessionManager // for retain
        // swiftlint:enable redundant_discardable_let

        switch response.result {
        case .success:
            guard let tokenInfos = response.result.value as? [[String]] else {
                print("parse tokenInfo response error")
                promise.fulfill([])
                return
            }
            promise.fulfill(tokenInfos)

        case .failure(let error):
            print(error)
            if retryCount < 5 {
                getKanaTokenInfos(kanjiString,
                                 originalString: originalString,
                                 retryCount: retryCount + 1)
                    .then { tokenInfo in
                        promise.fulfill(tokenInfo)
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
            let kanaPart = getFixedFuriganaForScore(tokenInfo[0]) ??
                (tokenInfo[tokenInfo.count - shift] == "*" ? tokenInfo[0] : tokenInfo[tokenInfo.count - shift])
            return kanaStr + kanaPart
        }
        promise.fulfill(kanaStr)
    }

    return promise
}

func calculateScore(
    _ originalString: String,
    _ recognizedString: String
) -> Promise<Score> {
    #if os(iOS)
        if gameLang == .en { return calculateScoreEn(originalString, recognizedString) }
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
//        if score != 100 {
//            print("-------")
//            print("1>" ,str1)
//            print("2>", str2, score)
//        }
        return score
    }

    all([
        getKana(originalString, originalString: originalString),
        getKana(recognizedString, originalString: originalString),
    ]).then { kanas in
        let score = calcScore(kanas[0].kataganaToHiragana, kanas[1].kataganaToHiragana)
        #if os(iOS)
            postEvent(.scoreCalculated, score: Score(value: score))
        #endif
        promise.fulfill(Score(value: score))
    }.catch { error in
        promise.reject(error)
    }

    return promise
}

func calculateScoreEn(
    _ sentence1: String,
    _ sentence2: String
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

    let normalizedText1 = normalizeEnglishText(sentence1)
    let normalizedText2 = normalizeEnglishText(sentence2)

    let score = calcScore(normalizedText1, normalizedText2)
    #if os(iOS)
        postEvent(.scoreCalculated, score: Score(value: score))
    #endif
    promise.fulfill(Score(value: score))
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

    tagger.string = text
    let range = NSRange(location: 0, length: text.count)

    tagger.enumerateTags(in: range, scheme: .tokenType, options: []) { tag, tokenRange, _, _ in
        let token = (text as NSString).substring(with: tokenRange)
        if tag?.rawValue == "Punctuation" {
            returnText += ""
        } else {
            returnText += "\(token)"
        }
    }

    return returnText.lowercased()
        .spellOutNumbers()
        .replacingOccurrences(of: "where is", with: "where's")
        .replacingOccurrences(of: " ", with: "")
        .replacingOccurrences(of: "-", with: "")
}
