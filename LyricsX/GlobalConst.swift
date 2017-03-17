//
//  GlobalConst.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/2/7.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Cocoa
import EasyPreference

let appDelegate = NSApplication.shared().delegate as! AppDelegate
let Preference = EasyPreference(defaults: .standard)

// MARK: - Notification Name

let LyricsShouldDisplayNotification = "LyricsShouldDisplay"

extension Notification.Name {
    static var lyricsShouldDisplay = Notification.Name(LyricsShouldDisplayNotification)
}

// MARK: - User Defaults

// Menu
let DesktopLyricsEnabled: PreferenceKey<Bool>   = "DesktopLyricsEnabled"
let MenuBarLyricsEnabled: PreferenceKey<Bool>   = "MenuBarLyricsEnabled"

// Display
let DesktopLyricsHeighFromDock: PreferenceKey<Int>  = "DesktopLyricsHeighFromDock"
let DesktopLyricsFontName: PreferenceKey<String>    = "DesktopLyricsFontName"
let DesktopLyricsFontSize: PreferenceKey<Int>       = "DesktopLyricsFontSize"

let DesktopLyricsColor: PreferenceKey<NSColor>              = "DesktopLyricsColor"
let DesktopLyricsShadowColor: PreferenceKey<NSColor>        = "DesktopLyricsShadowColor"
let DesktopLyricsBackgroundColor: PreferenceKey<NSColor>    = "DesktopLyricsBackgroundColor"

let DisplayLyricsWithTag: PreferenceKey<Bool>   = "DisplayLyricsWithTag"

// File
let LyricsCustomSavingPath: PreferenceKey<String>   = "LyricsCustomSavingPath"

// Filter
let LyricsDirectFilterKey: PreferenceKey<[String]>  = "LyricsDirectFilterKey"
let LyricsColonFilterKey: PreferenceKey<[String]>   = "LyricsColonFilterKey"
