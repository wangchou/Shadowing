import express from 'express'
import bodyParser from 'body-parser'
import MeCab from 'mecab-async'
import morgan from 'morgan'
import fs from 'fs'
import path from 'path'
import mcache from 'memory-cache'

import os from 'os'
const isMac = os.type() === 'Darwin'

const mecab = new MeCab()
if(isMac){
  mecab.command = 'mecab -d /usr/local/lib/mecab/dic/mecab-ipadic-neologd/ -E "<改行>\\n"';
} else {
  mecab.command = 'mecab -d /usr/lib/mecab/dic/mecab-ipadic-neologd -E "<改行>\\n"';
}

const app = express()

var __dirname
if(isMac) {
  __dirname = './log'
} else {
  __dirname = '/home/ubuntu/Shadowing/prototype/nlpService/log'
}

// https://medium.com/the-node-js-collection/simple-server-side-cache-for-express-js-with-node-js-45ff296ca0f0
var cache = (duration) => {
  return (req, res, next) => {
    if (!req.body || !req.body.jpnStr || req.body.jpnStr.length > 50) return res.sendStatus(400)
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

app.post('/nlp', cache(864000), (req, res) => {
  if (!req.body || !req.body.jpnStr) return res.sendStatus(400)
  console.log(req.body.jpnStr)
  mecab.parse(req.body.jpnStr, function(err, result) {
    if (err) {
      return res.status(500).send({ error: 'Something failed!' })
    }
    res.json(result);
  });
})

// use reverse proxy or
// iptables -t nat -I PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 3000
var server = app.listen(3000)
server.keepAliveTimeout = 20000
