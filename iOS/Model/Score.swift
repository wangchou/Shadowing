//
//  Score.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/05/23.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Foundation
#if os(iOS)
import UIKit
#endif

enum ScoreType: String, Codable {
    case perfect
    case great
    case good
    case poor
}

struct Score: Codable {
    var value: Int

    var type: ScoreType {
        if value >= 100 { return .perfect }
        if value >= 80 { return .great }
        if value >= 60 { return .good}
        return .poor
    }

    #if os(iOS)
    var text: String {
        if type == .perfect { return gameLang == .jp ? "正解" : "Perfect" }
        if type == .great { return gameLang == .jp ? "すごい" : "Excellent" }
        if type == .good { return gameLang == .jp ? "いいね" : "Good" }
        return gameLang == .jp ? "違います" : "Poor"
    }

    var color: UIColor {
        if type == .perfect { return myGreen }
        if type == .great { return myGreen }
        if type == .good { return myOrange}
        return myRed
    }
    #endif

    var valueText: String { return "\(value)点" }
}
