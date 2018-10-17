const fs = require('fs');

var folderUrl = "/Users/kinda/projects/Shadowing/iOS/Game/Sentences/"
var speechSentences = fs.readFileSync(`${folderUrl}/speech.swift`,'utf8').split('\n')

//http://ilog4.blogspot.com/2015/09/javascript-convert-full-width-and-half.html
String.prototype.toHalfWidth = function() {
    return this.replace(/[Ａ-Ｚａ-ｚ０-９]/g, function(s) {return String.fromCharCode(s.charCodeAt(0) - 0xFEE0)});
};
String.prototype.toFullWidth = function() {
    return this.replace(/[A-Za-z0-9]/g, function(s) {return String.fromCharCode(s.charCodeAt(0) + 0xFEE0);});
};

folderUrl = "/Users/kinda/Documents/sentences"
var enSentences = fs.readFileSync(`${folderUrl}/en.txt`,'utf8').split('\n').map(s => s.replace(/\"/g, `\"\"`))
var jaSentences = fs.readFileSync(`${folderUrl}/ja.txt`,'utf8')
                    .toHalfWidth()
                    .replace(/\./g,"。")
                    .replace(/\!/g,"！")
                    .replace(/\?/g,"？")
                    .replace(/,/g,"、")
                    .split('\n')


speechSentences.forEach(s => {
  let idx = jaSentences.indexOf(s)
  if(idx == -1) {
    console.log(s)
  } else {
    console.log(`${s}|${enSentences[idx]}`)
  }
})
