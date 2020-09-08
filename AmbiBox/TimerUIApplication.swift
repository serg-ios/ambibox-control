//
//  TimerUIApplication.swift
//  iOS Prismatik
//
//  Created by Sergio Rodríguez Rama on 08/12/2018.
//  Copyright © 2018 Sergio Rodríguez Rama. All rights reserved.
//

import Foundation
import UIKit

class TimerUIApplication: UIApplication {

    static let ApplicationDidTimeoutNotification = "InactivityTimeOut"
    static let ApplicationResetTimerNotification = "ResetTimer"
    
    var timer: Timer?
    
    @objc func timerExceeded() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: TimerUIApplication.ApplicationDidTimeoutNotification), object: nil)
    }
    
    func resetTimer() {
        timer?.invalidate()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: TimerUIApplication.ApplicationResetTimerNotification), object: nil)
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(5), target: self, selector: #selector(timerExceeded), userInfo: nil, repeats: false)
    }
    
    override func sendEvent(_ event: UIEvent) {
        super.sendEvent(event)
        resetTimer()
        guard let allTouches: NSSet = event.allTouches as NSSet? else { return }
        if allTouches.count > 0 {
            if let touch = allTouches.anyObject() as? UITouch, touch.phase == UITouch.Phase.began {
                resetTimer()
            }
        }
    }
}
