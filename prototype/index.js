// 1. use node 9 or above for async
// 2. install tts sound on Mac by
//    System Preference -> Accessibility -> Speech -> 聲 -> Japanese
// 3. make sure the network is connected for Apple Speech Recognition
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
  return Application('System Events').keyCode([fnKeyCode, fnKeyCode])
})

const enter = osa(() => {
  const enterKeyCode = 36
  delay(3)
  return Application('System Events').keyCode([enterKeyCode])
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

async function learn (item, isFirstTime = true) {
  if(isFirstTime) {
    gray('--------------------------------------------\n')
    white(repeatMe)
  } else {
    white(repeatMeSecond)
  }

  blue(item.text + '\n')
  await toggleListen()
  let speaker = {
    using: item.gender === 'f' ? "Kyoko" : "Otoya",
    speakingRate: isFirstTime ? 160 : 120
  }
  say(item.text, speaker)
  const speakText = await promptly.prompt('換你說：')
  await toggleListen()

  // press the enter after recognition when prototyping
  let trimedText = trim(item.text)
  let strDist = calcDist(speakText, trimedText)
  let len = max(trimedText.length, speakText.length)
  let score = Math.trunc(max(len - strDist, 0) * 100 / len)
  if(score >= 80) {
    let goodWord = score === 100 ? "すごい" : "いいね"
    green(`${score}点: ${goodWord}\n`)
    await say(goodWord, kyoko)
  } else if(isFirstTime) {
    red(`${score}点: ${strDist}/${len} もう一回\n`)
    await say('もう一回', otoya)
    await learn(item, false)
  } else {
    red(`${score}点: ${strDist}/${len} やっぱりだめだ\n`)
    await say('やっぱりだめだ', otoya)
  }
}

const items = [
  {text: "こんにちは", gender: 'm'},
  {text: "なぜですか？", gender: 'f'},
  {text: "そりゃ無理だ", gender: 'm'},
  {text: "おね様", gender: 'f'},
  {text: "真実はいつもひとつ！", gender: 'm'},
  {text: "私、気になります！", gender: 'f'},
  {text: "おまえはもう死んでる", gender: 'm'},
  {text: "わーい！たーのしー！すごい！", gender: 'f'},
  {text: "はじめまして", gender: 'm'},
  {text: "不愉快です", gender: 'f'},
  {text: "はい、わかりました", gender: 'm'},
  {text: "うるさい、うるさい！", gender: 'f'},
  {text: "どなたですか", gender: 'm'},
  {text: "あんたバカ？", gender: 'f'},
  {text: "どうしましたか？", gender: 'm'},
  {text: "頑張ります！", gender: 'f'},
]

const main = async () => {
  for(let i = 0; i < items.length; i++) {
    await learn(items[i])
    // console.log(trim(items[i].text))
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





















