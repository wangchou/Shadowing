// 1. use node 9 or above for async
// 2. install tts sound on Mac by
//    System Preference -> Accessibility -> Speech -> 聲 -> Japanese
const osa = require('osa2')
const promptly = require('promptly')
const chalk = require('chalk')

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
  if(speakText === item.text) {
    green('いいね\n')
    await say('いいね', kyoko)
  } else if(isFirstTime) {
    red('もう一回\n')
    await say('もう一回', otoya)
    await learn(item, false)
  } else {
    red('やっぱりだめだ\n')
    await say('やっぱりだめだ', otoya)
  }
}

const items = [
  {text: "こんにちは。", gender: 'm'},
  {text: "なぜですか？", gender: 'f'},
  {text: "そりゃ無理だ", gender: 'm'},
  {text: "おね様", gender: 'f'},
  {text: "真実はいつもひとつ！", gender: 'm'},
  {text: "私、気になります！", gender: 'f'},
  {text: "おまえはもう死んでる", gender: 'm'},
  {text: "わーい！たーのしー！すごい！", gender: 'f'},
  {text: "はじめまして", gender: 'm'},
  {text: "不愉快です~", gender: 'f'},
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





















