//
//  AppDelegate.swift
//  LyricsXHelper
//
//  Created by 邓翔 on 2017/3/27.
//
//  Copyright (C) 2017  Xander Deng
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
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

