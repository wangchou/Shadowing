//
//  ViewController.swift
//  PlayThrough
//
//  Created by Wangchou Lu on H30/04/14.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import UIKit
import AVFoundation
import Speech

let MeiJia = "com.apple.ttsbundle.Mei-Jia-premium"
let Otoya = "com.apple.ttsbundle.Otoya-premium"
let Kyoko = "com.apple.ttsbundle.Kyoko-premium"
let Oren = "com.apple.ttsbundle.siri_female_ja-JP_compact"
let Hattori = "com.apple.ttsbundle.siri_male_ja-JP_compact"

let CANNOT_HEAR_HINT = "聽不清楚、再說一次"
let I_HEAR_YOU_HINT = "我聽到你說："
let SPEAK_TO_ME_HINT = "請說日文給我聽"

let replayRate: Float = 0.8

// move the right earphone close to the mic
// then you can test the app on real device in quite space
let isDevMode = true

class ViewController: UIViewController {
    var engine = AVAudioEngine()
    var speedEffectNode = AVAudioUnitTimePitch()
    var replayUnit: ReplayUnit!
    var speechRecognizer: SpeechRecognizer = SpeechRecognizer()
    var mic: AVAudioInputNode!
    var bgm = BGM()
    var tts = TTS()
    
    func buildNodeGraph() {
        // get nodes
        let mainMixer = engine.mainMixerNode
        mic = engine.inputNode // only for real device, simulator will crash
        let format = mic.outputFormat(forBus: 0)
        replayUnit = ReplayUnit(pcmFormat: format)
        
        // attach nodes
        engine.attach(bgm.node)
        engine.attach(replayUnit.node)
        engine.attach(speedEffectNode)
        
        // connect nodes
        engine.connect(bgm.node, to: mainMixer, format: bgm.buffer.format)
        engine.connect(mic, to: mainMixer, format: format)
        engine.connect(replayUnit.node, to: speedEffectNode, format: format)
        engine.connect(speedEffectNode, to: mainMixer, format: format)
        
        // misc
        speedEffectNode.rate = replayRate // replay slowly
        
        // for dev
        if(isDevMode) {
            bgm.node.pan = -1.0
            bgm.node.volume = 0.05
            mic.pan = -1.0
        }
    }
    
    func engineStart() {
        do {
            configureAudioSession()
            buildNodeGraph()
            engine.prepare()
            try engine.start()
        } catch {
            print("Start Play through failed \(error)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        engineStart()
        bgm.play()
        speakToMe()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func speakDevTTS() {
        if(isDevMode) {
            self.tts.speak("読めば分かる！説明できない面白さ！！", Hattori, volume: 1.0, leftChannelOn: false)
        }
    }
    
    func speakToMe() {
        self.tts.speak(SPEAK_TO_ME_HINT, MeiJia) {
            self.speechRecognizer.start(
                inputNode: self.mic,
                stopAfterSeconds: 5,
                startCompleteHandler: self.speakDevTTS,
                resultHandler: self.speechResultHandler
            )
        }
    }
    
    func iHearYouSaid(_ result: SFSpeechRecognitionResult) {
        print("\n<<< \(result.bestTranscription.formattedString)\n")
        tts.speak(I_HEAR_YOU_HINT, MeiJia) {
            self.bgm.node.volume = self.bgm.node.volume * 0.2
            var isReplayUnitComplete = false
            var isTTSSpeakComplete = false
            func afterReplayComplete() {
                if(isReplayUnitComplete && isTTSSpeakComplete) {
                    self.speakToMe()
                    self.bgm.node.volume = self.bgm.node.volume * 5
                }
            }
            self.replayUnit.play() {
                isReplayUnitComplete = true
                afterReplayComplete()
            }
            self.tts.speak(result.bestTranscription.formattedString,
                           Oren,
                           rate: AVSpeechUtteranceDefaultSpeechRate * replayRate,
                           rightChannelOn: false
            ) {
                isTTSSpeakComplete = true
                afterReplayComplete()
            }
        }
    }
    
    func speechResultHandler(result: SFSpeechRecognitionResult?, error: Error?) {
        if let result = result {
            if(result.isFinal) {
                iHearYouSaid(result)
            }
        }
        
        if let error = error {
            print(error)
            speakToMe()
        }
    }
}


