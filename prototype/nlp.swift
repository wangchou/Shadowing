// execute this file by "xcrun swift ./nlp.swift"
import Foundation

// random string from internet
var text = "やってきました夏合宿。かなり荷物は減らしたけど、それでも大きめのキャリーバッグにぎゅうぎゅうに押し込めてきた。我ながらいったい何を持ってきたのだろう。宿泊先は保養所というより完全にホテルで、部屋もツインルームだった。これ、合宿というよりただの旅行だよね？同室になったのは違うクラスの野々瀬ののせ真帆まほちゃん。ほとんどしゃべったこともないけど、仲良くなれるかな？なんだか緊張しているみたいだけど。部屋でしばらく休んだあとは、ホテルの庭でバーベキュー。"

let tagger = NSLinguisticTagger(
  tagSchemes: NSLinguisticTagger.availableTagSchemes(forLanguage: "ja"),
  options: 0
)

tagger.string = text
let range = NSMakeRange(0, text.count)
let options: NSLinguisticTagger.Options = [.omitWhitespace]

var colorIndex = 2
tagger.enumerateTags(in: range, scheme: .tokenType, options: []) { (tag, tokenRange, sentenceRange, stop) in
  let token = (text as NSString).substring(with: tokenRange)
  if(tag?.rawValue == "Punctuation") {
    print("\u{001B}[0;31m\(token)")
  } else {
    print("\u{001B}[0;3\(colorIndex)m\(token)", terminator:"")
    colorIndex = ((colorIndex - 1) % 6) + 2
  }
}

func getSentences(_ text: String) -> [String] {
  let tagger = NSLinguisticTagger(
    tagSchemes: NSLinguisticTagger.availableTagSchemes(forLanguage: "ja"),
    options: 0
  )

  var sentences: [String] = []
  var curSentences = ""

  tagger.string = text
  let range = NSMakeRange(0, text.count)
  let options: NSLinguisticTagger.Options = [.omitWhitespace]

  tagger.enumerateTags(in: range, scheme: .tokenType, options: []) { (tag, tokenRange, sentenceRange, stop) in
    let token = (text as NSString).substring(with: tokenRange)
    if(tag?.rawValue == "Punctuation") {
      curSentences += token
      sentences.append(curSentences)
      curSentences = ""
    } else {
      curSentences += token
    }
  }

  return sentences
}

print(getSentences(text))
