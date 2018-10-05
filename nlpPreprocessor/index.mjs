var MeCab = require('mecab-async')

//http://ilog4.blogspot.com/2015/09/javascript-convert-full-width-and-half.html
String.prototype.toHalfWidth = function() {
    return this.replace(/[Ａ-Ｚａ-ｚ０-９]/g, function(s) {return String.fromCharCode(s.charCodeAt(0) - 0xFEE0)});
};
String.prototype.toFullWidth = function() {
    return this.replace(/[A-Za-z0-9]/g, function(s) {return String.fromCharCode(s.charCodeAt(0) + 0xFEE0);});
};

const mecab = new MeCab()
  mecab.command = 'mecab -d /usr/local/lib/mecab/dic/mecab-ipadic-neologd/ -E "<改行>\\n"';
mecab.parse(process.argv[2].toHalfWidth(), function(err, result) {
  console.log(result)
  var isContainOtherLang = false
  var count = 0
  result.forEach(arr => {
    var targetStr
    var kanaCount
    if(arr[arr.length-1] == '*') { // for substring is katakana already
      targetStr = arr[0]
      kanaCount = getKanaCount(targetStr)
      if(kanaCount == 0) { // for substring includes english
        isContainOtherLang = true
      }
    } else {
      targetStr = arr[arr.length - 1]
      kanaCount = getKanaCount(targetStr)
    }
    count += kanaCount
    console.log(arr[arr.length - 1], kanaCount)
  })
  if(isContainOtherLang) {
    console.log(-1)
  } else {
    console.log(count)
  }
});

function getKanaCount(str) {
  var count = 0;
  str.split("").forEach(c => {
    if(c >= "ア" && c <= "ヿ" ||
       c >= "あ" && c <= "ゟ") {
      count++
    }
  })
  return count
}
