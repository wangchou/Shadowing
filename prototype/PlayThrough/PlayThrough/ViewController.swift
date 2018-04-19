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

var sentenceIndex = 0

let replayRate: Float = 0.8

let assistant = MeiJia
let teacher = Hattori

class ViewController: UIViewController {
    var engine = AVAudioEngine()
    var speedEffectNode = AVAudioUnitTimePitch()
    var replayUnit: ReplayUnit!
    var speechRecognizer: SpeechRecognizer = SpeechRecognizer()
    var bgm = BGM()
    var tts = TTS()
    
    func buildNodeGraph() {
        // get nodes
        let mainMixer = engine.mainMixerNode
        let mic = engine.inputNode // only for real device, simulator will crash
        let format = mic.outputFormat(forBus: 0)
        replayUnit = ReplayUnit()
        
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
        
        // volume
        bgm.node.volume = 0.5
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
        repeatAfterMe()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // sugar function
    func say(
        _ text: String,
        _ name: String,
        rate: Float = normalRate,
        onCompleteHandler: @escaping () -> Void = {}
    ) {
        tts.say(text, name, rate: rate, onCompleteHandler: onCompleteHandler)
    }
    
    func repeatAfterMe() {
        say(REPEAT_AFTER_ME_HINT, assistant) {
            self.bgm.reduceVolume()
            let sentence = sentences[sentenceIndex]
            let listeningDuration: Double = Double((Float(sentence.count) * 0.6 * teachingRate) + 1.5)
            self.say(sentence, teacher, rate: teachingRate) {
                self.bgm.restoreVolume()
                self.speechRecognizer.start(
                    inputNode: self.engine.inputNode,
                    stopAfterSeconds: listeningDuration,
                    startCompleteHandler: {},
                    resultHandler: self.speechResultHandler
                )
            }
        }
    }
    
    func iHearYouSaid(_ saidString: String) {
        sentenceIndex = (sentenceIndex + 1) % sentences.count
        print("\n<<< \(saidString)\n")
        say(I_HEAR_YOU_HINT, assistant) {
            self.bgm.reduceVolume()
            
            var isReplayUnitComplete = false
            var isTTSSpeakComplete = false
            func afterReplayComplete() {
                //mimic promise.all
                if(isReplayUnitComplete && isTTSSpeakComplete) {
                    self.bgm.restoreVolume()
                    self.repeatAfterMe()
                }
            }
            self.replayUnit.play() {
                isReplayUnitComplete = true
                afterReplayComplete()
            }
            self.say(
                saidString,
                Oren,
                rate: teachingRate * replayRate
            ) {
                self.say("100分", assistant) {
                    isTTSSpeakComplete = true
                    afterReplayComplete()
                }
            }
        }
    }
    
    func speechResultHandler(result: SFSpeechRecognitionResult?, error: Error?) {
        if (result?.isFinal) != nil {
            iHearYouSaid(result!.bestTranscription.formattedString)
        }
        
        if let error = error {
            print(error)
            say(CANNOT_HEAR_HINT, assistant) {
                self.repeatAfterMe()
            }
        }
    }
}


