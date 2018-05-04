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
        let context = CommandContext.shared
        if !context.isEngineRunning {
            cmdGroup.leave()
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
        
        if let result = result, result.isFinal {
            context.saidSentence = result.bestTranscription.formattedString
            cmdGroup.leave()
        }
        
        if error != nil {
            context.saidSentence = context.isDev ? "おねさま" : ""
            cmdGroup.leave()
        }
        
    }
}
