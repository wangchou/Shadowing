import express from 'express'
import bodyParser from 'body-parser'
import MeCab from 'mecab-async'
import morgan from 'morgan'
import fs from 'fs'
import path from 'path'
import mcache from 'memory-cache'
import { getFixedTokenInfos, loadNLocal } from './utils.js'

import os from 'os'
const isMac = os.type() === 'Darwin'

const mecab = new MeCab()
if(isMac){
  mecab.command = 'mecab -d /usr/local/lib/mecab/dic/mecab-ipadic-neologd/ -E "<改行>\\n"';
} else {
  mecab.command = 'mecab -d /usr/lib/x86_64-linux-gnu/mecab/dic/mecab-ipadic-neologd -E "<改行>\\n"';
}

const app = express()

var __dirname
if(isMac) {
  __dirname = './log'
} else {
  __dirname = '/home/ubuntu/Shadowing/nlpService/log'
}

var { nLocalFixes, correctKanas } = loadNLocal()

// https://medium.com/the-node-js-collection/simple-server-side-cache-for-express-js-with-node-js-45ff296ca0f0
var cache = (duration) => {
  return (req, res, next) => {
    if (!req.body || !req.body.jpnStr) return res.sendStatus(400)
    let key = req.body.jpnStr
    let cachedBody = mcache.get(key)
    if(cachedBody) {
      res.send(cachedBody)
      return
    } else {
      res.sendResponse = res.send
      res.send = (body) => {
        mcache.put(key, body, duration * 1000)
        res.sendResponse(body)
      }
      next()
    }
  }
}

app.use(morgan('[:date[clf]] :method :url :status :res[content-length] - :response-time ms'))
app.use(bodyParser.urlencoded({ extended: true }))
app.use(bodyParser.json())

app.post('/nlp', cache(864000), (req, res) => {
  if (!req.body || !req.body.jpnStr) return res.sendStatus(400)
  console.log(new Date().toLocaleString(), req.body.jpnStr)
  mecab.parse(req.body.jpnStr, function(err, result) {
    if (err) {
      return res.status(500).send({ error: 'Something failed!' })
    }
    // trimedResult = [[kanji, 詞性, furikana, yomikana]]
    let trimedResult = result.map((arr) => [arr[0], arr[1], arr[arr.length-2], arr[arr.length-1]])
    let originalStr = req.body.originalStr || req.body.jpnStr
    let localFixes = nLocalFixes[originalStr] || []
    res.json(getFixedTokenInfos(trimedResult, localFixes));
  });
})

// use reverse proxy or
// iptables -t nat -I PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 3000
var server = app.listen(3000)
server.keepAliveTimeout = 20000
