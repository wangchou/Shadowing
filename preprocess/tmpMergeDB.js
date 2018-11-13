var MeCab = require('mecab-async')
const fs = require('fs');
const sqlite3 = require('sqlite3').verbose();
const { execSync } = require('child_process');

let inSamanthaDbName = "inf_sentences_1113_samantha.sqlite"
let inKyokoDbName = "inf_sentences_1113_kyoko.sqlite"
let outDbName = "inf_sentences_1113_merged.sqlite"
let tableName = "sentences"
var outDb
try {
  execSync(`rm ./${outDbName}`)
} catch (e) {}

var idToAlex = {}
var idToAlexScore = {}
var idToSamantha = {}
var idToSamanthaScore = {}
async function runAll() {
  var samanthaRows = await getSamanthaSaid()
  var kyokoRows = await getKyokoSaid()
  samanthaRows.forEach(row => {
    idToAlex[`${row.id}`] = row.alex
    idToAlexScore[`${row.id}`] = row.alex_score
    idToSamantha[`${row.id}`] = row.samantha
    idToSamanthaScore[`${row.id}`] = row.samantha_score
  })
  console.log("samantha", samanthaRows.length)
  console.log("kyoko", kyokoRows.length)
  outDb = new sqlite3.Database(`./${outDbName}`);
  outDb.run(`CREATE TABLE ${tableName} (id integer PRIMARY_KEY, ja text NOT NULL, kana_count integer NOT NULL, otoya text, otoya_score integer, kyoko text, kyoko_score integer, en text NOT NULL, syllables_count integer, alex text, alex_score integer, samantha text, samantha_score integer)`, err => {
      if (err) {
        return console.log(err.message);
      }
      insertData(kyokoRows)
  });
}
function insertData(objs) {
  outDb.run("BEGIN;")
  let sql = `INSERT INTO ${tableName} VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`
  var count = 0
  objs.forEach( (obj, i) => {
    let values = [obj.id,
      obj.ja, obj.kana_count,
      obj.otoya, obj.otoya_score, obj.kyoko, obj.kyoko_score,
      obj.en, obj.syllables_count,
      idToAlex[`${obj.id}`], idToAlexScore[`${obj.id}`],
      idToSamantha[`${obj.id}`], idToSamanthaScore[`${obj.id}`],
    ]

    outDb.run(sql, values, function(err) {
      count++
      if (count % 1000 == 0) {
        console.log(`${count} / ${objs.length}`)
      }
      if (err) {
        return console.log(err.message);
      }
    });
  })
  outDb.run("COMMIT;")
}

runAll()

function getSamanthaSaid() {
  return new Promise(function(resolve, reject) {
    let inDb = new sqlite3.Database(`./${inSamanthaDbName}`)
    inDb.all("SELECT * FROM sentences", function(err, rows) {
        inDb.close();
        resolve([...rows])
    });
  })
}
function getKyokoSaid() {
  return new Promise(function(resolve, reject) {
    let inDb = new sqlite3.Database(`./${inKyokoDbName}`)
    inDb.all("SELECT * FROM sentences", function(err, rows) {
        inDb.close();
        resolve([...rows])
    });
  })
}
