var MeCab = require('mecab-async')
const fs = require('fs');
const sqlite3 = require('sqlite3').verbose();
const { execSync } = require('child_process');
var levenshtein = require('levenshtein-edit-distance')

let inDbName = "inf_sentences_1113_merged.sqlite"
let outDbName = "inf_sentences_100points_duolingo.sqlite"
let tableName = "sentences"
let kanaTableName = "kanaInfo"
let syllablesTableName = "syllablesInfo"

try {
  execSync(`rm ./${outDbName}`)
} catch (e) {}

var start = Date.now();

async function runAll() {
  var sentences = await getSentences()

  console.log(sentences.length)
  dumpCounts(sentences)
  let outDb = new sqlite3.Database(`./${outDbName}`);
  outDb.run(`CREATE TABLE ${tableName} (id integer PRIMARY_KEY, kana_count integer NOT NULL, ja text NOT NULL, syllables_count integer NOT NULL, en text NOT NULL)`, err => {
      if (err) {
        return console.log(err.message);
      }
      insertData(sentences)
  });

  outDb.run(`CREATE TABLE ${kanaTableName} (kana_count integer PRIMARY_KEY, ids text NOT NULL, sentence_count interger NOT NULL)`, err => {
      if (err) {
        return console.log(err.message);
      }
      let info = {}
      sentences.forEach((obj, i) => {
        if(obj.otoya_score != 100 || obj.kyoko_score != 100) { return }
        if(!info[obj.kana_count]) {
          info[obj.kana_count] = {
            sentence_count: 0,
            ids: []
          }
        } else {
          info[obj.kana_count].sentence_count += 1
          info[obj.kana_count].ids.push(obj.id)
        }
      })
      insertInfoData(kanaTableName, info)
  });

  outDb.run(`CREATE TABLE ${syllablesTableName} (syllables_count integer PRIMARY_KEY, ids text NOT NULL, sentence_count interger NOT NULL)`, err => {
      if (err) {
        return console.log(err.message);
      }
      let info = {}
      sentences.forEach((obj, i) => {
        if(obj.alex_score != 100 || obj.samantha_score != 100) { return }
        if(!info[obj.syllables_count]) {
          info[obj.syllables_count] = {
            sentence_count: 0,
            ids: []
          }
        } else {
          info[obj.syllables_count].sentence_count += 1
          info[obj.syllables_count].ids.push(obj.id)
        }
      })
      insertInfoData(syllablesTableName, info)
  });

  outDb.close();

  function insertData(objs) {
    let sql = `INSERT INTO ${tableName} VALUES (?, ?, ?, ?, ?)`
    objs.forEach( obj => {
      let values = [obj.id, obj.kana_count, obj.ja, obj.syllables_count, obj.en]
      outDb.run(sql, values, function(err) {
        if (err) {
          return console.log(err.message);
        }
      });
    })
  }

  function insertInfoData(infoTableName, info) {
    let sql = `INSERT INTO ${infoTableName} VALUES (?, ?, ?)`
    Object.keys(info).forEach( c => {
      let values = [c, info[c].ids.join(","), info[c].sentence_count]
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

function getSentences() {
  return new Promise(function(resolve, reject) {
    let inDb = new sqlite3.Database(`./${inDbName}`)
    inDb.all("SELECT id, kana_count, ja, otoya_score, kyoko_score, syllables_count, en, alex_score, samantha_score FROM sentences where (otoya_score=100 and kyoko_score=100) or (alex_score=100 and samantha_score=100) ", function(err, rows) {
        inDb.close();
        resolve([...rows])
    });
  })
}
