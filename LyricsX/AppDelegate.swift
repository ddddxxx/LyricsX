//
//  AppDelegate.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/2/4.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Cocoa
import EasyPreference

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var mediaPlayerHelper = MediaPlayerHelper()
    
    var statusItem: NSStatusItem!
    var menuBarLyrics: MenuBarLyrics!

    dynamic var currentOffset = 0
    
    @IBOutlet weak var statusBarMenu: NSMenu!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem = NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength)
        menuBarLyrics = MenuBarLyrics()
        
        statusItem.button?.image = #imageLiteral(resourceName: "status_bar_icon")
        statusItem.menu = statusBarMenu
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @IBAction func lyricsOffsetStepAction(_ sender: Any) {
        mediaPlayerHelper.currentLyrics?.offset = currentOffset
        mediaPlayerHelper.currentLyrics?.saveToLocal()
    }
    
    @IBAction func checkUpdateAction(_ sender: Any) {
        let url = URL(string: "https://github.com/XQS6LB3A/LyricsX/releases")!
        NSWorkspace.shared().open(url)
    }
    
}

