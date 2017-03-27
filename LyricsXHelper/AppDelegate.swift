//
//  AppDelegate.swift
//  LyricsXHelper
//
//  Created by 邓翔 on 2017/3/27.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Cocoa
import ScriptingBridge

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let iTunes = SBApplication(bundleIdentifier: "com.apple.iTunes")
    var shouldWaitForiTunesQuit = false

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let lyricsXDefault = UserDefaults(suiteName: "group.ddddxxx.LyricsX")!
        
        if lyricsXDefault.bool(forKey: LaunchAndQuitWithPlayer) {
            shouldWaitForiTunesQuit = iTunes?.isRunning == true
            Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
                if self.shouldWaitForiTunesQuit {
                    self.shouldWaitForiTunesQuit = self.iTunes?.isRunning == true
                    return
                }
                if self.iTunes?.isRunning == true {
                    self.launchMainAndQuit()
                }
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        
    }

    func launchMainAndQuit() -> Never {
        var pathComponents = (Bundle.main.bundlePath as NSString).pathComponents
        pathComponents.removeLast(4)
        let path = NSString.path(withComponents: pathComponents)
        NSWorkspace.shared().launchApplication(path)
        NSApp.terminate(nil)
        abort() // fake invoking, just make compiler happy.
    }

}

// Preference
let LaunchAndQuitWithPlayer = "LaunchAndQuitWithPlayer"

