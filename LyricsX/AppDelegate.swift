//
//  AppDelegate.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/2/4.
//  Copyright © 2017年 ddddxxx. All rights reserved.
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

