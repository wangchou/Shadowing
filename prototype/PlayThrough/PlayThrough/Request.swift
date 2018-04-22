// copied from https://qiita.com/xshirade/items/086be09376b9cbbe7bc8

import Foundation

class Request {
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
func getKana(
    _ kanjiString: String,
    onKanaGenerated: @escaping (String, Error?) -> Void
    ) {
    //setStartTime("request start")
    let request: Request = Request()
    let url: URL = URL(string: "http://54.250.149.163/nlp")!
    let body: NSMutableDictionary = ["jpnStr": kanjiString]
    do {
        try request.post(url: url, body: body, completionHandler: { data, response, error in
            do {
                //printDuration("got response")
                let tokenInfos: [[String]] = try JSONSerialization.jsonObject(with: data!, options:[]) as! [[String]]
                let kanaStr = tokenInfos.reduce("", { kanaStr, tokenInfo in
                    kanaStr + tokenInfo.last!
                })
                onKanaGenerated(kanaStr, nil)
            } catch {
                onKanaGenerated("", error)
                print("Error with parse json: \(error)")
            }
            
            if error != nil {
                onKanaGenerated("", error)
                print("post request error")
            }
        })
    } catch {
        onKanaGenerated("", error)
        print("error occurs in getKana")
    }
}

func getSpeechScore(
    _ targetSentence: String,
    _ saidSentence: String,
    onScore: @escaping (Int) -> Void
) {
    var targetKana = ""
    var saidKana = ""
    var isTargetKanaReady = false
    var isSaidKanaReady = false
    func calcScore(_ str1: String, _ str2: String) -> Int {
        let len = max(str1.count, str2.count)
        return (len - distanceBetween(str1, str2)) * 100 / len
    }
    getKana(targetSentence) { str, error in
        targetKana = str
        isTargetKanaReady = true
        if isSaidKanaReady {
            onScore(calcScore(targetKana, saidKana))
        }
    }
    getKana(saidSentence) { str, error in
        saidKana = str
        isSaidKanaReady = true
        if isTargetKanaReady {
            onScore(calcScore(targetKana, saidKana))
        }
    }
}






















