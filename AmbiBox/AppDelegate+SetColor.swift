//
//  AppDelegate+SetColor.swift
//  iOS Prismatik
//
//  Created by Sergio Rodríguez Rama on 06/12/2018.
//  Copyright © 2018 Sergio Rodríguez Rama. All rights reserved.
//

import Foundation
import UIKit

extension AppDelegate {
    func setColor(background: Background? = nil, dynBackground: DynBackground? = nil, string: String? = nil, dynamic: Bool = false) {
        if !dynamic {
            client.lastBackground = string
            if background != nil {
                client.background = background
            }
        } else {
            client.lastBackground = string
            if dynBackground != nil {
                client.dynBackground = dynBackground
            }
        }
        client.dynamic = dynamic
        if client.setColorStatus == .stop {
            client.setColorStatus = .play
            DispatchQueue.global(qos: .background).async { [weak self] in
                self?.setColor()
            }
        }
    }
    
    private func setColor() {
        var colorStr: String?
        if client.lastBackground == nil {
            colorStr = client.background?.value
        } else {
            colorStr = client.lastBackground
        }
        if let colorStr = colorStr {
            client.setColor(string: colorStr, error: { [weak self] in
                if self?.client.setColorStatus == .play {
                    self?.setColor()
                }
            }, ok: { [weak self] in
                if self?.client.setColorStatus == .play {
                    if self?.client.dynamic == true {
                        self?.client.lastBackground = self?.dynamicManager.background()
                    }
                    self?.setColor()
                }
            })
        }
    }
}
