//
//  Score.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/23.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
import UIKit

enum ScoreType {
    case perfect
    case great
    case good
    case poor
}

struct Score {
    var value: Int

    var type: ScoreType {
        if value >= 100 { return .perfect }
        if value >= 80 { return .great }
        if value >= 60 { return .good}
        return .poor
    }

    var text: String {
        if type == .perfect { return "正解"}
        if type == .great { return "すごい"}
        if type == .good { return "いいね"}
        return "違うよ"
    }

    var color: UIColor {
        if type == .perfect { return myGreen }
        if type == .great { return myGreen }
        if type == .good { return myOrange}
        return myRed
    }

    var valueText: String { return "\(value)分"}
}
