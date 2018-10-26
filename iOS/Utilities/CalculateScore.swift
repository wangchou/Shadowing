import Foundation
import Promises
import Alamofire

#if os(iOS)
#else
var kanaTokenInfosCacheDictionary: [String: [[String]]] = [:]
#endif

func getKanaTokenInfos(_ kanjiString: String) -> Promise<[[String]]> {
    let promise = Promise<[[String]]>.pending()
    let parameters: Parameters = ["jpnStr": kanjiString]

    if let tokenInfos = kanaTokenInfosCacheDictionary[kanjiString] {
        promise.fulfill(tokenInfos)
        return promise
    }

    Alamofire.request(
        "http://52.194.172.67/nlp",
        method: .post,
        parameters: parameters
        ).responseJSON { response in
            switch response.result {
            case .success:
                guard let tokenInfos = response.result.value as? [[String]] else {
                    print("parse tokenInfo response error")
                    promise.fulfill([])
                    return
                }
                kanaTokenInfosCacheDictionary[kanjiString] = tokenInfos
                promise.fulfill(tokenInfos)

            case .failure:
                promise.fulfill([])
            }
    }
    return promise
}

func getKana(_ kanjiString: String) -> Promise<String> {
    let promise = Promise<String>.pending()

    if kanjiString.isEmpty {
        promise.fulfill("")
        return promise
    }

    getKanaTokenInfos(kanjiString).then { tokenInfos in
        let kanaStr = tokenInfos.reduce("", { kanaStr, tokenInfo in
            if tokenInfo.count < 2 || tokenInfo[1] == "記号" {
                return kanaStr
            }
            let kanaPart = findKanaFix(tokenInfo[0]) ?? tokenInfo[tokenInfo.count - 1]
            return kanaStr + kanaPart
        })
        promise.fulfill(kanaStr)
    }

    return promise
}

func calculateScore(
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

    all([
        getKana(sentence1),
        getKana(sentence2)
    ]).then { kanas in
        let score = calcScore(kanas[0], kanas[1])
        #if os(iOS)
        postEvent(.scoreCalculated, score: Score(value: score))
        #endif
        promise.fulfill(Score(value: score))
    }.catch { error in
        promise.reject(error)
    }

    return promise
}
