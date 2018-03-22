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
const meijia = { using: "Mei-Jia" }

const listenMe = "請仔細聽："

const white = (text) => console.log(chalk.white(text));
const blue = (text) => console.log(chalk.blue(text));
const green = (text) => console.log(chalk.green(text));
const red = (text) => console.log(chalk.red(text));
const gray = (text) => console.log(chalk.gray(text));

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
  } else {
    red('X')
  }
}

const main = async () => {
  await learn('そりゃ無理だ')
  await learn('安い')
  await learn('イリアちゃんも')
}

main()





















