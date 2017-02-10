//
//  AppDelegate.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/2/4.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var helper: iTunesHelper!
    
    var statusItem: NSStatusItem!
    var desktopLyrics: DesktopLyrics!
    var menuBarLyrics: MenuBarLyrics!

    @IBOutlet weak var statusBarMenu: NSMenu!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let registerDefaults: [String:AnyObject] = [
            // Menu
            DesktopLyricsEnabled : NSNumber(value: true),
            MenuBarLyricsEnabled : NSNumber(value: false),
            // Display
            DesktopLyricsHeighFromDock : NSNumber(value: 20),
            DesktopLyricsFontName: "Helvetica Light" as AnyObject,
            DesktopLyricsFontSize: NSNumber(value: 28),
        ]
        UserDefaults.standard.register(defaults: registerDefaults)
        
        helper = iTunesHelper()
        
        statusItem = NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength)
        desktopLyrics = DesktopLyrics()
        menuBarLyrics = MenuBarLyrics()
        
        statusItem.button?.image = #imageLiteral(resourceName: "status_bar_icon")
        statusItem.menu = statusBarMenu
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

