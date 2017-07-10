//
//  GlobalConst.swift
//
//  This file is part of LyricsX
//  Copyright (C) 2017  Xander Deng
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Cocoa
import GenericID

// NOTE: to build your own product, you need to replace the team identifier to yours
// and do the same thing in LyricsXHelper
let LyricsXGroupIdentifier = "3665V726AE.group.ddddxxx.LyricsX"
let LyricsXHelperIdentifier = "ddddxxx.LyricsXHelper"

let defaults = UserDefaults.standard
let groupDefaults = UserDefaults(suiteName: LyricsXGroupIdentifier)!

extension CAMediaTimingFunction {
    static let mystery = CAMediaTimingFunction(controlPoints: 0.2, 0.1, 0.2, 1)
}

func log(_ message: @autoclosure () -> String, file: StaticString = #file, line: UInt = #line) {
    NSLog("\(file):\(line): \(message())")
}

extension NSStoryboard.Identifiers {
    static let DesktopLyricsWindow: ID<NSWindowController> = "DesktopLyricsWindow"
    static let LyricsHUDAccessory: ID<LyricsHUDAccessoryViewController> = "LyricsHUDAccessory"
}

// MARK: - Notification Name

let LyricsShouldDisplayNotification = "LyricsShouldDisplayNotification"
let CurrentLyricsChangeNotification = "CurrentLyricsChangeNotification"

extension Notification.Name {
    static var PositionChange = Notification.Name(LyricsShouldDisplayNotification)
    static var LyricsChange = Notification.Name(CurrentLyricsChangeNotification)
}

// MARK: - User Defaults

extension UserDefaults.DefaultKeys {
    
    static let NotifiedUpdateVersion: Key<String?>  = "NotifiedUpdateVersion"
    static let NoSearchingTrackIds: Key<[String]>   = "NoSearchingTrackIds"
    
    // Menu
    static let DesktopLyricsEnabled: Key<Bool>  = "DesktopLyricsEnabled"
    static let MenuBarLyricsEnabled: Key<Bool>  = "MenuBarLyricsEnabled"
    
    // General
    static let PreferredPlayerIndex: Key<Int>       = "PreferredPlayerIndex"
    static let LaunchAndQuitWithPlayer: Key<Bool>   = "LaunchAndQuitWithPlayer"
    
    static let LyricsSavingPathPopUpIndex: Key<Int>         = "LyricsSavingPathPopUpIndex"
    static let LyricsCustomSavingPathBookmark: Key<Data?>   = "LyricsCustomSavingPathBookmark"
    static let LoadLyricsBesideTrack: Key<Bool>         = "LoadLyricsBesideTrack"
    
    static let PreferBilingualLyrics: Key<Bool>         = "PreferBilingualLyrics"
    static let ChineseConversionIndex: Key<Int>         = "ChineseConversionIndex"
    
    static let CombinedMenubarLyrics: Key<Bool>         = "CombinedMenubarLyrics"
    
    static let DisableLyricsWhenPaused: Key<Bool>       = "DisableLyricsWhenPaused"
    static let DisableLyricsWhenSreenShot: Key<Bool>    = "DisableLyricsWhenSreenShot"
    
    // Display
    static let DesktopLyricsOneLineMode: Key<Bool>      = "DesktopLyricsOneLineMode"
    
    static let DesktopLyricsInsetTopEnabled: Key<Bool>      = "DesktopLyricsInsetTopEnabled"
    static let DesktopLyricsInsetBottomEnabled: Key<Bool>   = "DesktopLyricsInsetBottomEnabled"
    static let DesktopLyricsInsetLeftEnabled: Key<Bool>     = "DesktopLyricsInsetLeftEnabled"
    static let DesktopLyricsInsetRightEnabled: Key<Bool>    = "DesktopLyricsInsetRightEnabled"
    
    static let DesktopLyricsInsetTop: Key<Int>          = "DesktopLyricsInsetTop"
    static let DesktopLyricsInsetBottom: Key<Int>       = "DesktopLyricsInsetBottom"
    static let DesktopLyricsInsetLeft: Key<Int>         = "DesktopLyricsInsetLeft"
    static let DesktopLyricsInsetRight: Key<Int>        = "DesktopLyricsInsetRight"
    
    static let DesktopLyricsFontName: Key<String?>      = "DesktopLyricsFontName"
    static let DesktopLyricsFontSize: Key<Int>          = "DesktopLyricsFontSize"
    
    static let DesktopLyricsColor: Key<NSColor>             = "DesktopLyricsColor"
    static let DesktopLyricsShadowColor: Key<NSColor>       = "DesktopLyricsShadowColor"
    static let DesktopLyricsBackgroundColor: Key<NSColor>   = "DesktopLyricsBackgroundColor"
    
    static let DisplayLyricsWithTag: Key<Bool>      = "DisplayLyricsWithTag"
    
    // Shortcut
    static let ShortcutOffsetIncrease: Key<String>  = "ShortcutOffsetIncrease"
    static let ShortcutOffsetDecrease: Key<String>  = "ShortcutOffsetDecrease"
    static let ShortcutWriteToiTunes: Key<String>   = "ShortcutWriteToiTunes"
    static let ShortcutWrongLyrics: Key<String>     = "ShortcutWrongLyrics"
    
    // Filter
    static let LyricsFilterEnabled: Key<Bool>       = "LyricsFilterEnabled"
    static let LyricsSmartFilterEnabled: Key<Bool>  = "LyricsSmartFilterEnabled"
    static let LyricsDirectFilterKey: Key<[String]> = "LyricsDirectFilterKey"
    static let LyricsColonFilterKey: Key<[String]>  = "LyricsColonFilterKey"
    
    // Lab
    static let WriteiTunesWithTranslation: Key<Bool>    = "WriteiTunesWithTranslation"
    static let WriteToiTunesAutomatically: Key<Bool>    = "WriteToiTunesAutomatically"
    
    static let LyricsSources: Key<[String]>         = "LyricsSources"
    static let PreferredLyricsSource: Key<String?>  = "PreferredLyricsSource"
}
