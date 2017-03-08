//
//  GlobalConst.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/2/7.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Cocoa

let appDelegate = NSApplication.shared().delegate as! AppDelegate

// MARK: - Notification Name

let LyricsShouldDisplayNotification = "LyricsShouldDisplay"

extension Notification.Name {
    static var lyricsShouldDisplay = Notification.Name(LyricsShouldDisplayNotification)
}

// MARK: - User Defaults

// Menu
let DesktopLyricsEnabled = "DesktopLyricsEnabled"
let MenuBarLyricsEnabled = "MenuBarLyricsEnabled"

// Display
let DesktopLyricsHeighFromDock = "DesktopLyricsHeighFromDock"
let DesktopLyricsFontName = "DesktopLyricsFontName"
let DesktopLyricsFontSize = "DesktopLyricsFontSize"

let DesktopLyricsColor = "DesktopLyricsColor"
let DesktopLyricsShadowColor = "DesktopLyricsShadowColor"
let DesktopLyricsBackgroundColor = "DesktopLyricsBackgroundColor"

let DisplayLyricsWithTag = "DisplayLyricsWithTag"

// File
let LyricsCustomSavingPath = "LyricsCustomSavingPath"

// Filter
let LyricsDirectFilterKey = "LyricsDirectFilterKey"
let LyricsColonFilterKey = "LyricsColonFilterKey"
