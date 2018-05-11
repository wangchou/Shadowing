import Foundation
import Promises
import Alamofire

var kanaCacheDictionary: [String: String] = [:]

fileprivate func getKana(_ kanjiString: String) -> Promise<String> {
    let promise = Promise<String>.pending()
    let parameters: Parameters = ["jpnStr": kanjiString]
    
    if(kanjiString == "") {
        promise.fulfill("")
        return promise
    }
    
    if let kanaStr = kanaCacheDictionary[kanjiString] {
        promise.fulfill(kanaStr)
        return promise
    }
    
    Alamofire.request(
        "http://54.250.149.163/nlp",
        method: .post,
        parameters: parameters
    ).responseJSON { response in
        switch response.result {
        case .success:
            let tokenInfos: [[String]] = response.result.value as! [[String]]
            let kanaStr = tokenInfos.reduce("", { kanaStr, tokenInfo in
                return tokenInfo[1] != "記号" ?
                    kanaStr + tokenInfo.last! :
                    kanaStr
            })
            kanaCacheDictionary[kanjiString] = kanaStr
            promise.fulfill(kanaStr)
        case .failure(_):
            promise.fulfill("")
        }
        
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
        let score = (len - distanceBetween(str1, str2)) * 100 / len
        return score
    }
    
    all([
        getKana(sentence1),
        getKana(sentence2)
    ]).then { result in
        let score = calcScore(result.first!, result.last!)
        postEvent(.scoreCalculated, int: score)
        promise.fulfill(score)
    }.catch { error in
        promise.reject(error)
    }
    
    return promise
}
