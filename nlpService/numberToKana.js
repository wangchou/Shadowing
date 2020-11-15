let unitToKana = (unit) => {
    var dict = {          // unit
        "10": "じゅう",   // special for   10 without いち
        "100": "ひゃく",  // special for  100 without いち
        "1000": "せん",   // special for 1000 without いっ in number < 10000 or digit != 1
        "10000": "まん",
        "100000000": "おく",
        "1000000000000": "ちょう"
    }
    return dict[`${unit}`]
}

// https://en.wikipedia.org/wiki/Japanese_numerals
// http://japanese-lesson.com/vocabulary/words/numbers.html
// note: this should work between 1 - (10^12 -1) or 1 ~ 1兆 -1
// isBig for 1000 = いっせん for number >= 10000 && digit == 1
//                  other せん
export let numberToKana = (number, isFromBig = false) => {
    var dict = {
        "0": "れい",
        "1": "いち",
        "2": "に",
        "3": "さん",
        "4": "よん",
        "5": "ご",
        "6": "ろく",
        "7": "なな",
        "8": "はち",
        "9": "きゅう",
        // specials
        "10": "じゅう",       // special for   10 without いち
        "100": "ひゃく",      // special for  100 without いち
        "300": "さんびゃく",
        "600": "ろっぴゃく",
        "800": "はっぴゃく",
        "3000": "さんぜん",
        "8000":"はっせん"
    }
    let specialValues = [10, 100, 1000, 300, 600, 800, 3000, 8000]

    if(number == 1000) {
        return isFromBig ? "いっせん" : "せん"
    }

    if(dict[`${number}`] != undefined) {
        return dict[`${number}`]
    }

    //           兆,               億,              万,    千,   百,  十
    let units = [Math.pow(10, 12), Math.pow(10, 8), 10000, 1000, 100, 10]
    var output = ''

    let isBig = isFromBig || number >= 10000
    units.forEach((unit, i) => {
        if(i == 0) {
            let digit = Math.floor(number/unit)
            if(digit > 0) {
                output += numberToKana(digit, isBig) + unitToKana(unit)
            }
        } else {
            let digit = Math.floor((number%units[i-1])/unit)
            if(digit > 0) {
                let value = digit * unit
                if(specialValues.includes(value)) {
                    output += numberToKana(value, isBig)
                } else {
                    output += numberToKana(digit, isBig) + unitToKana(unit)
                }
            }
        }
    })
    if(number % 10 != 0) {
        output += numberToKana(number % 10)
    }
    return output
}

//console.log(numberToKana(1603))
//console.log(numberToKana(111111111111))

function isDigit(str) {
    return str.match(/^[\d]+$/) != null
}
// for apple recognized japanese
//     from ["1" "," "000" "," "000"] to ["1,000,000"]
export let fixNumberGrouping = (tokenInfos) => {
    var newTokenInfos = []
    var compound = ""
    for(var i = 0; i < tokenInfos.length; i++) {
        let token = tokenInfos[i][0]
        var j = i+1
        if(isDigit(token)) {
            var newToken = token
            var isPreviousDigit = true
            for(; j < tokenInfos.length; j++) {
                let token = tokenInfos[j][0]
                if(isPreviousDigit && token == ',') {
                    isPreviousDigit = false
                    newToken += token
                    continue
                } else if(!isPreviousDigit && isDigit(token)) {
                    isPreviousDigit = true
                    newToken += token
                    continue
                } else {
                    break
                }
            }
            if(j > i + 1) {
                newTokenInfos.push([newToken, "名詞", "*", "*"])
                i = j-1
            } else {
                newTokenInfos.push(tokenInfos[i])
            }
        } else {
            newTokenInfos.push(tokenInfos[i])
        }
    }
    return newTokenInfos
}
