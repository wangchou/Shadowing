import Cocoa
import Foundation
import Darwin

// get URL to the the documents directory in the sandbox
let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as NSURL

// TODO: Replace full width number to HALF width number for ja
// TODO: Replace full width number to HALF width number for ja
// TODO: Replace full width number to HALF width number for ja
// TODO: Replace full width number to HALF width number for ja
// TODO: Replace full width number to HALF width number for ja
// TODO: Replace full width number to HALF width number for ja
// TODO: Replace full width number to HALF width number for ja
// TODO: Replace full width number to HALF width number for ja
// TODO: Replace full width number to HALF width number for ja
// TODO: Replace full width number to HALF width number for ja

// add a filename
let enFileUrl = documentsUrl.appendingPathComponent("/sentences/en.txt")
let jaFileUrl = documentsUrl.appendingPathComponent("/sentences/ja.txt")
let outFileUrl = documentsUrl.appendingPathComponent("/sentences/out.txt")

extension String {
    func appendLineToURL(fileURL: URL) throws {
         try (self + "\n").appendToURL(fileURL: fileURL)
     }

     func appendToURL(fileURL: URL) throws {
         let data = self.data(using: String.Encoding.utf8)!
         try data.append(fileURL: fileURL)
     }
 }

 extension Data {
     func append(fileURL: URL) throws {
         if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
             defer {
                 fileHandle.closeFile()
             }
             fileHandle.seekToEndOfFile()
             fileHandle.write(self)
         }
         else {
             try write(to: fileURL, options: .atomic)
         }
     }
 }

// https://stackoverflow.com/questions/48376150/how-do-i-run-shell-command-in-swift
func exec(_ path: String, _ args: String...) -> String {
    let task = Process()
    task.launchPath = path
    task.arguments = args

    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe
    task.launch()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)
    task.waitUntilExit()

    return(output!)
}


struct PairSentence {
  var kanaCount: Int
  var ja: String
  var en: String
}

var testLimit = 1000
do {
  let en = try String(contentsOf: enFileUrl!, encoding: .utf8)
  let ja = try String(contentsOf: jaFileUrl!, encoding: .utf8)
  let enSentences = en.split(separator: "\n")
  let jaSentences = ja.split(separator: "\n")
  var pairs = [PairSentence](repeatElement(PairSentence(kanaCount: 0, ja: "", en: ""), count: testLimit+1))//jaSentences.count))
  for i in 0...testLimit {
    pairs[i].en = String(enSentences[i])
    pairs[i].ja = String(jaSentences[i])
  }
  for i in 0...testLimit {
    pairs[i].kanaCount = Int(String(exec("/usr/local/bin/node", "index.mjs", pairs[i].ja).split(separator: "\n")[0]))!
    //print(exec("/usr/local/bin/node", "index.mjs", pairs[i].ja))
  }

  pairs.sort { a, b in
    return a.kanaCount < b.kanaCount
  }

  for i in 0...testLimit {
    print(pairs[i].kanaCount, pairs[i].ja)
    // print(pairs[i].ja)
    // print(pairs[i].en)
  }

  // try! en.write(to: outFileUrl!, atomically: true, encoding: String.Encoding.utf8)
  // try! ja.write(to: outFileUrl!, atomically: true, encoding: String.Encoding.utf8)
} catch {
  /* error handling here */
  print("some error")
}

