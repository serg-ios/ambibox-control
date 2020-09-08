//
//  SocketClient+APICalls.swift
//  iOS Prismatik
//
//  Created by Sergio Rodríguez Rama on 01/11/2018.
//  Copyright © 2018 Sergio Rodríguez Rama. All rights reserved.
//

import UIKit
import Foundation

// MARK: - Errors

@objc enum SetColorError: Int {
    case busy
    case error
    case notLocked
}

@objc enum SetStatusError: Int {
    case busy
    case error
}

@objc enum GetStatusApiError: Int {
    case busy
    case badConn
    case endConn
}

@objc enum ReconnectError: Int {
    case busy
    case endConn
}

extension SocketClient {
    
    // MARK: - reconnect
    
    func reconnect() {
        guard let ip = ip, let port = port, let target = target else {
            return
        }
        connect(ip, port, target: target, nil, { [weak self] (_) in
            self?.getStatusApi()
        }, { [weak self] (_) in
            self?.delegate?.reconnectError?(.busy)
        }, { [weak self] (_) in
            self?.delegate?.reconnectError?(.endConn)
        })
    }

    // MARK: - getstatusapi
    
    func getStatusApi() {
        write("getstatusapi\n", readyCompletion: { [weak self] (readStr) in
            let response = readStr.split(separator: ":")
            if readStr.count > 0 && response.count == 2 {
                if response[1].hasPrefix("idle") {
                    self?.delegate?.getStatusApiOk?()
                } else if response[1].hasPrefix("busy") {
                    self?.delegate?.getStatusApiError?(.busy)
                } else {
                    self?.delegate?.getStatusApiError?(.badConn)
                }
            }
        }, endCompletion: { [weak self] (_) in
            self?.delegate?.getStatusApiError?(.badConn)
        })
    }

    // MARK: - lock

    private func lock(success: (() -> Void)? = nil, busy: (() -> Void)? = nil, error: (() -> Void)? = nil) {
        write("lock\n", readyCompletion: { (readStr) in
            let response = readStr.split(separator: ":")
            if response.count == 2 {
                if response[1].hasPrefix("success") {
                    success?()
                } else if response[1].hasPrefix("busy") {
                    busy?()
                }
            }
        })
    }

    // MARK: - unlock

    func unlock(success: (() -> Void)? = nil) {
        write("unlock\n", readyCompletion: { (readStr) in
            let response = readStr.split(separator: ":")
            if response.count == 2 {
                if response[1].hasPrefix("success") || response[1].hasPrefix("not locked") {
                    success?()
                }
            }
        })
    }
    
    // MARK: - setstatus
    
    private func setStatus(_ on: Bool) {
        let string = "setstatus:" + (on ? "on" : "off") + "\n"
        write(string, readyCompletion: { [weak self] (readStr) in
            guard readStr.count > 0 else {
                return
            }
            self?.unlock(success: {
                if readStr.hasPrefix("ok") {
                    self?.delegate?.setStatusOk?()
                } else if readStr.hasPrefix("busy") {
                    self?.delegate?.setStatusError?(.busy)
                } else if readStr.hasPrefix("error") || readStr.hasPrefix("not locked") {
                    self?.delegate?.setStatusError?(.error)
                }
            })
        })
    }
    
    func setStatus(on: Bool) {
        lock(success: { [weak self] in
            self?.setStatus(on)
        }, busy: { [weak self] in
            self?.delegate?.setStatusError?(.busy)
        }, error: { [weak self] in
            self?.delegate?.setStatusError?(.error)
        })
    }
    
    // MARK: - setcolor

    func setColor(string: String, error: (() -> Void)? = nil, ok: (() -> Void)? = nil) {
        write(string, readyCompletion: { [weak self] (readStr) in
            if readStr.hasPrefix("ok") {
                ok?()
            } else if readStr.hasPrefix("need lock") || readStr.hasPrefix("not locked") {
                self?.lock()
                error?()
            } else if readStr.count > 0 {
                error?()
            }
        })
    }
    
    // MARK: - getcountleds
    
    func getCountLeds() {
        write("getcountleds\n", readyCompletion: { [weak self] (readStr) in
            let response = readStr.split(separator: ":")
            if readStr.count > 0 && response.count == 2 {
                if let leds = Int(response[1].filter { "0123456789".contains($0) }) {
                    self?.delegate?.getCountLedsOk?(leds: leds)
                }
            }
        }, endCompletion: { [weak self] (_) in
            self?.delegate?.getCountLedsError?()
        })
    }
    
    // MARK: - getprofiles
    
    func getProfiles() {
        write("getprofiles\n", readyCompletion: { [weak self] (readStr) in
            let pattern: String = "^profiles:((.*;)*)[^;]*$"
            let regex = try? NSRegularExpression(pattern: pattern)
            let result = regex?.matches(in:readStr, range:NSMakeRange(0, readStr.count))
            if let result  = result?.first, let allProfiles = Range(result.range(at: 1), in: readStr) {
                let profiles = String(readStr[allProfiles]).split(separator: ";")
                let array = profiles.map({ (substring) -> String in
                    String(substring)
                })
                self?.delegate?.getProfilesOk?(profiles: array)
            }
        }, endCompletion: { [weak self] (_) in
            self?.delegate?.getProfilesError?()
        })
    }
    
    // MARK: - setprofile
    
    func setProfile(profile: String, error: (() -> Void)? = nil, ok: (() -> Void)? = nil) {
        write("setprofile:\(profile)\n", readyCompletion: { [weak self] (readStr) in
            if readStr.hasPrefix("ok") {
                self?.unlock(success: {
                    ok?()
                })
            } else if readStr.hasPrefix("need lock") || readStr.hasPrefix("not locked") {
                self?.lock(success: {
                    self?.setProfile(profile: profile, error: error, ok: ok)
                }, busy: {
                    error?()
                }, error: {
                    error?()
                })
            } else if readStr.count > 0 {
                error?()
            }
        })
    }
}
