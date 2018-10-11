var MeCab = require('mecab-async')
const fs = require('fs');
const sqlite3 = require('sqlite3').verbose();
const { execSync } = require('child_process');

let dbName = "inf_sentences.sqlite"
let tableName = "sentences"
let infoTableName = "kanaInfo"

try {
  execSync(`rm ./${dbName}`)
} catch (e) {}

//http://ilog4.blogspot.com/2015/09/javascript-convert-full-width-and-half.html
String.prototype.toHalfWidth = function() {
    return this.replace(/[Ａ-Ｚａ-ｚ０-９]/g, function(s) {return String.fromCharCode(s.charCodeAt(0) - 0xFEE0)});
};
String.prototype.toFullWidth = function() {
    return this.replace(/[A-Za-z0-9]/g, function(s) {return String.fromCharCode(s.charCodeAt(0) + 0xFEE0);});
};


var folderUrl = "/Users/kinda/Documents/sentences"
var enSentences = fs.readFileSync(`${folderUrl}/en.txt`,'utf8').split('\n').map(s => s.replace(/\"/g, `\"\"`))
var jaSentences = fs.readFileSync(`${folderUrl}/ja.txt`,'utf8')
                    .toHalfWidth()
                    .replace(/\./g,"。")
                    .replace(/\!/g,"！")
                    .replace(/\?/g,"？")
                    .replace(/,/g,"、")
                    .split('\n')

var sLimit = jaSentences.length
var start = Date.now();
var pairs = []
async function runAll() {
  for(let i = 0; i < sLimit; i++) {

    if(i + 1000 < sLimit) {
      var millis = Date.now() - start;
      console.log(`${i}/${jaSentences.length}, ${Math.floor(millis/1000)}s`);

      let ps = []
      for(let j = i; j < i+1000; j++) {
        ps.push(getSentenceKanaCount(jaSentences[j]))
      }
      let cs = await Promise.all(ps)
      cs.forEach((c, k) => {
        pairs.push({
          "en": enSentences[i+k],
          "ja": jaSentences[i+k],
          "c": c
        })
      })
      i += 999
      continue;
    }

    let c = await getSentenceKanaCount(jaSentences[i])
    pairs.push({
      "en": enSentences[i],
      "ja": jaSentences[i],
      "c": c
    })
  }
  var sortedPairs = pairs.sort((a,b) => (a.c - b.c))
  dumpCounts(sortedPairs)

  let db = new sqlite3.Database(`./${dbName}`);
  db.run(`CREATE TABLE ${tableName} (id integer PRIMARY_KEY, kana_count integer NOT NULL, ja text NOT NULL, en text NOT NULL)`, err => {
      if (err) {
        return console.log(err.message);
      }
      insertData(sortedPairs)
  });

  db.run(`CREATE TABLE ${infoTableName} (kana_count integer PRIMARY_KEY, start_id integer NOT NULL, sentence_count interger NOT NULL)`, err => {
      if (err) {
        return console.log(err.message);
      }
      let kanaInfo = {}
      sortedPairs.forEach((obj, i) => {
        if(!kanaInfo[obj.c]) {
          kanaInfo[obj.c] = {}
          kanaInfo[obj.c].sentence_count = 1
          kanaInfo[obj.c].start_id = i
        } else {
          kanaInfo[obj.c].sentence_count += 1
        }
      })
      insertKanaInfoData(kanaInfo)
  });

  db.close();

  function insertData(pairs) {
    let sql = `INSERT INTO ${tableName} VALUES (?, ?, ?, ?)`
    pairs.forEach( (obj, i) => {
      let values = [i, obj.c, obj.ja, obj.en]
      db.run(sql, values, function(err) {
        if (err) {
          return console.log(err.message);
        }
      });
    })
  }
  function insertKanaInfoData(kanaInfo) {
    let sql = `INSERT INTO ${infoTableName} VALUES (?, ?, ?)`
    Object.keys(kanaInfo).forEach( c => {
      let values = [c, kanaInfo[c].start_id, kanaInfo[c].sentence_count]
      db.run(sql, values, function(err) {
        if (err) {
          return console.log(err.message);
        }
      });
    })
  }
}

runAll()


function dumpCounts(arr) {
  console.log("-------------")
  var counts = {};

  for (var i = 0; i < arr.length; i++) {
    var num = arr[i].c;
    counts[num] = counts[num] ? counts[num] + 1 : 1;
  }

  for(var i = 1; i<=100; i+=5) {
    var j
    var rangeCounts = 0
    for(j = i; j < i+5; j++) {
      if(counts[j]) {
        rangeCounts += counts[j]
      }
    }
    console.log(`${i}~${j-1}`, rangeCounts, (parseFloat(rangeCounts * 100)/arr.length).toFixed(2)+"%")
  }
}

function getSentenceKanaCount(sentence) {
  const mecab = new MeCab()
  mecab.command = 'mecab -d /usr/local/lib/mecab/dic/mecab-ipadic-neologd/ -E "<改行>\\n"';
  return new Promise(function(resolve, reject) {
    mecab.parse(sentence, function(err, result) {
      resolve(getKanaCountFromResult(result))
    });
  });
}

function getKanaCountFromResult(result) {
      // console.log(result)
      var isContainOtherLang = false
      var count = 0
      if(result == undefined) {
        return -100
        return
      }
      result.forEach(arr => {
        var targetStr
        var kanaCount
        if(arr[arr.length-1] == '*') { // for substring is katakana already
          targetStr = arr[0]
          kanaCount = getKanaCount(targetStr)
          if(kanaCount == 0) { // for japanese substring includes english
            isContainOtherLang = true
          }
        } else {
          targetStr = arr[arr.length - 1]
          kanaCount = getKanaCount(targetStr)
        }
        count += kanaCount
        //console.log(arr[arr.length - 1], kanaCount)
      })
      if(isContainOtherLang) {
        return -1
      } else {
        return count
      }
}


function getKanaCount(str) {
  var count = 0;
  str.split("").forEach(c => {
    if(c >= "ア" && c <= "ヿ" ||
       c >= "あ" && c <= "ゟ" ||
       c >= "0" && c <="9"
    ) {
      count++
    }
  })
  return count
}
