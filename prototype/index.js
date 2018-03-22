const osa = require('osa2')
const promptly = require('promptly')
const chalk = require('chalk')

const say = osa((text, props) => {
  var app = Application.currentApplication()
  app.includeStandardAdditions = true

  return app.say(text, props)
})

const displayDialog = osa((text) => {
  var app = Application.currentApplication()
  app.includeStandardAdditions = true

  return app.displayDialog(text, {
    defaultAnswer: "",
    buttons: ["done"],
    givingUpAfter: 10
  })
})

const toggleListen = osa(() => {
  const fnKeyCode = 63
  // press Fn twice to enable dictation
  Application('System Events').keyCode([fnKeyCode, fnKeyCode])
})

// async is supported in node 9
// need to install tts sound from
// System Preference -> Accessibility -> Speech -> 聲 -> Japanese

const kyokoSlow = {
  using: "Kyoko",
  speakingRate: 140,
  //pitch: 120,
  //modulation: 100
}
const kyoko = { using: "Kyoko"}
const meijia = { using: "Mei-Jia" }

const listenMe = "請仔細聽："
const repeatMe = "請跟著唸："

const colorLog = (color) => (text) => console.log(chalk[color](text))
const white = colorLog('white')
const blue = colorLog('blue')
const green = colorLog('green')
const red = colorLog('red')
const gray = colorLog('gray')

const learn = async (sentence) => {
  gray('--------------------------------------------')
  white(listenMe)
  await say(listenMe, meijia)

  blue(sentence + '\n')
  await say(sentence, kyokoSlow)

  await toggleListen()
  const speakText = await promptly.prompt(repeatMe)
  await toggleListen()
  // press the enter after recognition when prototyping
  if(speakText === sentence) {
    green('O')
    await say('いいね', kyoko)
  } else {
    red('X')
    await say('がんばろ', kyoko)
  }
}

const main = async () => {
  await learn('そりゃ無理だ')
  await learn('安い')
  await learn('イリアちゃんも')
}

main()





















