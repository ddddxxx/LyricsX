//
//  GlobalConst.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/2/7.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Cocoa
import EasyPreference

let LyricsXGroupIdentifier = "group.ddddxxx.LyricsX"
let LyricsXHelperIdentifier = "ddddxxx.LyricsXHelper"

let Preference = { () -> EasyPreference in
    registerUserDefaults()
    return EasyPreference(defaults: .standard)
}()
let GroupPreference = EasyPreference(defaults: UserDefaults(suiteName: LyricsXGroupIdentifier)!)

// MARK: - Notification Name

let LyricsShouldDisplayNotification = "LyricsShouldDisplayNotification"
let CurrentLyricsChangeNotification = "CurrentLyricsChangeNotification"

extension Notification.Name {
    static var PositionChange = Notification.Name(LyricsShouldDisplayNotification)
    static var LyricsChange = Notification.Name(CurrentLyricsChangeNotification)
}

// MARK: - User Defaults

extension EasyPreference.Keys {
    
    static let NotifiedUpdateVersion: Key<String>  = "NotifiedUpdateVersion"
    
    // Menu
    static let DesktopLyricsEnabled: Key<Bool>  = "DesktopLyricsEnabled"
    static let MenuBarLyricsEnabled: Key<Bool>  = "MenuBarLyricsEnabled"
    
    // General
    static let PreferredPlayerIndex: Key<Int>       = "PreferredPlayerIndex"
    static let LaunchAndQuitWithPlayer: Key<Bool>   = "LaunchAndQuitWithPlayer"
    
    static let LyricsSavingPathPopUpIndex: Key<Int>         = "LyricsSavingPathPopUpIndex"
    static let LyricsCustomSavingPathBookmark: Key<Data>    = "LyricsCustomSavingPathBookmark"
    
    static let PreferBilingualLyrics: Key<Bool>         = "PreferBilingualLyrics"
    static let ChineseConversionIndex: Key<Int>         = "ChineseConversionIndex"
    
    static let CombinedMenubarLyrics: Key<Bool>         = "CombinedMenubarLyrics"
    
    static let DisableLyricsWhenPaused: Key<Bool>       = "DisableLyricsWhenPaused"
    static let DisableLyricsWhenSreenShot: Key<Bool>    = "DisableLyricsWhenSreenShot"
    
    // Display
    static let DesktopLyricsHeighFromDock: Key<Int>     = "DesktopLyricsHeighFromDock"
    static let DesktopLyricsFontName: Key<String>       = "DesktopLyricsFontName"
    static let DesktopLyricsFontSize: Key<Int>          = "DesktopLyricsFontSize"
    
    static let DesktopLyricsColor: Key<NSColor>             = "DesktopLyricsColor"
    static let DesktopLyricsShadowColor: Key<NSColor>       = "DesktopLyricsShadowColor"
    static let DesktopLyricsBackgroundColor: Key<NSColor>   = "DesktopLyricsBackgroundColor"
    
    static let DisplayLyricsWithTag: Key<Bool>      = "DisplayLyricsWithTag"
    
    // Filter
    static let LyricsFilterEnabled: Key<Bool>       = "LyricsFilterEnabled"
    static let LyricsSmartFilterEnabled: Key<Bool>  = "LyricsSmartFilterEnabled"
    static let LyricsDirectFilterKey: Key<[String]> = "LyricsDirectFilterKey"
    static let LyricsColonFilterKey: Key<[String]>  = "LyricsColonFilterKey"
}

// MARK: -

func registerUserDefaults() {
    let defaultsUrl = Bundle.main.url(forResource: "UserDefaults", withExtension: "plist")!
    var defaults = NSDictionary(contentsOf: defaultsUrl) as! [String: AnyObject]
    defaults["DesktopLyricsColor"] = NSKeyedArchiver.archivedData(withRootObject: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)) as AnyObject
    defaults["DesktopLyricsShadowColor"] = NSKeyedArchiver.archivedData(withRootObject: #colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1)) as AnyObject
    defaults["DesktopLyricsBackgroundColor"] = NSKeyedArchiver.archivedData(withRootObject: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.6041579279)) as AnyObject
    UserDefaults.standard.register(defaults: defaults)
}
