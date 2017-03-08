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

    dynamic var currentOffset = 0
    
    @IBOutlet weak var statusBarMenu: NSMenu!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        registerUserDefaults()
        
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
    
    func registerUserDefaults() {
        let directFilter = ["作詞", "作词", "作曲", "編曲", "编曲", "収録", "收录", "演唱", "歌手", "歌曲", "制作", "製作", "歌词", "歌詞", "翻譯", "翻译", "插曲", "插入歌", "主题歌", "主題歌", "片頭曲", "片头曲", "片尾曲", "Lrc", "QQ", "アニメ", "LyricsBy", "ComposedBy", "CharacterSong", "InsertSong", "SoundTrack", "www\\.", "\\.com", "\\.net"]
        let colonFilter = ["by", "歌", "唄", "曲", "作", "唱", "詞", "词", "編", "编"]
        let defaultSavingPath = NSSearchPathForDirectoriesInDomains(.musicDirectory, [.userDomainMask], true).first! + "/LyricsX"
        let registerDefaults: [String:AnyObject] = [
            // Menu
            DesktopLyricsEnabled: NSNumber(value: true),
            MenuBarLyricsEnabled: NSNumber(value: false),
            // Display
            DesktopLyricsHeighFromDock: NSNumber(value: 20),
            DesktopLyricsFontName: "Helvetica Light" as AnyObject,
            DesktopLyricsFontSize: NSNumber(value: 28),
            DesktopLyricsColor: NSArchiver.archivedData(withRootObject: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)) as AnyObject,
            DesktopLyricsShadowColor: NSArchiver.archivedData(withRootObject: #colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1)) as AnyObject,
            DesktopLyricsBackgroundColor: NSArchiver.archivedData(withRootObject: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.6041579279)) as AnyObject,
            // File
            LyricsCustomSavingPath: defaultSavingPath as AnyObject,
            // Filter
            LyricsDirectFilterKey: directFilter as AnyObject,
            LyricsColonFilterKey: colonFilter as AnyObject,
            ]
        UserDefaults.standard.register(defaults: registerDefaults)
    }

    @IBAction func lyricsOffsetStepAction(_ sender: Any) {
        helper?.currentLyrics?.offset = currentOffset
        helper?.currentLyrics?.saveToLocal()
    }
    
}

