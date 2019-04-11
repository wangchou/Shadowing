//
//  UIView+Animation.swift
//  今話したい
//
//  Created by Wangchou Lu on 4/11/31 H.
//  Copyright © 31 Heisei Lu, WangChou. All rights reserved.
//

import UIKit

// Show UIView animation
extension UIView {
    func slideIn(delay: TimeInterval = 0, duration: TimeInterval) {
        frame.origin.x += screen.width
        alpha = 0.2

        let animator = UIViewPropertyAnimator(duration: duration, curve: .easeIn, animations: {
            self.transform = CGAffineTransform(translationX: -1 * screen.width, y: 0)
            self.alpha = 1
        })
        Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
            animator.startAnimation()
        }
    }

    func enlargeIn(delay: TimeInterval = 0, duration: TimeInterval) {
        transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        alpha = 0

        let animator = UIViewPropertyAnimator(duration: duration, curve: .easeIn, animations: {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.alpha = 1
        })
        Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
            animator.startAnimation()
        }
    }

    func shrinkIn(delay: TimeInterval = 0, duration: TimeInterval) {
        isHidden = true
        transform = CGAffineTransform(scaleX: 2, y: 2)

        let animator = UIViewPropertyAnimator(duration: duration, curve: .easeIn, animations: {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
        Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
            self.isHidden = false
            animator.startAnimation()
        }
    }

    func fadeIn(delay: TimeInterval = 0, duration: TimeInterval) {
        alpha = 0

        let animator = UIViewPropertyAnimator(duration: duration, curve: .easeIn, animations: {
            self.alpha = 1
        })
        Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
            animator.startAnimation()
        }
    }
}
