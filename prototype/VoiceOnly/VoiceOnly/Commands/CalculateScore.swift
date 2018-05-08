import Foundation
import Promises

// MARK: - Private
// copied from https://qiita.com/xshirade/items/086be09376b9cbbe7bc8
fileprivate class Request {
    let session: URLSession = URLSession.shared
    
    // POST METHOD
    func post(url: URL, body: NSMutableDictionary, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) throws {
        var request: URLRequest = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions.prettyPrinted)
        
        session.dataTask(with: request, completionHandler: completionHandler).resume()
    }
    
}

// 台灣大哥大 ４G -> AWS Tokyo server の round-trip time on Sunday morning
// ~= 200ms (process time in server < 10ms)
// freaking slow... T.T
fileprivate func getKana(_ kanjiString: String) -> Promise<String> {
    let promise = Promise<String>.pending()
    let request: Request = Request()
    let url: URL = URL(string: "http://54.250.149.163/nlp")!
    let body: NSMutableDictionary = ["jpnStr": kanjiString]
    
    if(kanjiString == "") {
        promise.fulfill("")
        return promise
    }
    
    do {
        try request.post(url: url, body: body) { data, response, error in
            if error != nil {
                promise.reject(error!)
                print("post request error")
            }
            
            do {
                let tokenInfos: [[String]] = try JSONSerialization.jsonObject(with: data!, options:[]) as! [[String]]
                let kanaStr = tokenInfos.reduce("", { kanaStr, tokenInfo in
                    //print(tokenInfo)
                    if tokenInfo[1] != "記号" {
                        return kanaStr + tokenInfo.last!
                    }
                    return kanaStr
                    
                })
                promise.fulfill(kanaStr)
            } catch {
                //promise.reject(error)
                //print("MyError with parse json:\n \(error)")
            }
        }
    } catch {
        promise.reject(error)
        print("error occurs in getKana")
    }
    
    return promise
}

func calculateScore(
    _ targetSentence: String,
    _ saidSentence: String
) -> Promise<Int> {
    let promise = Promise<Int>.pending()
    var targetKana = ""
    var saidKana = ""
    var isTargetKanaReady = false
    var isSaidKanaReady = false
    var score = -1
    
    func calcScore(_ str1: String, _ str2: String) -> Int {
        let len = max(str1.count, str2.count)
        let score = (len - distanceBetween(str1, str2)) * 100 / len
        return score
    }
    
    all([
        getKana(targetSentence),
        getKana(saidSentence)
    ]).then { result in
        let score = calcScore(result.first!, result.last!)
        postEvent(.scoreCalculated, score)
        promise.fulfill(score)
    }.catch { error in
        promise.reject(error)
    }
    
    return promise
}
