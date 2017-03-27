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
    
    var mediaPlayer: SBApplication?
    var shouldWaitForPlayerQuit = false

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let lyricsXDefault = UserDefaults(suiteName: "group.ddddxxx.LyricsX")!
        
        let ident = playerBundleIdentifier[lyricsXDefault.integer(forKey: PreferredPlayerIndex)]
        mediaPlayer = SBApplication(bundleIdentifier: ident)
        
        if lyricsXDefault.bool(forKey: LaunchAndQuitWithPlayer) {
            shouldWaitForPlayerQuit = mediaPlayer?.isRunning == true
            Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
                if self.shouldWaitForPlayerQuit {
                    self.shouldWaitForPlayerQuit = self.mediaPlayer?.isRunning == true
                    return
                }
                if self.mediaPlayer?.isRunning == true {
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

let playerBundleIdentifier = [
    "com.apple.iTunes",
    "com.spotify.client",
    "com.coppertino.Vox",
]

// Preference
let PreferredPlayerIndex = "PreferredPlayerIndex"
let LaunchAndQuitWithPlayer = "LaunchAndQuitWithPlayer"

