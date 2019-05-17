//
//  thisProjectOnly.swift
//  processVOC
//
//  Created by Wangchou Lu on 5/17/31 H.
//  Copyright © 31 Heisei Lu, WangChou. All rights reserved.
//

import Foundation

// duplicate with other project when include
extension String {
    func substring(with nsrange: NSRange) -> Substring? {
        guard let range = Range(nsrange, in: self) else { return nil }
        return self[range]
    }
}
