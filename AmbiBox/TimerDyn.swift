//
//  TimerDyn.swift
//  iOS Prismatik
//
//  Created by Sergio Rodríguez Rama on 12/12/2018.
//  Copyright © 2018 Sergio Rodríguez Rama. All rights reserved.
//

import Foundation
import UIKit

@objc protocol TimerDynDelegate: class {
    @objc optional func stop()
    @objc optional func play()
    @objc optional func pause()
    @objc optional func finish()
    @objc optional func incrementSecond(timeStr: String)
}

enum StatusDyn {
    case stop
    case pause
    case play
    case finish
}

class TimerDyn {

    weak var delegate: TimerDynDelegate?

    private var seconds: UInt16 = 0
    private var timerDyn: Timer?
    
    var navBarImage: UIImage? {
        if statusDyn == .stop || statusDyn == .pause || statusDyn == nil {
            return UIImage(named: "rec")?.withRenderingMode(.alwaysOriginal)
        } else if statusDyn == .play {
            return UIImage(named: "pause")
        } else {
            return nil
        }
    }
    
    var timeStr: String {
        let secondsInt: UInt8 = UInt8(seconds % 60)
        let minutesInt: UInt8 = UInt8(seconds / 60)
        return String(format: "%02d:%02d", minutesInt, secondsInt)
    }

    var statusDyn: StatusDyn? {
        didSet {
            switch statusDyn {
            case .stop?:
                timerDyn?.invalidate()
                seconds = 0
                delegate?.stop?()
            case .pause?:
                timerDyn?.invalidate()
                delegate?.pause?()
            case .play?:
                timerDyn = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(incrementSecond), userInfo: nil, repeats: true)
                if let timer = timerDyn {
                    RunLoop.main.add(timer, forMode: .common)
                }
                delegate?.play?()
            case .finish?:
                break
            case nil:
                break
            }
        }
    }
    
    func toggle() {
        if statusDyn == .stop || statusDyn == .pause {
            statusDyn = .play
        } else if statusDyn == .play {
            statusDyn = .pause
        }
    }
    
    @objc private func incrementSecond() {
        if seconds == 3599 {
            // One hour
            statusDyn = .finish
            delegate?.finish?()
            return
        }
        seconds = (seconds + 1) % 3600
        delegate?.incrementSecond?(timeStr: timeStr)
    }
}
