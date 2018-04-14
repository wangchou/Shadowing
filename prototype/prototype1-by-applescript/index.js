// 1. use node 9 or above for async
// 2. install tts sound on Mac by
//    System Preference -> Accessibility -> Speech -> 聲 -> Japanese
// 3. make sure the network is connected for Apple Speech Recognition
// Increase the font size for better experience
const osa = require('osa2')
const promptly = require('promptly')
const chalk = require('chalk')
const calcDist = require('js-levenshtein')

const colorLog = (color) => (text) => process.stdout.write(chalk[color](text))
const white = colorLog('white')
const blue = colorLog('blue')
const green = colorLog('green')
const red = colorLog('red')
const gray = colorLog('gray')

const say = osa((text, props) => {
  var app = Application.currentApplication()
  app.includeStandardAdditions = true

  return app.say(text, props)
})

const toggleListen = osa((seconds = 0) => {
  const fnKeyCode = 63
  delay(seconds)
  Application('System Events').keyCode([fnKeyCode, fnKeyCode])
  return delay(0.5)
})

const kyoko = { using: "Kyoko" }
const otoya = { using: "Otoya" }
const meijia = { using: "Mei-Jia" }

const repeatMe = "請跟著唸："
const repeatMeSecond = "再跟著唸："

let max = (x, y) => (x > y) ? x : y
let trim = str => {
  return str.replace(/[！？、。]/g, '')
}

const calScore = (text, speakText) => {
  let trimedText = trim(text)
  let strDist = calcDist(speakText, trimedText)
  let len = max(trimedText.length, speakText.length)
  return Math.trunc(max(len - strDist, 0) * 100 / len)
}

async function learn (item, isFirstTime = true) {
  if(isFirstTime) {
    gray('--------------------------------------------\n')
    white(repeatMe)
    await say(repeatMe, meijia)
  } else {
    white(repeatMeSecond)
  }

  blue(' ' + item.text + '\n')

  // Key Part Start //////////////////////////////////////////////////////////////
  let speakingRate = isFirstTime ? 120 : 90
  let speaker = {
    using: item.gender === 'f' ? "Kyoko" : "Otoya",
    speakingRate
  }
  say(item.text, speaker)
  const delayTimeInSeconds = item.text.length/(speakingRate/60) - 1
  await toggleListen(delayTimeInSeconds)
  const speakText = await promptly.prompt('嗶聲後說：')
  await toggleListen()
  // Key Part End //////////////////////////////////////////////////////////////

  // press the enter after recognition when prototyping
  const score = calScore(item.text, speakText)
  if(score >= 80) {
    let goodWord = score === 100 ? "パーフェクト" : "いいね"
    green(`${score}点: ${goodWord}\n`)
    await say(goodWord, kyoko)
  } else if(isFirstTime) {
    red(`${score}点: もう一回\n`)
    await say('もう一回', otoya)
    await learn(item, false)
  } else {
    red(`${score}点: やっぱりだめだ\n`)
    await say('やっぱりだめだ', otoya)
  }
}

const items = [
  {text: "安い", gender: 'm'},
  {text: "いいね", gender: 'f'},
  {text: "すごい", gender: 'm'},
  {text: "はじめまして", gender: 'f'},
  {text: "こんにちは", gender: 'm'},
  {text: "なぜですか？", gender: 'f'},
  {text: "どうしましたか？", gender: 'm'},
  {text: "おねさま", gender: 'f'},
  {text: "真実はいつもひとつ！", gender: 'm'},
  {text: "わたし、気になります！", gender: 'f'},
  {text: "おまえはもう死んでる", gender: 'm'},
  {text: "わーい！たーのしー！すごい！", gender: 'f'},
  {text: "はじめまして", gender: 'm'},
  {text: "頑張ります！", gender: 'f'},
  {text: "はい、わかりました", gender: 'm'},
  {text: "うるさい、うるさい！", gender: 'f'},
  {text: "どなたですか", gender: 'm'},
  {text: "あんたバカ？", gender: 'f'},
]

const main = async () => {
  for(let i = 0; i < items.length; i++) {
    await learn(items[i])
    /*
    let item = items[i]
    let speaker = {
      using: item.gender === 'f' ? "Kyoko" : "Otoya",
    }
    await say(item.text, speaker)
    */
  }
}

main()





















