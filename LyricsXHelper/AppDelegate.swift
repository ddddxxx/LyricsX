//
//  AppDelegate.swift
//
//  This file is part of LyricsX
//  Copyright (C) 2017 Xander Deng - https://github.com/ddddxxx/LyricsX
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
    
    var musicPlayers: [SBApplication] = []
    var shouldWaitForPlayerQuit = false

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        guard groupDefaults.bool(forKey: launchAndQuitWithPlayer) else {
            NSApplication.shared.terminate(nil)
            abort() // fake invoking, just make compiler happy.
        }
        
        let index = groupDefaults.integer(forKey: preferredPlayerIndex)
        let ident = playerBundleIdentifiers[index]
        musicPlayers = ident.compactMap(SBApplication.init)
        
        let event = NSAppleEventManager.shared().currentAppleEvent
        let isLaunchedAsLoginItem = event?.eventID == kAEOpenApplication &&
            event?.paramDescriptor(forKeyword: keyAEPropData)?.enumCodeValue == keyAELaunchedAsLogInItem
        let isLaunchedByMain = (groupDefaults.object(forKey: launchHelperTime) as? Date).map { Date().timeIntervalSince($0) < 10 } ?? false
        shouldWaitForPlayerQuit = !isLaunchedAsLoginItem && isLaunchedByMain && musicPlayers.contains { $0.isRunning }
        
        let wsnc = NSWorkspace.shared.notificationCenter
        wsnc.addObserver(self, selector: #selector(checkTargetApplication), name: NSWorkspace.didLaunchApplicationNotification, object: nil)
        wsnc.addObserver(self, selector: #selector(checkTargetApplication), name: NSWorkspace.didTerminateApplicationNotification, object: nil)
        
//        wsnc.addObserver(forName: NSWorkspace.didLaunchApplicationNotification, object: nil, queue: nil) { n in
//            let bundleID = n.userInfo?["NSApplicationBundleIdentifier"] as? String
//        }
        
        checkTargetApplication()
    }
    
    @objc func checkTargetApplication() {
        let isRunning = musicPlayers.contains { $0.isRunning }
        if shouldWaitForPlayerQuit {
            shouldWaitForPlayerQuit = isRunning
            return
        } else if isRunning {
            self.launchMainAndQuit()
        }
    }

    func launchMainAndQuit() -> Never {
        var host = Bundle.main.bundleURL
        for _ in 0..<4 {
            host.deleteLastPathComponent()
        }
        do {
            try NSWorkspace.shared.launchApplication(at: host, configuration: [:])
            NSLog("launch LyricsX succeed.")
        } catch {
            NSLog("launch LyricsX failed. reason: \(error)")
        }
        NSApp.terminate(nil)
        abort() // fake invoking, just make compiler happy.
    }

}

let playerBundleIdentifiers = [
    ["com.apple.Music", "com.apple.iTunes"],
    ["com.spotify.client"],
    ["com.coppertino.Vox"],
    ["com.audirvana.Audirvana", "com.audirvana.Audirvana-Plus"]
]

let groupDefaults = UserDefaults(suiteName: "3665V726AE.group.ddddxxx.LyricsX")!

// Preference
let preferredPlayerIndex = "PreferredPlayerIndex"
let launchAndQuitWithPlayer = "LaunchAndQuitWithPlayer"
let launchHelperTime = "launchHelperTime"
