// execute this file by "xcrun swift ./nlpEn.swift"
import Foundation
// random string from internet
var text = "If one only wished to be happy, this could be easily accomplished; but we wish to be happier than other people, and this is always difficult, for we believe others to be happier than they are."

let orthography = NSOrthography.defaultOrthography(forLanguage: "en")
NSLinguisticTagger.enumerateTags(
  for: text,
  range: NSRange(location: 0, length: text.count),
  unit: .word,
  scheme: .lexicalClass,
  orthography: orthography) { (tag, tokenRange, _) in
  let token = (text as NSString).substring(with: tokenRange)
  if tag == .verb {
    print("\u{001B}[0;31m\(token)", terminator: "")
  } else if tag == .punctuation {
    print("\u{001B}[0;32m\(token)")
  } else {
    print("\u{001B}[0;37m\(token)", terminator: "")
  }
}


// remove punctuation, put space between words and calculate edit distance as score => Done.
