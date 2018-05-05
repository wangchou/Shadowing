//
//  ListenCommand.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/03.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import Speech

struct ListenCommand: Command {
    let type = CommandType.listen
    let duration: Double
    
    func exec() {
        postEvent(.listenStarted, "")
        let context = CommandContext.shared
        if !context.isEngineRunning {
            cmdGroup.leave()
            postEvent(.listenEnded, "")
            return
        }
        DispatchQueue.main.async {
            context.speechRecognizer.start(
                inputNode: context.engine.inputNode,
                stopAfterSeconds: self.duration,
                resultHandler: self.resultHandler
            )
        }
    }
    
    func resultHandler(result: SFSpeechRecognitionResult?, error: Error?) {
        let context = CommandContext.shared
        if !context.isEngineRunning {
            return
        }
        
        if let result = result {
            if result.isFinal {
                context.saidSentence = result.bestTranscription.formattedString
                postEvent(.listenEnded, context.saidSentence)
                cmdGroup.leave()
            } else {
                postEvent(.stringRecognized, result.bestTranscription.formattedString)
            }
        }
        
        if error != nil {
            context.saidSentence = context.isDev ? "おねさま" : ""
            postEvent(.listenEnded, context.saidSentence)
            cmdGroup.leave()
        }
        
    }
}
