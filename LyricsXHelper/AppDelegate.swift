//
//  AppDelegate.swift
//
//  This file is part of LyricsX
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
        guard groupDefaults.bool(forKey: LaunchAndQuitWithPlayer) else {
            NSApplication.shared().terminate(nil)
            abort() // fake invoking, just make compiler happy.
        }
        
        let index = groupDefaults.integer(forKey: PreferredPlayerIndex)
        let ident = playerBundleIdentifiers[index]
        mediaPlayer = SBApplication(bundleIdentifier: ident)
        
        shouldWaitForPlayerQuit = mediaPlayer?.isRunning == true
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(checkiTunes), userInfo: nil, repeats: true)
    }
    
    func checkiTunes() {
        if self.shouldWaitForPlayerQuit {
            self.shouldWaitForPlayerQuit = self.mediaPlayer?.isRunning == true
            return
        }
        if self.mediaPlayer?.isRunning == true {
            self.launchMainAndQuit()
        }
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

let playerBundleIdentifiers = [
    "com.apple.iTunes",
    "com.spotify.client",
    "com.coppertino.Vox",
]

let groupDefaults = UserDefaults(suiteName: "3665V726AE.group.ddddxxx.LyricsX")!

// Preference
let PreferredPlayerIndex = "PreferredPlayerIndex"
let LaunchAndQuitWithPlayer = "LaunchAndQuitWithPlayer"

