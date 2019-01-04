// https://stackoverflow.com/questions/6158933/how-to-make-an-http-post-request-in-node-js
var request = require('request')
const fs = require('fs');

var folderUrl = "/Users/kinda/projects/Shadowing/iOS/Sentences"
var sentences = fs.readFileSync(`${folderUrl}/grammarN4.swift`,'utf8').split('\n')


// turn off the google ip setting before use it
var getTranslate = (originalText) => {
  return new Promise(function(resolve, reject) {

    request.post(
      'https://translation.googleapis.com/language/translate/v2?key=YOUR_API_KEY',
      { json: {
        'q': originalText,
        'source': 'ja',
        'target': 'zh-TW',
        'format': 'text'
      }},
      function (error, response, body) {
        if (!error && response.statusCode == 200) {
          resolve(body['data']['translations'][0]['translatedText'])
        } else {
          reject("error")
        }
      }

    )
  })
}

async function main() {
  for(i=0; i<sentences.length; i++) {
    let s = sentences[i]
    if(s == "" || s[0] == "/" ||s[0] == "\"" || s[0]=="l"|| s[0]=="]"|| s[0]=="#") {
      console.log(s)
    } else {
      let translate = await getTranslate(s)
      console.log(`${s}|${translate}`)
    }
  }
}

main()
