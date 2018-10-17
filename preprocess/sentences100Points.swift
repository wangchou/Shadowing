import Cocoa
import Foundation

private var fCurSpeechChannel: SpeechChannel? = nil

var theErr = OSErr(noErr)

// new channel
theErr = NewSpeechChannel(nil, &fCurSpeechChannel)
if theErr != OSErr(noErr) { print("error... 1") }

// set voice to otoya
private var fSelectedVoiceID: OSType = 369338093
private var fSelectedVoiceCreator: OSType = 1886745202

let voiceDict: NSDictionary = [kSpeechVoiceID: fSelectedVoiceID,
                               kSpeechVoiceCreator: fSelectedVoiceCreator]
theErr = SetSpeechProperty(fCurSpeechChannel!, kSpeechCurrentVoiceProperty, voiceDict)

if theErr != OSErr(noErr) { print("error... 2") }



func toggleListen() {
  let task = Process()
  task.launchPath = "/Users/kinda/projects/Shadowing/preprocess/toggleListen.js"
  task.arguments = []

  task.launch()
}

toggleListen()
// save file
theErr = SpeakCFString(fCurSpeechChannel!, "こんにちは" as CFString, nil)
usleep(3000000)
theErr = SpeakCFString(fCurSpeechChannel!, "こんにちは" as CFString, nil)
usleep(3000000)
theErr = SpeakCFString(fCurSpeechChannel!, "こんにちは" as CFString, nil)
usleep(3000000)

toggleListen()
