//
//  AppDelegate.swift
//  iOS Prismatik
//
//  Created by Sergio Rodríguez Rama on 23/10/2018.
//  Copyright © 2018 Sergio Rodríguez Rama. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class AppDelegate: UIResponder, UIApplicationDelegate {

    private var lockView: UIView?
    private var previousBrightness: CGFloat?
    private var trigger: UNTimeIntervalNotificationTrigger?

    var window: UIWindow?
    var client: SocketClient = SocketClient()
    var timerDyn: TimerDyn = TimerDyn()
    var dynamicManager = DynamicManager()
    
    private var resigned: Bool = false
    private var keyboardShown: Bool = false

    lazy var backgroundsContext = backgroundsContainer.viewContext

    lazy var backgroundsContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Backgrounds")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            // Do nothing
        })
        return container
    }()

    func saveBackground() {
        if backgroundsContext.hasChanges {
            do {
                try backgroundsContext.save()
            } catch {

            }
        }
    }
    
    func saveRec(name: String) -> DynBackground? {
        let dynBackground = DynBackground(context: backgroundsContext)
        dynBackground.backgrounds = dynamicManager.backgrounds
        dynBackground.leds = Int32(client.numLeds ?? 0)
        dynBackground.name = name
        do {
            try backgroundsContext.save()
        } catch {
            print("error saving dynamic background")
        }
        return dynBackground
    }

    @objc func applicationDidTimeout() {
        lockView = UIView(frame: UIScreen.main.bounds)
        lockView?.backgroundColor = .black
        if client.setColorStatus == .play || client.lastProfile != nil, let view = lockView, !resigned, !keyboardShown {
            UIApplication.shared.isIdleTimerDisabled = true
            TimerUIApplication.shared.keyWindow?.addSubview(view)
            TimerUIApplication.shared.delegate?.window??.windowLevel = UIWindow.Level.statusBar + 1
            previousBrightness = UIScreen.main.brightness
            UIScreen.main.brightness = 0
        }
    }
    
    @objc func inactivityTimerReset() {
        if let view = lockView {
            UIApplication.shared.isIdleTimerDisabled = false
            view.removeFromSuperview()
            UIScreen.main.brightness = previousBrightness ?? UIScreen.main.brightness
            TimerUIApplication.shared.delegate?.window??.windowLevel = UIWindow.Level.normal
            lockView = nil
            previousBrightness = nil
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidTimeout), name: NSNotification.Name(rawValue: TimerUIApplication.ApplicationDidTimeoutNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(inactivityTimerReset), name: NSNotification.Name(rawValue: TimerUIApplication.ApplicationResetTimerNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: TimerUIApplication.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: TimerUIApplication.keyboardWillShowNotification, object: nil)
        // Request for notifications permission
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound];
        center.requestAuthorization(options: options) { (_, _) in
            // Do something
        }
        return true
    }
    
    @objc func keyboardWillAppear() {
        keyboardShown = true
    }
    
    @objc func keyboardWillDisappear() {
        keyboardShown = false
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        resigned = true
        if lockView != nil, let bright = previousBrightness {
            UIScreen.main.brightness = bright
        }
        if timerDyn.statusDyn == .play {
            timerDyn.statusDyn = .pause
        }
        // The notification will be triggered two minutes after resigning
        if client.setColorStatus == .play || client.lastProfile != nil {
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: 120, repeats: false)
            let identifier = "ResignNotification"
            let content = UNMutableNotificationContent()
            // TODO: - Translate
            content.title = "Connection with AmbiBox will be lost 😅"
            content.body = "Leave the app open and the screen will turn off automatically to save battery."
            content.sound = UNNotificationSound.default
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            let center = UNUserNotificationCenter.current()
            center.add(request, withCompletionHandler: { (error) in
                // Do something
            })
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        // Flag para indicar que nos vamos al background
        UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.client.setColorStatus = .stop
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        if client.setColorStatus == .play {
            (TimerUIApplication.shared as? TimerUIApplication)?.resetTimer()
        }
        if lockView != nil {
            inactivityTimerReset()
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        resigned = false
        (TimerUIApplication.shared as? TimerUIApplication)?.resetTimer()
        if lockView != nil, let bright = previousBrightness {
            UIScreen.main.brightness = bright
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

extension AppDelegate: StreamDelegate {
    func connect(ip: String, port: UInt32, okCompletion: ((String) -> Void)?, readyCompletion: ((String) -> Void)?, busyCompletion: ((String) -> Void)?, endCompletion: ((String) -> Void)?) {
        client.connect(ip, port, target: self, okCompletion, readyCompletion, busyCompletion, endCompletion)
    }
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        if let stream = aStream as? InputStream {
            client.inputStream(stream, handle: eventCode)
        } else if let stream = aStream as? OutputStream {
            client.outputStream(stream, handle: eventCode)
        }
        client.stateChanged()
    }
}
