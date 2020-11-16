import fs from 'fs';
import { numberToKana, fixNumberGrouping } from './numberToKana.js'

function loadGlobalReplacement(fname) {
    return fs.readFileSync(fname,'utf8')
             .split('\n')
             .filter(line => (line != "" ))
             .map(line => {
                 return line.split(' ')
             })
}

// str \t correct_kana \t replace1 \t replace2 \t replace3 ... \n
function loadLocalReplacement(fname) {
    fs.readFileSync(fname,'utf8')
             .split('\n')
             .forEach(line => {
                 var items = line.split('\t')
                 var str = items[0]
                 var newLocalFixes = []
                 var key = ""
                 if(items[2]) {
                     items[2]
                         .split(' ')
                         .forEach((item, i) => {
                             if(i % 2 == 0) {
                                 key = item
                             } else {
                                 newLocalFixes.push([key, item])
                             }
                         })

                     nLocalFixes[str] = newLocalFixes
                 }
             })
}

var nGlobalReplace = loadGlobalReplacement('kanaFixes')

let katakanaToHiragana = (str) => {
    let result = ""

    for (let i = 0; i < str.length; i++) {
        let charCode = str.charCodeAt(i)
        if(str[i] == '・') {
            continue
        } else if (charCode >= 0x30A0 && charCode <= 0x30FB) {
            result += String.fromCharCode(charCode - 0x60)
        } else {
            result += str.charAt(i)
        }
    }
    return result
}

var nComplexFixes = nGlobalReplace.filter(array => array.length == 3)
var nOverwriteFixes = nGlobalReplace.filter(array => array[0] == 'ow')
var nIfFixes = nGlobalReplace.filter(array => array[0] == 'if')
var nSimpleFixes = nGlobalReplace.filter(array => array.length == 2)

// ow 2 微 笑み 微笑み 名詞 ほほえみ
// will overwrite ['微'...], ['笑み', ...] to ['微笑み', '名詞', 'ほほえみ']
function overwriteFix(tokenInfos) {
  var newTokenInfos = tokenInfos
  nOverwriteFixes.forEach(row => {
      if(row[0] != 'ow') {
          console.log('error: not started with ow')
          return
      }
      let keyLength = parseInt(row[1])
      let keys = row.slice(2, 2+keyLength)
      if((row.length - keyLength - 2) % 3 != 0) {
        console.log('wrong overwrite length:', row)
      }
      let partInfos = []
      var p1, p2
      row.slice(2+keyLength, row.length)
         .forEach((str, idx) => {
             if(idx % 3 == 0) {
                p1 = str
             }
             if(idx % 3 == 1) {
                p2 = str
             }
             if(idx % 3 == 2) {
                 partInfos.push([p1, p2, str])
             }
         })

      var matchStart = undefined
      for(var i = 0; i < newTokenInfos.length - keyLength; i++) {
        matchStart = i
        for(var j = 0; j < keyLength; j++) {
            if(keys[j] != newTokenInfos[i+j][0]) {
                matchStart = undefined
                break;
            }
        }
        if(matchStart != undefined) {
            var prefix = newTokenInfos.slice(0, matchStart) || []
            var suffix = newTokenInfos.slice(matchStart + keyLength, newTokenInfos.length)
            newTokenInfos = prefix.concat(partInfos).concat(suffix)
        }
      }
  })
  return newTokenInfos
}

function complexKanaFix(tokenInfos, fixes) {
  var newTokenInfos = [...tokenInfos]
  fixes.forEach(row => {
      for(var i = 0; i < tokenInfos.length - 1; i++) {
        if(newTokenInfos[i][0] == row[0] && newTokenInfos[i+1][0] == row[1]) {
            newTokenInfos[i][2] = newTokenInfos[i][3] = row[2]
        }
      }
  })
  return newTokenInfos
}

function simpleKanaFix(tokenInfo, fixes) {
  var newTokenInfo = [...tokenInfo]
  fixes.forEach(pair => {
    var key = pair[0]
    var fix = pair[1]
    if(tokenInfo[0] == key) {
      newTokenInfo[2] = newTokenInfo[3] = fix
    }
  })
  return newTokenInfo
}

function ifKanaFix(tokenInfo, fixes) {
  let newTokenInfo = [...tokenInfo]
  fixes.forEach(row => {
    var key = row[1]
    var ifCase = row[2]
    var fix = row[3]
    if(tokenInfo[0] == key && tokenInfo[2] == ifCase) {
      newTokenInfo[2] = newTokenInfo[3] = fix
    }
  })
  return newTokenInfo
}

export let getFixedTokenInfos = (tokenInfos, localFixes = []) => {
  var newTokenInfos = fixNumberGrouping(tokenInfos)
  newTokenInfos = complexKanaFix(newTokenInfos, nComplexFixes)
  newTokenInfos = overwriteFix(newTokenInfos)

  return newTokenInfos
        .map(tokenInfo => {
            var tmp = simpleKanaFix(tokenInfo, nSimpleFixes) // global fix
            tmp = ifKanaFix(tmp, nIfFixes)
            if(localFixes.length > 0) {
                tmp = simpleKanaFix(tmp, localFixes) // newly added local fix
            }
            if(tmp[2] == '*' && tmp[0].match(/^[\d][\d,]*$/)) {
                tmp[2] = tmp[3] = numberToKana(tmp[0].replace(/,/g, ""))
            }
            if(tmp[3] == undefined) { tmp[3] = tmp[2] }
            return tmp
        })
}

// str \t correct_kana \t replace1 \t replace2 \t replace3 ... \n
export let loadNLocal = () => {
    var correctKanas = {}
    var nLocalFixes = {}
    fs.readFileSync('local.n','utf8')
             .split('\n')
             .forEach(line => {
                 var items = line.split('\t')
                 var str = items[0]
                 var correctKana = items[1]
                 if(correctKana != "") {
                    correctKanas[str] = correctKana
                 }
                 var newLocalFixes = []
                 var key = ""
                 if(items[2]) {
                     items[2]
                         .split(' ')
                         .forEach((item, i) => {
                             if(i % 2 == 0) {
                                 key = item
                             } else {
                                 newLocalFixes.push([key, item])
                             }
                         })
                     nLocalFixes[str] = newLocalFixes
                 }
             })
    return {
        correctKanas: correctKanas,
        nLocalFixes: nLocalFixes
    }
}
