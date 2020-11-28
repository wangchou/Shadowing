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
        if value >= 60 { return .good }
        return .poor
    }

    #if os(iOS)
        var text: String {
            if type == .perfect { return gameLang == .ja ? "正解" : "Excellent!" }
            if type == .great { return gameLang == .ja ? "すごい" : "Great!" }
            if type == .good { return gameLang == .ja ? "いいね" : "Good." }
            return gameLang == .ja ? "違います" : "Not right."
        }

        var color: UIColor {
            if type == .perfect { return myGreen }
            if type == .great { return myGreen }
            if type == .good { return myOrange }
            return myRed
        }

        var valueText: String { return "\(value)\(i18n.pts)" }
    #endif
}
