//
//  SocketClient.swift
//  iOS Prismatik
//
//  Created by Sergio Rodríguez Rama on 27/10/2018.
//  Copyright © 2018 Sergio Rodríguez Rama. All rights reserved.
//

import UIKit
import Foundation

enum SocketStatus {
    case ok
    case ready
    case busy
    case end
}

enum SetColorStatus {
    case play
    case stop
}

class SocketClient {

    let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 4096)

    var ip: String?
    var port: UInt32?
    var target: StreamDelegate?
    var dynamic: Bool?
    var setColorStatus: SetColorStatus = .stop {
        didSet {
            if setColorStatus == .stop {
                background = nil
                dynBackground = nil
                lastBackground = nil
            } else if setColorStatus == .play {
                (TimerUIApplication.shared as? TimerUIApplication)?.resetTimer()
            }
        }
    }
    var lastBackground: String?
    var numLeds: Int?
    var background: Background?
    var dynBackground: DynBackground?
    var delegate: SocketAPIProtocol?
    var lastProfile: String?
    
    private(set) var inputStream: InputStream?
    private(set) var outputStream: OutputStream?

    private(set) var lastInputEvent: Stream.Event?
    private(set) var lastOutputEvent: Stream.Event?

    // MARK: - Socket states
    
    func stateChanged() {
        if connOk && state == .end {
            state = .ok
        } else if connReady && state != .end {
            state = .ready
        } else if connEnd {
            state = .end
        } else if connBusy && (state == .ok || state == .ready) {
            state = .busy
        }
    }
    
    var state: SocketStatus = .end {
        didSet {
            switch state {
            case .ok:
                okCompletion?(read())
            case .ready:
                readyCompletion?(read())
            case .busy:
                busyCompletion?(read())
            case .end:
                endCompletion?(read())
            }
        }
    }
    
    private var connOk: Bool {
        let inputOk = lastInputEvent == .openCompleted || lastInputEvent == .hasBytesAvailable
        let outputOk = lastOutputEvent == .openCompleted || lastOutputEvent == .hasSpaceAvailable
        return inputOk && outputOk
    }
    
    private var connReady: Bool {
        let inputReady = lastInputEvent == .hasBytesAvailable
        let outputReady = lastOutputEvent == .hasSpaceAvailable
        return inputReady && outputReady
    }
    
    private var connBusy: Bool {
        return lastInputEvent != nil && lastOutputEvent != nil && !connOk && !connReady && !connEnd
    }
    
    private var connEnd: Bool {
        let inputEnd = lastInputEvent == .endEncountered || lastInputEvent == .errorOccurred
        let outputEnd = lastOutputEvent == .endEncountered || lastOutputEvent == .errorOccurred
        return inputEnd && outputEnd
    }
    
    private var okCompletion: ((String) -> Void)?
    private var readyCompletion: ((String) -> Void)?
    private var busyCompletion: ((String) -> Void)?
    private var endCompletion: ((String) -> Void)?

    // MARK: - Connect / disconnect

    func connect(_ ip: String, _ port: UInt32, target: StreamDelegate, _ okCompletion: ((String) -> Void)?, _ readyCompletion: ((String) -> Void)?, _ busyCompletion: ((String) -> Void)?, _ endCompletion: ((String) -> Void)?) {
        self.okCompletion = okCompletion
        self.readyCompletion = readyCompletion
        self.busyCompletion = busyCompletion
        self.endCompletion = endCompletion
        connect(ip, port, target)
    }
    
    private func connect(_ ip: String, _ port: UInt32, _ target: StreamDelegate) {
        disconnect()
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, ip as CFString, port, &readStream, &writeStream)
        if let readStream = readStream, let writeStream = writeStream {
            inputStream = readStream.takeRetainedValue()
            outputStream = writeStream.takeRetainedValue()
        }
        inputStream?.delegate = target
        outputStream?.delegate = target
        inputStream?.schedule(in: .current, forMode: .default)
        outputStream?.schedule(in: .current, forMode: .default)
        CFReadStreamSetProperty(inputStream, CFStreamPropertyKey(kCFStreamPropertyShouldCloseNativeSocket), kCFBooleanFalse)
        CFWriteStreamSetProperty(outputStream, CFStreamPropertyKey(kCFStreamPropertyShouldCloseNativeSocket), kCFBooleanFalse)
        inputStream?.open()
        outputStream?.open()
        
        self.ip = ip
        self.port = port
        self.target = target
    }
    
    func disconnect(okCompletion: ((String) -> Void)? = nil, readyCompletion: ((String) -> Void)? = nil, busyCompletion: ((String) -> Void)? = nil, endCompletion: ((String) -> Void)? = nil) {
        self.okCompletion = okCompletion
        self.readyCompletion = readyCompletion
        self.busyCompletion = busyCompletion
        self.endCompletion = endCompletion
        disconnect()
    }

    private func disconnect() {
        inputStream?.close()
        outputStream?.close()
        lastInputEvent = nil
        lastOutputEvent = nil
        setColorStatus = .stop
    }

    // MARK: - Write / read
    
    func write(_ string: String, okCompletion: ((String) -> Void)? = nil, readyCompletion: ((String) -> Void)?, busyCompletion: ((String) -> Void)? = nil, endCompletion: ((String) -> Void)? = nil) {
        self.okCompletion = okCompletion
        self.readyCompletion = readyCompletion
        self.busyCompletion = busyCompletion
        self.endCompletion = endCompletion
        write(string)
    }

    private func write(_ string: String) {
//        print(">> " + string)
        if let data = string.data(using: .ascii) {
            return data.withUnsafeBytes { [weak self] in
                self?.outputStream?.write($0, maxLength: data.count)
            }
        }
    }

    private func read() -> String {
        var finalString = ""
        while inputStream?.hasBytesAvailable == true {
            if let numBytesRead = inputStream?.read(buffer, maxLength: 4096) {
                if numBytesRead < 0 {
                    break
                }
                if let string = String(bytesNoCopy: buffer, length: numBytesRead, encoding: .utf8, freeWhenDone: false) {
                    finalString += string
                }
            }
        }
//        print(finalString, terminator: "")
        return finalString
    }

    // MARK: - Events

    func inputStream(_ aStream: InputStream, handle eventCode: Stream.Event) {
        inputStream = aStream
        lastInputEvent = eventCode
//        printEvent(eventCode, stream: "IN")
    }

    func outputStream(_ aStream: OutputStream, handle eventCode: Stream.Event) {
        outputStream = aStream
        lastOutputEvent = eventCode
//        printEvent(eventCode, stream: "OUT")
    }
    
    private func printEvent(_ eventCode: Stream.Event, stream: String) {
        switch eventCode {
        case Stream.Event.hasBytesAvailable:
            print(stream + ": hasBytesAvailable")
        case Stream.Event.hasSpaceAvailable:
            print(stream + ": hasSpaceAvailable")
        case Stream.Event.endEncountered:
            print(stream + ": endEncountered")
        case Stream.Event.errorOccurred:
            print(stream + ": errorOccurred")
        case Stream.Event.openCompleted:
            print(stream + ": openCompleted")
        default:
            break
        }
    }
}
