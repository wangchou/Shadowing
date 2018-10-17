var MeCab = require('mecab-async')
const fs = require('fs');
const sqlite3 = require('sqlite3').verbose();
const { execSync } = require('child_process');
var levenshtein = require('levenshtein-edit-distance')

let inDbName = "with_siriSaid_inf_sentences.sqlite"
let outDbName = "inf_sentences_100points.sqlite"
let tableName = "sentences"
let infoTableName = "kanaInfo"

try {
  execSync(`rm ./${outDbName}`)
} catch (e) {}

var start = Date.now();

async function runAll() {
  var sentences = await getSentences()

  let sLimit = sentences.length
  for(i = 0; i < sLimit; i++) {
    let batchSize = Math.min(2000, sLimit - i)

    // speed up batch
    var millis = Date.now() - start;
    console.log(`${i}/${sLimit}, ${Math.floor(millis/1000)}s`);

    let sentenceScorePromises = []
    for(let j = i; j < i+batchSize; j++) {
      sentenceScorePromises.push(getScore(sentences[j].ja, sentences[j].siriSaid))
    }
    let sentenceScores = await Promise.all(sentenceScorePromises)
    sentenceScores.forEach((s, k) => {
      sentences[i+k].score = s
    })
    i += (batchSize - 1)
  }

  sentences = sentences.filter(o => (o.score == 1))
  console.log(sentences.length)
  dumpCounts(sentences)
  let outDb = new sqlite3.Database(`./${outDbName}`);
  outDb.run(`CREATE TABLE ${tableName} (id integer PRIMARY_KEY, kana_count integer NOT NULL, ja text NOT NULL)`, err => {
      if (err) {
        return console.log(err.message);
      }
      insertData(sentences)
  });

  outDb.run(`CREATE TABLE ${infoTableName} (kana_count integer PRIMARY_KEY, start_id integer NOT NULL, sentence_count interger NOT NULL)`, err => {
      if (err) {
        return console.log(err.message);
      }
      let kanaInfo = {}
      sentences.forEach((obj, i) => {
        if(!kanaInfo[obj.kana_count]) {
          kanaInfo[obj.kana_count] = {}
          kanaInfo[obj.kana_count].sentence_count = 1
          kanaInfo[obj.kana_count].start_id = i
        } else {
          kanaInfo[obj.kana_count].sentence_count += 1
        }
      })
      insertKanaInfoData(kanaInfo)
  });

  outDb.close();

  function insertData(objs) {
    let sql = `INSERT INTO ${tableName} VALUES (?, ?, ?)`
    objs.forEach( (obj, i) => {
      let values = [i, obj.kana_count, obj.ja]
      outDb.run(sql, values, function(err) {
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
      outDb.run(sql, values, function(err) {
        if (err) {
          return console.log(err.message);
        }
      });
    })
  }
}

runAll()
//async function test() {
//  let score = await getScore("ものすごくお腹がすいている。", "ものすごくお腹が空いている")
//  console.log(score)
//}
//test()

function dumpCounts(arr) {
  console.log("-------------")
  var counts = {};

  for (var i = 0; i < arr.length; i++) {
    var num = arr[i].kana_count;
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

async function getScore(s1, s2) {
  let kana1 = await getYomi(s1)
  let kana2 = await getYomi(s2)
  let dist = levenshtein(kana1, kana2)
  let len = Math.max(kana1.length, kana2.length)
  let score = (len - dist)/parseFloat(len)
  // console.log(kana1)
  // console.log(kana2)
  // console.log(score)
  return score
}

function getYomi(sentence) {
  const mecab = new MeCab()
  mecab.command = 'mecab -d /usr/local/lib/mecab/dic/mecab-ipadic-neologd/ -E "<改行>\\n"';
  return new Promise(function(resolve, reject) {
    mecab.parse(sentence, function(err, result) {
      resolve(getKanaFromResult(result))
    });
  });
}

function getSentences() {
  return new Promise(function(resolve, reject) {
    let inDb = new sqlite3.Database(`./${inDbName}`)
    inDb.all("SELECT kana_count, ja, siriSaid FROM sentences where siriSaid<>'' ", function(err, rows) {
        inDb.close();
        resolve([...rows])
    });
  })
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

function getKanaFromResult(result) {
      var isContainOtherLang = false
      var count = 0
      var kanaStr = ""
      if(result == undefined) {
        return ""
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
        kanaStr += targetStr
        //console.log(arr[arr.length - 1], kanaCount)
      })
      if(isContainOtherLang) {
        return ""
      } else {
        return kanaStr.split("").filter(c => isKana(c)).join("")
      }
}


function getKanaCount(str) {
  var count = 0;
  str.split("").forEach(c => {
    if(isKana(c)) {
      count++
    }
  })
  return count
}

function isKana(c) {
  if(c >= "ア" && c <= "ヿ" ||
     c >= "あ" && c <= "ゟ" ||
     c >= "0" && c <="9"
  ){
    return true
  }
  return false
}

function isNoTomAndMary(s) {
  return s.indexOf("Tom") == -1 && s.indexOf("Mary") == -1
}
function getRandomJPName() {
  let familyNames = [
    "佐藤",
    "鈴木",
    "高橋",
    "田中",
    "渡边",
    "伊藤",
    "山本",
    "中村",
    "小林",
    "斋藤",
    "加藤",
    "吉田",
    "山田",
    "佐々木",
    "山口",
    "松本",
    "井上",
    "木村",
    "林",
    "清水"
  ]
  return familyNames[getRandomInt(familyNames.length-1)]　+　"さん"

}

function getRandomInt(max) {
  return Math.floor(Math.random() * Math.floor(max));
}
