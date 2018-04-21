import express from 'express'
import bodyParser from 'body-parser'
import MeCab from 'mecab-async'
import morgan from 'morgan'
import fs from 'fs'
import path from 'path'

const mecab = new MeCab()
mecab.command = 'mecab -d /usr/local/lib/mecab/dic/mecab-ipadic-neologd/ -E "<改行>\\n"';
const app = express()

const __dirname = './log'
var accessLogStream = fs.createWriteStream(path.join(__dirname, 'access.log'), {flags: 'a'})
app.use(morgan((tokens, req, res) => {
    return [
      tokens.method(req, res),
      decodeURIComponent(tokens.url(req, res)),
      tokens.status(req, res),
      tokens.res(req, res, 'content-length'), '-',
      tokens['response-time'](req, res), 'ms'
    ].join(' ')
}, {stream: accessLogStream}))

app.use(bodyParser.urlencoded({ extended: true }))
app.use(bodyParser.json())

app.get('/nlp', (req, res) => {
  if (!req.query || !req.query.jpnStr) return res.sendStatus(400)
  console.log(req.query.jpnStr)
  mecab.parse(req.query.jpnStr, function(err, result) {
    if (err) {
      return res.status(500).send({ error: 'Something failed!' })
    }
    res.json(result);
  });
})

app.listen(80)
