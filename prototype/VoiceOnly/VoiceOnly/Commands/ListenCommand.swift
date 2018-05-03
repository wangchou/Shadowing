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
    let listenDuration: Double
    let resultHandler: (SFSpeechRecognitionResult?, Error?) -> Void
    
    func exec() {
        let context = Commands.shared
        cmdGroup.enter()
        if !context.isEngineRunning {
            return
        }
        DispatchQueue.main.async {
            context.speechRecognizer.start(
                inputNode: context.engine.inputNode,
                stopAfterSeconds: self.listenDuration,
                resultHandler: self.resultHandler
            )
        }
    }
}

func listen(listenDuration: Double,
            resultHandler: @escaping (SFSpeechRecognitionResult?, Error?) -> Void
    ) {
    let listenCommand = ListenCommand(listenDuration: listenDuration, resultHandler: resultHandler)
    dispatch(listenCommand)
}
