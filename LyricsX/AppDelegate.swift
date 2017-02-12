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
    var desktopLyrics: DesktopLyricsController!
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
            DesktopLyricsColor: NSKeyedArchiver.archivedData(withRootObject: NSColor.white) as AnyObject,
            DesktopLyricsShadowColor: NSKeyedArchiver.archivedData(withRootObject: NSColor.cyan) as AnyObject,
            DesktopLyricsBackgroundColor: NSKeyedArchiver.archivedData(withRootObject: NSColor(white: 0, alpha: 0.6)) as AnyObject,
        ]
        UserDefaults.standard.register(defaults: registerDefaults)
        
        helper = iTunesHelper()
        
        statusItem = NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength)
        desktopLyrics = DesktopLyricsController()
        menuBarLyrics = MenuBarLyrics()
        
        desktopLyrics.showWindow(nil)
        
        statusItem.button?.image = #imageLiteral(resourceName: "status_bar_icon")
        statusItem.menu = statusBarMenu
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

