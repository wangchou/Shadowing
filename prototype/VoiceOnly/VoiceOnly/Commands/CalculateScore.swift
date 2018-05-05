import Foundation

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
// ~= 400 ~ 600ms (process time in server < 10ms)
// freaking slow... T.T
fileprivate func getKana(
    _ kanjiString: String,
    completionHandler: @escaping (String, Error?) -> Void
    ) {
    let request: Request = Request()
    let url: URL = URL(string: "http://54.250.149.163/nlp")!
    let body: NSMutableDictionary = ["jpnStr": kanjiString]
    do {
        try request.post(url: url, body: body) { data, response, error in
            do {
                let tokenInfos: [[String]] = try JSONSerialization.jsonObject(with: data!, options:[]) as! [[String]]
                let kanaStr = tokenInfos.reduce("", { kanaStr, tokenInfo in
                    //print(tokenInfo)
                    if tokenInfo[1] != "記号" {
                        return kanaStr + tokenInfo.last!
                    }
                    return kanaStr
                    
                })
                completionHandler(kanaStr, nil)
            } catch {
                completionHandler("", error)
                print("Error with parse json: \(error)")
            }
            
            if error != nil {
                completionHandler("", error)
                print("post request error")
            }
        }
    } catch {
        completionHandler("", error)
        print("error occurs in getKana")
    }
}

// MARK: - Public
// Warning: use it in myQueue.async {} block
// It blocks current thead !!!
// Do not call it on main thread
func calculateScore(
    _ targetSentence: String,
    _ saidSentence: String
) -> Int {
    cmdGroup.wait()
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
    
    cmdGroup.enter()
    getKana(targetSentence) { str, error in
        targetKana = str
        isTargetKanaReady = true
        if isSaidKanaReady {
            score = calcScore(targetKana, saidKana)
        }
        cmdGroup.leave()
    }
    cmdGroup.enter()
    getKana(saidSentence) { str, error in
        saidKana = str
        isSaidKanaReady = true
        if isTargetKanaReady {
            score = calcScore(targetKana, saidKana)
        }
        cmdGroup.leave()
    }
    cmdGroup.wait()
    postEvent(.scoreCalculated, score)
    return score
}
