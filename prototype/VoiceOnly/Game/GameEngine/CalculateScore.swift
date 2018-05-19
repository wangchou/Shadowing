import Foundation
import Promises
import Alamofire

var kanaTokenInfosCacheDictionary: [String: [[String]]] = [:]

func getKanaTokenInfos(_ kanjiString: String) -> Promise<[[String]]> {
    let promise = Promise<[[String]]>.pending()
    let parameters: Parameters = ["jpnStr": kanjiString]

    if let tokenInfos = kanaTokenInfosCacheDictionary[kanjiString] {
        promise.fulfill(tokenInfos)
        return promise
    }

    Alamofire.request(
        "http://54.250.149.163/nlp",
        method: .post,
        parameters: parameters
        ).responseJSON { response in
            switch response.result {
            case .success:
                guard let tokenInfos = response.result.value as? [[String]] else {
                    print("parse tokenInfo response error")
                    promise.fulfill([[]])
                    return
                }
                kanaTokenInfosCacheDictionary[kanjiString] = tokenInfos
                promise.fulfill(tokenInfos)

            case .failure:
                promise.fulfill([[]])
            }
    }
    return promise
}

func getKana(_ kanjiString: String) -> Promise<String> {
    let promise = Promise<String>.pending()

    if kanjiString == "" {
        promise.fulfill("")
        return promise
    }

    getKanaTokenInfos(kanjiString).then { tokenInfos in
        let kanaStr = tokenInfos.reduce("", { kanaStr, tokenInfo in
            guard let kanaPart = tokenInfo.last,
                  tokenInfo[1] != "記号" else { return kanaStr }
            return kanaStr + kanaPart
        })
        promise.fulfill(kanaStr)
    }

    return promise
}

func calculateScore(
    _ sentence1: String,
    _ sentence2: String
) -> Promise<Int> {
    let promise = Promise<Int>.pending()

    func calcScore(_ str1: String, _ str2: String) -> Int {
        let len = max(str1.count, str2.count)
        guard len > 0 else { print("zero len error on calcScore"); return 0 }
        let score = (len - distanceBetween(str1, str2)) * 100 / len
        return score
    }

    all([
        getKana(sentence1),
        getKana(sentence2)
    ]).then { result in
        guard let kana1 = result.first, let kana2 = result.last else { print("get both kana fail"); return }
        let score = calcScore(kana1, kana2)
        postEvent(.scoreCalculated, int: score)
        promise.fulfill(score)
    }.catch { error in
        promise.reject(error)
    }

    return promise
}
