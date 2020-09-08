//
//  SocketClient+Protocol.swift
//  iOS Prismatik
//
//  Created by Sergio Rodríguez Rama on 02/11/2018.
//  Copyright © 2018 Sergio Rodríguez Rama. All rights reserved.
//

import Foundation

@objc protocol SocketAPIProtocol: class {
    // setcolor responses
    @objc optional func setColorOk(string: String)
    @objc optional func setColorError(_ error: SetColorError)
    // setstatus responses
    @objc optional func setStatusOk()
    @objc optional func setStatusError(_ error: SetStatusError)
    // getstausapi responses
    @objc optional func getStatusApiOk()
    @objc optional func getStatusApiError(_ error: GetStatusApiError)
    // getcountleds
    @objc optional func getCountLedsOk(leds: Int)
    @objc optional func getCountLedsError()
    // getprofiles
    @objc optional func getProfilesOk(profiles: [String])
    @objc optional func getProfilesError()
    // reconnect responses
    @objc optional func reconnectOk()
    @objc optional func reconnectError(_ error: ReconnectError)
}
