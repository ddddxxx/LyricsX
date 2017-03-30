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

let appDelegate = { NSApplication.shared().delegate as? AppDelegate }
let Preference = { () -> EasyPreference in
    registerUserDefaults()
    return EasyPreference(defaults: .standard)
}()
let GroupPreference = EasyPreference(defaults: UserDefaults(suiteName: LyricsXGroupIdentifier)!)

// MARK: - Notification Name

let LyricsShouldDisplayNotification = "LyricsShouldDisplayNotification"
let CurrentLyricsChangeNotification = "CurrentLyricsChangeNotification"

extension Notification.Name {
    static var lyricsShouldDisplay = Notification.Name(LyricsShouldDisplayNotification)
    static var currentLyricsChange = Notification.Name(CurrentLyricsChangeNotification)
}

// MARK: - User Defaults

// Menu
let DesktopLyricsEnabled: PreferenceKey<Bool>   = "DesktopLyricsEnabled"
let MenuBarLyricsEnabled: PreferenceKey<Bool>   = "MenuBarLyricsEnabled"

// General
let PreferredPlayerIndex: PreferenceKey<Int>        = "PreferredPlayerIndex"
let LaunchAndQuitWithPlayer: PreferenceKey<Bool>    = "LaunchAndQuitWithPlayer"

let LyricsSavingPathPopUpIndex: PreferenceKey<Int>  = "LyricsSavingPathPopUpIndex"
let LyricsCustomSavingPathBookmark: PreferenceKey<Data>     = "LyricsCustomSavingPathBookmark"

let PreferBilingualLyrics: PreferenceKey<Bool>      = "PreferBilingualLyrics"
let ChineseConversionIndex: PreferenceKey<Int>      = "ChineseConversionIndex"

let DisableLyricsWhenPaused: PreferenceKey<Bool>    = "DisableLyricsWhenPaused"
let DisableLyricsWhenSreenShot: PreferenceKey<Bool> = "DisableLyricsWhenSreenShot"

// Display
let DesktopLyricsHeighFromDock: PreferenceKey<Int>  = "DesktopLyricsHeighFromDock"
let DesktopLyricsFontName: PreferenceKey<String>    = "DesktopLyricsFontName"
let DesktopLyricsFontSize: PreferenceKey<Int>       = "DesktopLyricsFontSize"

let DesktopLyricsColor: PreferenceKey<NSColor>              = "DesktopLyricsColor"
let DesktopLyricsShadowColor: PreferenceKey<NSColor>        = "DesktopLyricsShadowColor"
let DesktopLyricsBackgroundColor: PreferenceKey<NSColor>    = "DesktopLyricsBackgroundColor"

let DisplayLyricsWithTag: PreferenceKey<Bool>       = "DisplayLyricsWithTag"

// Filter
let LyricsFilterEnabled: PreferenceKey<Bool>        = "LyricsFilterEnabled"
let LyricsSmartFilterEnabled: PreferenceKey<Bool>   = "LyricsSmartFilterEnabled"
let LyricsDirectFilterKey: PreferenceKey<[String]>  = "LyricsDirectFilterKey"
let LyricsColonFilterKey: PreferenceKey<[String]>   = "LyricsColonFilterKey"

// MARK: -

func registerUserDefaults() {
    let defaultsUrl = Bundle.main.url(forResource: "UserDefaults", withExtension: "plist")!
    var defaults = NSDictionary(contentsOf: defaultsUrl) as! [String: AnyObject]
    defaults["DesktopLyricsColor"] = NSKeyedArchiver.archivedData(withRootObject: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)) as AnyObject
    defaults["DesktopLyricsShadowColor"] = NSKeyedArchiver.archivedData(withRootObject: #colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1)) as AnyObject
    defaults["DesktopLyricsBackgroundColor"] = NSKeyedArchiver.archivedData(withRootObject: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.6041579279)) as AnyObject
    UserDefaults.standard.register(defaults: defaults)
}
