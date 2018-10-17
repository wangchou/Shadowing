const sqlite3 = require('sqlite3').verbose();
const { execSync } = require('child_process');

let dbName = "db.sqlite"
let tableName = "sentences"

try {
  execSync(`rm ./${dbName}`)
} catch (e) {}

let pairs = [
  { id: 3, ja: "春", en: "abs", count: 55},
  { id: 4, ja: "春4", en: "absff", count: 3},
  { id: 5, ja: "春4", en: "absff", count: 3}
]
let db = new sqlite3.Database(`./${dbName}`);
db.run(`CREATE TABLE ${tableName} (id integer PRIMARY_KEY, kana_count integer NOT NULL, ja text NOT NULL, en text NOT NULL)`, err => {
    if (err) {
      return console.log(err.message);
    }
    insertData(pairs)
});

function insertData(pairs) {
  let sql = `INSERT INTO ${tableName} VALUES ` + pairs.map(obj => `(${obj.id}, ${obj.count}, "${obj.ja}", "${obj.en}")`).join(',')
  db.run(sql, function(err) {
    if (err) {
      return console.log(err.message);
    }
    // get the last insert id
    console.log(`${pairs.length} rows has been inserted`);
  });
}

db.close();
