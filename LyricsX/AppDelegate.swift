//
//  AppDelegate.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/2/4.
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
import ServiceManagement

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    static var shared: AppDelegate? {
        return NSApplication.shared().delegate as? AppDelegate
    }

    @IBOutlet weak var lyricsOffsetTextField: NSTextField!
    @IBOutlet weak var lyricsOffsetStepper: NSStepper!
    @IBOutlet weak var statusBarMenu: NSMenu!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        MenuBarLyrics.shared.statusItem.menu = statusBarMenu
        
        let controller = AppController.shared
        lyricsOffsetStepper.bind(NSValueBinding, to: controller, withKeyPath: "lyricsOffset", options: [NSContinuouslyUpdatesValueBindingOption: true])
        lyricsOffsetTextField.bind(NSValueBinding, to: controller, withKeyPath: "lyricsOffset", options: [NSContinuouslyUpdatesValueBindingOption: true])
        
        NSRunningApplication.runningApplications(withBundleIdentifier: LyricsXHelperIdentifier).forEach() { $0.terminate() }
        if Preference[.LaunchAndQuitWithPlayer] {
            if !SMLoginItemSetEnabled(LyricsXHelperIdentifier as CFString, true) {
                print("Failed to enable login item")
            }
        }
        
        DispatchQueue.global().async {
            UpdateManager.shared.checkForUpdate()
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        UserDefaults.standard.synchronize()
        if Preference[.LaunchAndQuitWithPlayer] {
            let url = Bundle.main.bundleURL.appendingPathComponent("Contents/Library/LoginItems/LyricsXHelper.app")
            NSWorkspace.shared().launchApplication(url.path)
        }
    }
    
    @IBAction func checkUpdateAction(_ sender: Any) {
        DispatchQueue.global().async {
            UpdateManager.shared.checkForUpdate(force: true)
        }
    }
}

