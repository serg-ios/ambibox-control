//
//  DynamicManager.swift
//  iOS Prismatik
//
//  Created by Sergio Rodríguez Rama on 15/12/2018.
//  Copyright © 2018 Sergio Rodríguez Rama. All rights reserved.
//

import Foundation
import UIKit

protocol DynamicManagerDelegate: class {
    func newBackground()
}

class DynamicManager {
    var backgrounds: [String] = []
    var timer: Timer?
    weak var delegate: DynamicManagerDelegate?
    private var counter: Int = 0
    private var appDelegate = UIApplication.shared.delegate as? AppDelegate

    // MARK: - Playing methods
    
    func create(backgrounds: [String]) {
        self.backgrounds = backgrounds
        counter = 0
    }

    func background() -> String? {
        if counter >= backgrounds.count { return nil }
        let str = backgrounds[counter]
        counter = (counter + 1) % backgrounds.count
        return str
    }
    
    // MARK: - Recording methods
    
    func startRec() {
        timer?.invalidate()
        backgrounds = []
        counter = 0
    }
    
    func playRec() {
        timer = Timer.scheduledTimer(timeInterval: 0.03, target: self, selector: #selector(newBackground), userInfo: nil, repeats: true)
    }
    
    func pauseRec() {
        timer?.invalidate()
    }
    
    func stopRec() {
        timer?.invalidate()
    }
    
    // MARK: - Selectors
    
    @objc private func newBackground() {
        delegate?.newBackground()
    }
}
