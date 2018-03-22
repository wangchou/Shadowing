const osa = require('osa2')
const promptly = require('promptly')

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
const hint = "請跟著唸："
const sentence = "おはようございます"

const white = (text) => console.log('\x1b[37m%s\x1b[0m', text);
const blue = (text) => console.log('\x1b[34m%s\x1b[0m', text);
const green = (text) => console.log('\x1b[32m%s\x1b[0m', text);
const red = (text) => console.log('\x1b[31m%s\x1b[0m', text);

const main = async () => {
  white(hint + '\n')
  await say(hint, meijia)

  blue(sentence + '\n')
  await say(sentence, kyokoSlow)

  toggleListen()
  const speakText = await promptly.prompt('換你說：')
  toggleListen()
  // press the enter after recognition when prototyping
  if(speakText === sentence) {
    green('O')
  } else {
    red('X')
  }
}

main()







