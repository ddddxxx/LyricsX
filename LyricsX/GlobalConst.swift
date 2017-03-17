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
let Preference = { () -> EasyPreference in
    registerUserDefaults()
    return EasyPreference(defaults: .standard)
}()

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

// MARK: -

func registerUserDefaults() {
    let directFilter = ["作詞", "作词", "作曲", "編曲", "编曲", "収録", "收录", "演唱", "歌手", "歌曲", "制作", "製作", "歌词", "歌詞", "翻譯", "翻译", "插曲", "插入歌", "主题歌", "主題歌", "片頭曲", "片头曲", "片尾曲", "Lrc", "QQ", "アニメ", "LyricsBy", "ComposedBy", "CharacterSong", "InsertSong", "SoundTrack", "www\\.", "\\.com", "\\.net"]
    let colonFilter = ["by", "title", "artist", "lyrics", "歌", "唄", "曲", "作", "唱", "詞", "词", "編", "编"]
    let defaultSavingPath = NSSearchPathForDirectoriesInDomains(.musicDirectory, [.userDomainMask], true).first! + "/LyricsX"
    let registerDefaults: [String:AnyObject] = [
        // Menu
        "DesktopLyricsEnabled": NSNumber(value: true),
        "MenuBarLyricsEnabled": NSNumber(value: false),
        // Display
        "DesktopLyricsHeighFromDock": NSNumber(value: 20),
        "DesktopLyricsFontName": "Helvetica Light" as AnyObject,
        "DesktopLyricsFontSize": NSNumber(value: 28),
        "DesktopLyricsColor": NSKeyedArchiver.archivedData(withRootObject: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)) as AnyObject,
        "DesktopLyricsShadowColor": NSKeyedArchiver.archivedData(withRootObject: #colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1)) as AnyObject,
        "DesktopLyricsBackgroundColor": NSKeyedArchiver.archivedData(withRootObject: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.6041579279)) as AnyObject,
        // File
        "LyricsCustomSavingPath": defaultSavingPath as AnyObject,
        // Filter
        "LyricsDirectFilterKey": directFilter as AnyObject,
        "LyricsColonFilterKey": colonFilter as AnyObject,
    ]
    UserDefaults.standard.register(defaults: registerDefaults)
}
