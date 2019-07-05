//
//  Type+Conversion.swift
//  今話したい
//
//  Created by Wangchou Lu on 12/23/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation

#if os(iOS)
    import UIKit
#endif

extension Int {
    var f: Float { return Float(self) }
    var c: CGFloat { return CGFloat(self) }
    var s: String { return String(self) }
}

extension Float {
    var i: Int { return Int(self) }
    var c: CGFloat { return CGFloat(self) }
}

extension CGFloat {
    var f: Float { return Float(self) }
}

extension Date {
    var ms: Int64 {
        return Int64((timeIntervalSince1970 * 1000.0).rounded())
        // RESOLVED CRASH HERE
    }

    init(ms: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(ms / 1000))
    }
}

extension Substring {
    var s: String { return String(self) }
}

extension ArraySlice {
    var a: [Element] { return Array(self) }
}
